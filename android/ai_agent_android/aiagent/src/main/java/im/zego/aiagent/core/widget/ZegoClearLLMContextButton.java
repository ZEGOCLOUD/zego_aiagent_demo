package im.zego.aiagent.core.widget;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.ui.ZegoAgentConfigActivity;
import im.zego.aiagent.core.utils.ToastUtils;

/**
 * 清理 LLM 上下文按钮，清理成功后会往当前聊天页面注入本地系统消息
 */
public class ZegoClearLLMContextButton extends FrameLayout {

    TextView mSettingView;
    TextView mCleanView;
    ZegoAIAgentConfigController.CharacterConfig mCharacterConfig;
    String TAG = "ZegoClearLLMContextButton";

    public ZegoClearLLMContextButton(Context context) {
        super(context);
    }

    public void init(String conversationID, PopupWindow popupWindow) {
        LayoutInflater.from(getContext()).inflate(R.layout.window_clean_context, this, true);
        mSettingView = findViewById(R.id.icon_settings_txt);
        mCleanView = findViewById(R.id.icon_clean_txt);
        mCharacterConfig = ZegoAIAgentConfigController.getConfig().getCurrentCharacter();
        mSettingView.setOnClickListener(view -> {
            ZegoAgentConfigActivity.editAIAgent((Activity) getContext());
            popupWindow.dismiss();
        });

        // 点击清除上下文
        mCleanView.setOnClickListener(v2 -> {
            ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.Clean_LLM_Context_Start);
            popupWindow.dismiss();

            ZegoAIAgentRequest.requestResetConversationMsg(new CommonCallBack() {
                @Override
                public void onSuccess(Object data) {
                    sendZIMLocalSystemMessage("开启新话题", conversationID, new CommonCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.Clean_LLM_Context_Success);
                        }

                        @Override
                        public void onFailed(int errorCode, String errorMsg) {
                            ToastUtils.show("清除上下文失败1: " + errorMsg);
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.Clean_LLM_Context_Failed);
                        }
                    });
                }

                @Override
                public void onFailed(int errorCode, String errorMsg) {
                    ToastUtils.show("清除上下文失败2: " + errorCode + ", " + errorMsg);
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.Clean_LLM_Context_Failed);
                }
            });
        });
    }

    /**
     * 发送 zim 本地系统消息
     *
     * @param text           消息文本
     * @param conversationID 会话 ID
     * @param cb             发送回调
     */
    private void sendZIMLocalSystemMessage(String text, String conversationID, CommonCallBack cb) {
        ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
        if (imProxy != null) {
            imProxy.sendZIMLocalSystemMessage(text, conversationID, cb);
        }
    }
}
