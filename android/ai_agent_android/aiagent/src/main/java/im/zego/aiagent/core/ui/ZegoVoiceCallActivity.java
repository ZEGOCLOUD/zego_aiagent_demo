package im.zego.aiagent.core.ui;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.AbsListView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import com.google.gson.Gson;
import com.squareup.picasso.Picasso;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.AppUserInfo;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.data.RTCRoomMessage;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallExpressImpl;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallExpressImpl.SendMediaCallBack;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallProxy;
import im.zego.aiagent.core.widget.ZegoAgentTestView;
import im.zego.aiagent.core.widget.ZegoSwitchTTSWindow;
import im.zego.aiagent.core.widget.ZegoVoiceActivityChecker;
import im.zego.aiagent.core.widget.ZegoVoiceActivityChecker.VadCheckerInfo;
import im.zego.aiagent.core.widget.ZegoVoiceCallMessageAdapter;
import im.zego.zegoexpress.callback.IZegoEventHandler;
import im.zego.zegoexpress.constants.ZegoStreamEvent;
import im.zego.zegoexpress.entity.ZegoPlayStreamQuality;
import im.zego.zegoexpress.entity.ZegoPublishStreamQuality;
import im.zego.zegoexpress.entity.ZegoSoundLevelInfo;
import im.zego.zegoexpress.entity.ZegoUser;
import java.io.File;
import java.util.Timer;
import java.util.TimerTask;
import timber.log.Timber;

/**
 * 语音通话页面
 */
public class ZegoVoiceCallActivity extends AppCompatActivity {

    public enum ChatSessionState {
        UNINIT, //未初始化状态
        AI_SPEAKING,//AI在讲话
        AI_THINKING,//AI在想，LLM大模型推理
        AI_LISTEN,  //AI在听
    }

    private static final String TAG = "ZegoVoiceCallActivity";
    private ListView mMessageListView;
    private ZegoVoiceCallMessageAdapter messageAdapter;
    private TextView mStatusTextView;
    private ImageView mMicButton;
    private boolean mIsMicOn = false;
    private ZegoSwitchTTSWindow mTTSSettingsWindow;
    private boolean mMessageListViewAutoScrollToBottom;

    private ZegoAgentTestView mTestView;                            //测试数据View


    //下面变量是用来实现快速打断逻辑
    private ZegoVoiceActivityChecker mVadChecker;
    protected ZegoVoiceCallActivity.ChatSessionState mChatSessionState = ZegoVoiceCallActivity.ChatSessionState.UNINIT;
    private final Handler handler = new Handler();
    private int kOriginVolume = 100;
    private final int kCycles = 10; // 分 10 次递减
    private long kCheckSeq = 0;
    private Timer timer;
    private boolean mLocalMuteFlag = false;
    private Gson gson = new Gson();


    private ZegoVoiceCallProxy rtcFunction;
    private ActivityResultLauncher<String> requestPermissionLauncher = registerForActivityResult(
        new ActivityResultContracts.RequestPermission(), new ActivityResultCallback<Boolean>() {
            @Override
            public void onActivityResult(Boolean isGranted) {
                if (isGranted) {
                    onRecordAudioPermissionGranted();
                } else {
                    Toast.makeText(ZegoVoiceCallActivity.this, "录音权限被拒绝，无法录音", Toast.LENGTH_LONG).show();
                    ZegoVoiceCallActivity.this.finish();
                }
            }
        });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        rtcFunction = ZegoAIAgentHelper.getVoiceCallProxy();
        configuration = ViewConfiguration.get(this);

