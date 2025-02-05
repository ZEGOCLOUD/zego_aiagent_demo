package im.zego.aiagent.core.controller;

import android.annotation.SuppressLint;
import android.util.Log;
import androidx.annotation.NonNull;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * App 状态监控，用于监控状态和统计各步骤耗时
 */
@SuppressLint("LogNotTimber")
public class ZegoAIAgentMonitor {
    private static final String TAG = "ZegoAIAgentMonitor";
    private static int TRACE_ID_INDEX = 0;

    public enum AppState {
        // App 开启初始化
        AppInit_Start,
        // App 初始化结束
        AppInit_Finish,
        // 请求额外配置
        RequestExtraConfig_Start,
        // 请求额外配置成功
        RequestExtraConfig_Success,
        // 请求额外配置失败
        RequestExtraConfig_Failed,
        // 上传额外配置
        UploadExtraConfig_Start,
        // 上传额外配置成功
        UploadExtraConfig_Success,
        // 上传额外配置失败
        UploadExtraConfig_Failed,
        // 登录业务服务器
        LoginBackendServer_Start,
        // 登陆业务服务器成功
        LoginBackendServer_Success,
        // 登陆业务服务器失败
        LoginBackendServer_Failed,
        // 登录zim
        LoginZIM_Start,
        // 登陆zim成功
        LoginZIM_Success,
        // 登陆zim失败
        LoginZIM_Failed,
        // 跳转消息页面
        JumpToMessageActivity,
        // 收到我的声音 Vad 开始
        VAD_MyVoice_Start,
        // 收到我的声音 Vad 结束
        VAD_MyVoice_Finish,
        // 收到 AI 声音 Vad 开始
        VAD_AIVoice_Start,
        // 收到 AI 声音 Vad 结束
        VAD_AIVoice_Finish,
        // 收到 ASR 文本
        ReceiveASRText,
        // 收到 LLM 文本
        ReceiveLLMText,
        // 发送心跳
        Send_Heartbeat,
        // 选择 LLM
        Select_LLM,
        // 清除 LLM 上下文
        Clean_LLM_Context_Start,
        // 清除 LLM 上下文成功
        Clean_LLM_Context_Success,
        // 清除 LLM 上下文失败
        Clean_LLM_Context_Failed,
        // 离开消息页面
        LeaveMessageActivity,

        // 请求模版
        RequestAgentTemp_Start,
        // 请求模版成功
        RequestAgentTemp_Success,
        // 请求模版失败
        RequestAgentTemp_Failed,

        // 请求会话
        RequestConversation_Start,
        // 请求会话成功
        RequestConversation_Success,
        // 请求会话失败
        RequestConversation_Failed,

        // 创建会话
        BuildConversation_Start,
        // 创建会话成功
        BuildConversation_Success,
        // 创建会话失败
        BuildConversation_Failed,

        RemoveConversation_Start,
        RemoveConversation_Success,
        RemoveConversation_Failed,

        ModifyConversation_Start,
        ModifyConversation_Success,
        ModifyConversation_Failed,

        ResetConversation_Start,
        ResetConversation_Success,
        ResetConversation_Failed,

        BuildTalk_Start,
        BuildTalk_Success,
        BuildTalk_Failed,

        RemoveTalk_Start,
        RemoveTalk_Success,
        RemoveTalk_Failed,

        UploadAgentAvatar_Start,
        UploadAgentAvatar_Success,
        UploadAgentAvatar_Failed,
    }

    public static final HashMap<AppState, AppState[]> sFocusPrevStateMap = new HashMap<>();

    private static final ZegoAIAgentMonitor sInstance = new ZegoAIAgentMonitor();

    private final ArrayList<TraceItem> mTraceHistory = new ArrayList<>();
    private String mTraceID;

    private ZegoAIAgentMonitor() {
        // App 启动耗时
        sFocusPrevStateMap.put(AppState.AppInit_Finish, new AppState[]{AppState.AppInit_Start});
        // 登录业务服务器耗时
        sFocusPrevStateMap.put(AppState.LoginBackendServer_Success, new AppState[]{AppState.LoginBackendServer_Start});
        // 登陆业务服务器耗时
        sFocusPrevStateMap.put(AppState.LoginBackendServer_Failed, new AppState[]{AppState.LoginBackendServer_Start});
        // 登录zim耗时
        sFocusPrevStateMap.put(AppState.LoginZIM_Success, new AppState[]{AppState.LoginZIM_Start});
        // 登陆zim耗时
        sFocusPrevStateMap.put(AppState.LoginZIM_Failed, new AppState[]{AppState.LoginZIM_Start});
        // 我本段语音长度
        sFocusPrevStateMap.put(AppState.VAD_MyVoice_Finish, new AppState[]{AppState.VAD_MyVoice_Start});
        // 1. AI本段语音长度 2.距离我本段语音结束耗时，可以认为是 AI 语音回答总耗时
        sFocusPrevStateMap.put(AppState.VAD_AIVoice_Finish, new AppState[]{AppState.VAD_AIVoice_Start, AppState.VAD_MyVoice_Start});
        // 收到 ASR 文本耗时
        sFocusPrevStateMap.put(AppState.ReceiveASRText, new AppState[]{AppState.VAD_MyVoice_Finish});
        // 收到 LLM 文本耗时
        sFocusPrevStateMap.put(AppState.ReceiveLLMText, new AppState[]{AppState.VAD_MyVoice_Finish});
        // 心跳间距
        sFocusPrevStateMap.put(AppState.Send_Heartbeat, new AppState[]{AppState.Send_Heartbeat});
        // 停留在消息页面总耗时
        sFocusPrevStateMap.put(AppState.LeaveMessageActivity, new AppState[]{AppState.JumpToMessageActivity});
        reset();
    }

