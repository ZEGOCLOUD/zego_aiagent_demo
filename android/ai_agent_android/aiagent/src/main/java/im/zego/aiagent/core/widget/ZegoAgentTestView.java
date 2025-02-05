package im.zego.aiagent.core.widget;

import android.content.Context;
import android.text.method.ScrollingMovementMethod;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.CompoundButton;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.google.android.material.switchmaterial.SwitchMaterial;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.data.RTCRoomMessage;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallProxy;
import im.zego.zegoexpress.entity.ZegoPlayStreamQuality;
import im.zego.zegoexpress.entity.ZegoPublishStreamQuality;
import java.util.LinkedList;

/**
 * 测试入口View
 */
public class ZegoAgentTestView extends ConstraintLayout {

    private SwitchMaterial mAudioDumpSwitch;
    private TextView publishText;
    private TextView playText;
    private TextView playVolume;
    private TextView cmdText;
    private TextView room_id;
    private TextView conversation_id;
    private LinkedList<RTCRoomMessage> cmdList = new LinkedList<>();
    private static final int MAX_LOG_COUNT = 8;

    public ZegoAgentTestView(@NonNull Context context) {
        super(context);
        initView();
    }

    public ZegoAgentTestView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public ZegoAgentTestView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.view_agent_test, this, true);
        mAudioDumpSwitch = findViewById(R.id.switch_audio_dump);
        mAudioDumpSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                ZegoVoiceCallProxy rtcFunction = ZegoAIAgentHelper.getVoiceCallProxy();
                if (isChecked) {
                    if (rtcFunction != null) {
                        rtcFunction.startDumpData();
                    }
                    mAudioDumpSwitch.setText("dump 已开启");
                } else {
                    if (rtcFunction != null) {
                        rtcFunction.stopDumpData();
                    }
                    mAudioDumpSwitch.setText("dump 已关闭");
                }

            }
        });

        publishText = findViewById(R.id.log_publish_text);
        playText = findViewById(R.id.log_play_text);
        playVolume = findViewById(R.id.log_play_volume);
        cmdText = findViewById(R.id.log_cmd_text);
        cmdText.setMovementMethod(ScrollingMovementMethod.getInstance());

        room_id = findViewById(R.id.log_room_id);
        conversation_id = findViewById(R.id.log_conversation_id);
    }

    public void onPublisherQualityUpdate(String streamID, ZegoPublishStreamQuality quality) {
        publishText.setText("推流质量 : audioCaptureFPS = [" + ((int) quality.audioCaptureFPS) + "], audioSendFPS = ["
            + ((int) quality.audioSendFPS) + "],audioKBPS:" + ((int) quality.audioKBPS));
    }

    public void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
        playText.setText("拉流质量 : audioDecodeFPS = [" + ((int) quality.audioDecodeFPS) + "], audioRecvFPS = ["
            + ((int) quality.audioRecvFPS) + "],audioKBPS:" + ((int) quality.audioKBPS));
    }

    public void setPlayVolume(int volume) {
        playVolume.setText("拉流音量：" + String.valueOf(volume));
    }

    public void onIMRecvCustomCommand(RTCRoomMessage command) {
        if (cmdList.size() > MAX_LOG_COUNT) {
            cmdList.removeFirst();
        }
        cmdList.addLast(command);
        String string = cmdList.stream().map(roomMessage -> {
            if (roomMessage.cmd == 1 || roomMessage.cmd == 2) {
                return "seq:" + roomMessage.seq_id + ",cmd:" + roomMessage.cmd + ",speak_status:"
                    + roomMessage.data.speak_status;
            } else {
                String text = roomMessage.data.text;
                if (roomMessage.data.text.length() > 20) {
                    text = text.substring(0, 10) + "...";
                }
                return "seq:" + roomMessage.seq_id + ",cmd:" + roomMessage.cmd + ",messageID:"
                    + roomMessage.data.message_id + ",text:" + text;
            }
        }).reduce((s, s2) -> s + "\n" + s2).orElse("");

        cmdText.setText(string);
    }

    public void setRoomID(String roomID) {
        room_id.setText("房间ID:" + roomID);
    }

    public void setConversationID(String conversationId) {
        conversation_id.setText("后台会话ID:" + conversationId);
    }
}