        if (rtcFunction == null) {
            rtcFunction = new ZegoVoiceCallExpressImpl();
            ZegoAIAgentHelper.setVoiceCallProxy(rtcFunction);
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            requestPermissionLauncher.launch(Manifest.permission.RECORD_AUDIO);
        } else {
            // 权限已被授予，可以直接录音
            onRecordAudioPermissionGranted();
        }
    }

    private void onRecordAudioPermissionGranted() {

        initView();

        mVadChecker = new ZegoVoiceActivityChecker();
        rtcFunction.init(getApplication());

        AppUserInfo userInfo = ZegoAIAgentConfigController.getUserInfo();
        rtcFunction.loginUser(userInfo.userID, userInfo.userName, "", null);
        rtcFunction.setEventHandler(new ZegoExpressEventHandler(this));

        ZegoVoiceCallExpressImpl.sendMediaCallBack = new SendMediaCallBack() {
            @Override
            public void onSendFinished() {
                File file = new File(ZegoVoiceCallExpressImpl.audioPath);
                String message = "文件 " + file.getName() + " 发送完毕";
                Toast.makeText(ZegoVoiceCallActivity.this, message, Toast.LENGTH_SHORT).show();
                updateStatusText(message);
            }

            @Override
            public void onError() {
                Toast.makeText(ZegoVoiceCallActivity.this, "文件不存在或者大小为0", Toast.LENGTH_SHORT).show();
            }
        };
        prepare();
    }

    public void prepare() {
        ZegoAIAgentConfigController.CharacterConfig curUser = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        if (curUser == null) {
            updateStatusText("智能体配置错误：当前没有设置智能体");
            return;
        }
        // 进入 RTC 房间,并推流
        rtcFunction.loginRoom(curUser.getRoomID(), (errorCode, message) -> {
            if (errorCode == 0) {
                // todo  推流成功后才向后台请求开启语音会话
                startRTCChat();
            } else {
                updateStatusText("rtcFunction.loginRoom 错误：" + errorCode);
            }
        });
    }

    public static void startActivity(Context context) {
        Intent intent = new Intent(context, ZegoVoiceCallActivity.class);
        context.startActivity(intent);
    }

    public void updateStatusText(String text) {
        mStatusTextView.setText(text);
    }


    public void startRTCChat() {
        ZegoAIAgentRequest.startRtcChat(new AIAgentCommonCallBack<Void>() {
            @Override
            public void onCallback(int errorCode, String message, Void unused) {
                if (errorCode == 0 || errorCode == 410003101) {
                    //                    if (errorCode != 0) {
                    //                        Toast.makeText(ZegoVoiceCallActivity.this, "startRtcChat：上一个RTCChat 未结束：" + errorCode,
                    //                            Toast.LENGTH_SHORT).show();
                    //                    }
                    onExpressReady();
                    ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
                        .getCurrentCharacter();
                    mTestView.setRoomID(characterConfig.getRoomID());
                    mTestView.setConversationID(characterConfig.conversationId);
                } else {
                    updateStatusText("startRtcChat,errorCode：" + errorCode + ",message:" + message);
                }
            }
        });
    }


    private boolean finishedInOnPauseLifeCycle = false;

    @Override
    protected void onPause() {
        super.onPause();
        Log.d(TAG, "onPause() called");
        if (isFinishing()) {
            // 正常 finish,直接 clear
            // 比如反复进出此页面，不会引起时序的问题。
            finishedInOnPauseLifeCycle = true;
            clearResources();
        }
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onDestroy() called");
        super.onDestroy();
        if (!finishedInOnPauseLifeCycle) {
            clearResources();
        }
    }

    private void clearResources() {
        Log.d(TAG, "clearResources() called");
        stopRtcChat();
        rtcFunction.logoutRoom();
        rtcFunction.logoutUser();
        rtcFunction.setEventHandler(null);
        rtcFunction.destroyEngine();
        ZegoAIAgentHelper.setVoiceCallProxy(null);
        ZegoVoiceCallExpressImpl.sendMediaCallBack = null;
    }

    public void stopRtcChat() {
        ZegoAIAgentRequest.stopRtcChat(null);
    }

    protected void onExpressReady() {
        switchMicState(true); // 默认打开麦克风
        updateStatusText("已连接");

        if (ZegoVoiceCallExpressImpl.customAudioCapture) {
            File file = new File(ZegoVoiceCallExpressImpl.audioPath);
            updateStatusText("使用本地音频：" + file.getName());
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initView() {
        setContentView(R.layout.widget_voice_call_foreground_view);
        TextView userNameTextView = findViewById(R.id.user_name);
        userNameTextView.setText(ZegoAIAgentConfigController.getConfig().getCurrentCharacter().name);
        ImageView backgroundImageView = findViewById(R.id.background);
        Picasso.get().load(ZegoAIAgentConfigController.getConfig().getCurrentCharacter().getBackground())
            .into(backgroundImageView);
        mMessageListView = findViewById(R.id.message_list);
        messageAdapter = new ZegoVoiceCallMessageAdapter();
        mMessageListView.setAdapter(messageAdapter);
        mMessageListView.setDivider(null);
        mMessageListView.setDividerHeight(0);
        mStatusTextView = findViewById(R.id.status);
        updateStatusText("呼叫中...");
        ImageView settingsButton = findViewById(R.id.settings);
        settingsButton.setOnClickListener(v -> mTTSSettingsWindow.show(ZegoSwitchTTSWindow.MODE_EDIT));
        mTTSSettingsWindow = new ZegoSwitchTTSWindow(findViewById(R.id.root));
        mMicButton = findViewById(R.id.microphone);
        mMicButton.setOnClickListener(v -> switchMicState(!mIsMicOn));
        findViewById(R.id.end_call).setOnClickListener(v -> finish());
        mTestView = findViewById(R.id.atv_test_view);

        // 判断需要自动滚动到底部，用户在浏览态下不要自动滚动到底部
        // 浏览态定义：用户手动滑动列表浏览历史消息
        // 判断两个时刻：
        // 1. 手指离开屏幕列表有没有到底部
        // 2. 手指离开后列表是否借势能自动滚动到底部，自动滚动到底部则取消浏览态
        mMessageListViewAutoScrollToBottom = true;
        // 1. 判断手指离开屏幕列表有没有到底部
        mMessageListView.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                if (mMessageListView.getChildCount() == 0) {
                    mMessageListViewAutoScrollToBottom = true;
                } else {
                    View lastVisibleItemView = mMessageListView.getChildAt(mMessageListView.getChildCount() - 1);
                    ZegoVoiceCallMessageAdapter.ViewHolder viewHolder = (ZegoVoiceCallMessageAdapter.ViewHolder) lastVisibleItemView.getTag();
                    if (viewHolder.position != messageAdapter.getCount() - 1) {
                        mMessageListViewAutoScrollToBottom = false;
                    } else if (lastVisibleItemView.getBottom() > mMessageListView.getHeight()) {
                        mMessageListViewAutoScrollToBottom = false;
                    } else {
                        mMessageListViewAutoScrollToBottom = true;
                    }
                }
            }
            return false;
        });
        // 2. 判断手指离开后列表是否借势能自动滚动到底部
        mMessageListView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                if (mMessageListView.getChildCount() > 0) {
                    View lastVisibleItemView = mMessageListView.getChildAt(mMessageListView.getChildCount() - 1);
                    if (lastVisibleItemView.getBottom() <= mMessageListView.getHeight()) {
                        mMessageListViewAutoScrollToBottom = true;
                    }
                }
            }
        });
    }

    private void switchMicState(boolean on) {
        Timber.d("switchMicState: " + on);
        mIsMicOn = on;
        runOnUiThread(() -> {
            rtcFunction.muteMicrophone(!mIsMicOn);
            if (on) {
                mMicButton.setImageResource(R.mipmap.icon_mic_normal);
            } else {
                mMicButton.setImageResource(R.mipmap.icon_mic_jinyong);
            }
        });
    }

    private void setPlayVolumeInternal(int volume) {
        String agentStreamID = ZegoAIAgentConfigController.getConfig().getCurrentCharacter().getAgentStreamID();
        rtcFunction.setPlayVolume(agentStreamID, volume);
        mTestView.setPlayVolume(volume);
    }

    private void graduallyMutePlayVolumeByWeightAverage(float weightAverage) {
        float graduallyf = 100 * (1 - weightAverage);
        int graduallyn = Math.round(graduallyf);
        setPlayVolumeInternal(graduallyn);
    }

    private void graduallyMutePlayVolumeByTimer(float duration, long checkSeq) {
        if (handler != null || kCheckSeq == checkSeq) {
            return;
        }
        kCheckSeq = checkSeq;

        // 设置时间间隔
        final long period = (long) (duration / kCycles);
        timer = new Timer();

        // 第一次会立刻执行，然后再间隔执行
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (mChatSessionState == ChatSessionState.AI_SPEAKING) {
                            kOriginVolume -= 10;
                            Log.d("applechang-test,", "graduallyMutePlayVolumeByTimer:" + kOriginVolume);
                            setPlayVolumeInternal(kOriginVolume);
                            if (kOriginVolume == 0) {
                                // 关闭定时器
                                if (timer != null) {
                                    timer.cancel();
                                    timer = null;
                                }
                                kOriginVolume = 100;
                            }
                        } else {
                            // 关闭定时器
                            if (timer != null) {
                                timer.cancel();
                                timer = null;
                            }
                            kOriginVolume = 100;
                        }
                    }
                });
            }
        }, 0, period);
    }

    //实现该回调用来实现快速打断逻辑,如果不需要请注释
    public void onCapturedSoundLevelInfoUpdate(ZegoSoundLevelInfo soundLevelInfo) {
        VadCheckerInfo checkerInfo = mVadChecker.voiceActivityDetection(soundLevelInfo.vad);

        //方案一：500ms内渐隐效果静音，客户也可以自己定这个渐隐时长
        if (checkerInfo.isVoiceActivity() && mChatSessionState == ChatSessionState.AI_SPEAKING && !mLocalMuteFlag) {
            float gradually = 100 * (1 - checkerInfo.getWeightAverage());
            Log.d("applechang-test",
                "onCapturedSoundLevelInfoUpdate setPlayVolume gradually=" + gradually + ",soundLevel="
                    + soundLevelInfo.soundLevel + ",weightAverage=" + checkerInfo.getWeightAverage()
                    + ", voiceActivity=" + checkerInfo.isVoiceActivity());
            graduallyMutePlayVolumeByTimer(500.0F, checkerInfo.getCheckSeq());
            mLocalMuteFlag = true;
        }

        //方案二：基于VAD加权和做衰减静音，效果上可能没那么平滑，但能保证200～300ms内静音
        //        if (checkerInfo.isVoiceActivity() &&
        //                mChatSessionState == ChatSessionState.AI_SPEAKING &&){
        //            float gradually = 100*(1-checkerInfo.getWeightAverage());
        //            Log.d("applechang-test", "onCapturedSoundLevelInfoUpdate setPlayVolume gradually=" + gradually +",soundLevel="+soundLevelInfo.soundLevel+",weightAverage="+ checkerInfo.getWeightAverage() + ", voiceActivity=" + checkerInfo.isVoiceActivity());
        //            graduallyMutePlayVolumeByWeightAverage(gradually);
        //        }

    }

    private void scrollToBottom() {
        // 滚动到最新一条，如果用户在浏览其他信息则不滚动
        if (mMessageListViewAutoScrollToBottom && mMessageListView.getChildCount() > 0) {
            mMessageListViewAutoScrollToBottom = true;
            // 没展示最后一条，滚动到最后一条
            if (mMessageListView.getLastVisiblePosition() != messageAdapter.getCount() - 1) {
                mMessageListView.smoothScrollToPosition(messageAdapter.getCount() - 1);
                Log.d(TAG,
                    "Scroll to last message: last -> " + mMessageListView.getLastVisiblePosition() + ", count -> "
                        + messageAdapter.getCount());
            } else {
                // 展示到最后一条了，则滚到到这条末尾
                View lastVisibleItemView = mMessageListView.getChildAt(mMessageListView.getChildCount() - 1);
                int extraScroll = lastVisibleItemView.getBottom() - mMessageListView.getHeight();
                if (extraScroll > 0) {
                    mMessageListView.smoothScrollBy(extraScroll, 500);
                }
            }
        }
    }


    private int lastCMD1Seq;

    private void onIMRecvCustomCommand(String roomID, ZegoUser fromUser, String command) {
        if (TextUtils.isEmpty(command)) {
            Timber.d("onIMRecvCustomCommand command is null");
            return;
        }

        try {
            RTCRoomMessage roomMessage = gson.fromJson(command, RTCRoomMessage.class);
            mTestView.onIMRecvCustomCommand(roomMessage);

            switch (roomMessage.cmd) {
                case 1:
                    if (roomMessage.seq_id < lastCMD1Seq) {
                        Timber.d("收到 cmd = 1,上次seq = [" + lastCMD1Seq + "], 当前seq  = [" + roomMessage.seq_id
                            + "], 丢弃该消息");
                        return;
                    }
                    if (roomMessage.data.speak_status == 1) {
                        updateStatusText("正在听...");
                        this.mChatSessionState = ChatSessionState.AI_LISTEN;
                        setPlayVolumeInternal(0);
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.VAD_MyVoice_Start);
                    } else if (roomMessage.data.speak_status == 2) {
                        updateStatusText("正在想...");
                        this.mChatSessionState = ChatSessionState.AI_THINKING;
                        this.mLocalMuteFlag = false;
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.VAD_AIVoice_Finish);
                    }
                    lastCMD1Seq = roomMessage.seq_id;
                    break;
                case 2:
                    if (roomMessage.data.speak_status == 1) {
                        updateStatusText("可以随时说话打断我");
                        this.mChatSessionState = ChatSessionState.AI_SPEAKING;
                        setPlayVolumeInternal(100);
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.VAD_AIVoice_Start);
                    } else if (roomMessage.data.speak_status == 2) {
                        updateStatusText("正在听...");
                        this.mChatSessionState = ChatSessionState.AI_LISTEN;
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.VAD_AIVoice_Finish);
                    }
                    break;
                case 3:
                    //  收到 asr 文本（右边），更新聊天信息
                    if (!TextUtils.isEmpty(roomMessage.data.text)) {
                        messageAdapter.updateASRChatRMessage(roomMessage);
                        scrollToBottom();
                    }
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ReceiveASRText);
                    break;
                case 4:
                    // 收到 LLM 文本(左边)，更新聊天信息
                    messageAdapter.addOrUpdateLLMChatMessage(roomMessage);
                    scrollToBottom();
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ReceiveLLMText);
                    break;
                default:
                    break;
            }
        } catch (Exception e) {

        }

    }


    private void onPublisherStreamEvent(ZegoStreamEvent eventID, String streamID, String extraInfo) {
        if (eventID == ZegoStreamEvent.PUBLISH_SUCCESS) {
            if (rtcFunction != null) {
                rtcFunction.startDumpData();
            }
        }
    }

    private void onPublisherQualityUpdate(String streamID, ZegoPublishStreamQuality quality) {
        mTestView.onPublisherQualityUpdate(streamID, quality);
    }

    private void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
        mTestView.onPlayerQualityUpdate(streamID, quality);
    }


    /**
     * 事件handler
     */
    private static class ZegoExpressEventHandler extends IZegoEventHandler {

        public Context mContext;

        public ZegoExpressEventHandler(Context context) {
            mContext = context;
        }


        @Override
        public void onIMRecvCustomCommand(String roomID, ZegoUser fromUser, String command) {
            ZegoVoiceCallActivity instance = (ZegoVoiceCallActivity) mContext;
            instance.onIMRecvCustomCommand(roomID, fromUser, command);
        }

        @Override
        public void onCapturedSoundLevelInfoUpdate(ZegoSoundLevelInfo soundLevelInfo) {
            ZegoVoiceCallActivity instance = (ZegoVoiceCallActivity) mContext;
            instance.onCapturedSoundLevelInfoUpdate(soundLevelInfo);
        }

        @Override
        public void onPublisherStreamEvent(ZegoStreamEvent eventID, String streamID, String extraInfo) {
            super.onPublisherStreamEvent(eventID, streamID, extraInfo);
            ZegoVoiceCallActivity instance = (ZegoVoiceCallActivity) mContext;
            instance.onPublisherStreamEvent(eventID, streamID, extraInfo);
        }

        @Override
        public void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
            super.onPlayerQualityUpdate(streamID, quality);
            ZegoVoiceCallActivity instance = (ZegoVoiceCallActivity) mContext;
            instance.onPlayerQualityUpdate(streamID, quality);
        }

        @Override
        public void onPublisherQualityUpdate(String streamID, ZegoPublishStreamQuality quality) {
            super.onPublisherQualityUpdate(streamID, quality);
            ZegoVoiceCallActivity instance = (ZegoVoiceCallActivity) mContext;
            instance.onPublisherQualityUpdate(streamID, quality);
        }
    }


    private float downX, downY;
    private ViewConfiguration configuration;

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                downX = event.getX();
                downY = event.getY();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        performLongClickAction();
                    }
                }, 3000);
                break;
            case MotionEvent.ACTION_MOVE:
                if (Math.abs(event.getX() - downX) > configuration.getScaledTouchSlop()
                    || Math.abs(event.getY() - downY) > configuration.getScaledTouchSlop()) {
                    // 用户移动了手指，取消长按检测
                    handler.removeCallbacksAndMessages(null);
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                handler.removeCallbacksAndMessages(null);
                break;
        }
        return super.dispatchTouchEvent(event);
    }

    private void performLongClickAction() {
        if (mTestView.getVisibility() == View.VISIBLE) {
            mTestView.setVisibility(View.GONE);
        } else {
            mTestView.setVisibility(View.VISIBLE);
        }
    }
}