    public static ZegoAIAgentMonitor getInstance() {
        return sInstance;
    }

    /**
     * 重置状态，用于重新统计
     */
    public void reset() {
        mTraceID = "android_" + System.currentTimeMillis() + TRACE_ID_INDEX++;
        if (mTraceHistory.size() >= 2) {
            // 重置状态的时候不要丢掉 app init 状态，那个状态只在 app 启动的时候初始化一次
            TraceItem appInitTrace = mTraceHistory.get(0);
            TraceItem appInitFinishTrace = mTraceHistory.get(1);
            if (appInitTrace.state != AppState.AppInit_Start || appInitFinishTrace.state != AppState.AppInit_Finish) {
                throw new IllegalStateException("AppMonitor reset error, first item not app init!");
            }
            mTraceHistory.clear();
            appInitTrace.traceID = mTraceID;
            appInitFinishTrace.traceID = mTraceID;
            mTraceHistory.add(appInitTrace);
            mTraceHistory.add(appInitFinishTrace);
        } else {
            mTraceHistory.clear();
        }
    }

    public String getTraceID() {
        return mTraceID;
    }

    /**
     * 上报状态
     *
     * @param state app 状态
     */
    public void report(AppState state) {
        long currentMS = System.currentTimeMillis();
        TraceItem item = new TraceItem(mTraceID, state, currentMS);
        mTraceHistory.add(item);
        printOne(item);
    }

    /**
     * 打印所有记录
     */
    public void printAll() {
        Log.d(TAG, "============ start, trace count: " + mTraceHistory.size() + " ============");
        for (int i = 0; i < mTraceHistory.size(); i++) {
            printOne(mTraceHistory.get(i));
        }
        Log.d(TAG, "============ finish report ============");
    }

    /**
     * 打印某一条记录
     *
     * @param item 记录
     */
    public void printOne(TraceItem item) {
        AppState[] focusPrevState = sFocusPrevStateMap.get(item.state);
        if (focusPrevState == null || focusPrevState.length == 0) {
            Log.d(TAG, "trace, id: " + mTraceID + ", name: " + item.state.name());
        } else {
            int currentIndex = mTraceHistory.indexOf(item) - 1;
            if (currentIndex < 0) {
                currentIndex = mTraceHistory.size() - 1;
            }
            StringBuilder strBuilder = new StringBuilder();
            for (AppState prevState : focusPrevState) {
                TraceItem prev = findLatestState(prevState, currentIndex);
                if (prev != null) {
                    strBuilder.append("[");
                    strBuilder.append(prev.state.name());
                    strBuilder.append("]->");
                    strBuilder.append(item.timeStampMS - prev.timeStampMS);
                    strBuilder.append("ms; ");
                }
            }
            if (strBuilder.length() == 0) {
                strBuilder.append("no prev state");
            }
            Log.d(TAG, "trace, id: " + mTraceID + ", name: " + item.state.name() + ", cost: " + strBuilder);
        }
    }

    /**
     * 查找最新的某个状态记录
     *
     * @param state 状态
     * @return 状态记录
     */
    public TraceItem findLatestState(AppState state) {
        return findLatestState(state, mTraceHistory.size() - 1);
    }

    /**
     * 查找最新的某个状态记录
     *
     * @param state 状态
     * @param index 从哪个 index 开始往回找
     * @return 状态记录
     */
    public TraceItem findLatestState(AppState state, int index) {
        for (int i = index; i >= 0; i--) {
            if (mTraceHistory.get(i).state == state) {
                return mTraceHistory.get(i);
            }
        }
        return null;
    }

    public static class TraceItem {
        public String traceID;
        public AppState state;
        public long timeStampMS;

        public TraceItem(String traceID, AppState state, long timeStampMS) {
            this.traceID = traceID;
            this.state = state;
            this.timeStampMS = timeStampMS;
        }

        @NonNull
        @Override
        public String toString() {
            return "id: " + traceID + ", " + state.name();
        }
    }
}
