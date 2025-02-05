package im.zego.aiagent.core.widget;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.Nullable;
import com.squareup.picasso.Picasso;
import im.zego.aiagent.R;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.CustomAgentConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.CharacterConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.ExtraConfigType;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.net.ZegoBackendServerAPI;
import im.zego.aiagent.core.utils.ToastUtils;
import im.zego.aiagent.core.utils.Utils;
import java.lang.ref.WeakReference;

/**
 * 选择大模型按钮以及相关的 window
 */
public class ZegoSwitchLLMButton extends FrameLayout implements ZegoAIAgentConfigController.ConfigDataObserver {

    private ImageView mLLMIconImage;
    private TextView mLLMNameTextView;
    private PopupWindow mPopupWindow;

    public ZegoSwitchLLMButton(Context context) {
        super(context);
        init();
    }

    public ZegoSwitchLLMButton(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        LayoutInflater.from(getContext()).inflate(R.layout.widget_switch_llm_button, this, true);
        mLLMIconImage = findViewById(R.id.llm_icon);
        mLLMNameTextView = findViewById(R.id.llm_text);
        setOnClickListener(v -> {
            showSettingsWindow();
        });
        ZegoAIAgentConfigController.AppCurrentExtraConfig currentExtraConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter().cur_config;
        currentExtraConfig.addDataChangedObserver(new WeakReference<>(this));
        refreshButtonUI();
    }

    /**
     * 根据 llm 信息刷新 button ui
     */
    private void refreshButtonUI() {
        ZegoAIAgentConfigController.AppCurrentExtraConfig currentExtraConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter().cur_config;
        ZegoAIAgentConfigController.LLMConfig currentLLMConfig = currentExtraConfig.getCurrentLLMConfig();
        if (currentLLMConfig != null) {
            Picasso.get().load(currentLLMConfig.icon).fit().centerCrop().into(mLLMIconImage);
            mLLMNameTextView.setText(currentLLMConfig.name);
        } else {
            mLLMNameTextView.setText("未设置");
        }
    }

    private void showSettingsWindow() {
        View view = LayoutInflater.from(getContext()).inflate(R.layout.window_llm_settings, null, false);
        LinearLayout llmList = view.findViewById(R.id.llm_list);
        ZegoAIAgentConfigController.LLMConfig[] llmConfigs = ZegoAIAgentConfigController.getConfig().llm_list;
        for (int i = 0; i < llmConfigs.length; i++) {
            ZegoAIAgentConfigController.LLMConfig llmInfo = llmConfigs[i];

            // 创建 view
            View llmItemView = LayoutInflater.from(getContext())
                .inflate(R.layout.window_item_llm_settings, null, false);
            llmItemView.setTag(R.id.llm_icon, llmItemView.findViewById(R.id.llm_icon));
            llmItemView.setTag(R.id.llm_text, llmItemView.findViewById(R.id.llm_text));
            llmItemView.setTag(R.id.icon_chose, llmItemView.findViewById(R.id.icon_chose));
            llmItemView.setTag(R.id.icon_coming, llmItemView.findViewById(R.id.icon_coming));
            llmItemView.setTag(R.id.divider, llmItemView.findViewById(R.id.divider));
            llmItemView.setTag(llmInfo);
            llmList.addView(llmItemView);

            // 刷新状态
            Picasso.get().load(llmInfo.icon).fit().centerCrop().into((ImageView) llmItemView.getTag(R.id.llm_icon));
            ((TextView) llmItemView.getTag(R.id.llm_text)).setText(llmInfo.name);
            if (llmInfo.isSelected()) {
                ((ImageView) llmItemView.getTag(R.id.icon_chose)).setVisibility(View.VISIBLE);
                ((ImageView) llmItemView.getTag(R.id.icon_coming)).setVisibility(View.GONE);
            } else if (!llmInfo.is_supported) {
                ((ImageView) llmItemView.getTag(R.id.icon_chose)).setVisibility(View.GONE);
                ((ImageView) llmItemView.getTag(R.id.icon_coming)).setVisibility(View.VISIBLE);
            } else {
                ((ImageView) llmItemView.getTag(R.id.icon_chose)).setVisibility(View.GONE);
                ((ImageView) llmItemView.getTag(R.id.icon_coming)).setVisibility(View.GONE);
            }

            // 监听点击
            llmItemView.setOnClickListener(v -> {
                ZegoAIAgentConfigController.LLMConfig clickLLMInfo = (ZegoAIAgentConfigController.LLMConfig) llmItemView.getTag();
                if (clickLLMInfo.isSelected()) {
                    return;
                }
                if (!clickLLMInfo.is_supported) {
                    ToastUtils.show("更新LLM 失败，暂不支持此LLM");
                    return;
                }
                if (TextUtils.isEmpty(clickLLMInfo.raw_properties.Type) || TextUtils.isEmpty(
                    clickLLMInfo.raw_properties.Model)) {
                    ToastUtils.show("更新LLM 失败，请检查此LLM参数");
                    return;
                }

                for (int j = 0; j < llmList.getChildCount(); j++) {
                    View subView = llmList.getChildAt(j);
                    ZegoAIAgentConfigController.LLMConfig subLLMInfo = (ZegoAIAgentConfigController.LLMConfig) subView.getTag();
                    if (subLLMInfo == clickLLMInfo) {
                        ((ImageView) subView.getTag(R.id.icon_chose)).setVisibility(View.VISIBLE);
                    } else if (subLLMInfo.isSelected()) {
                        ((ImageView) subView.getTag(R.id.icon_chose)).setVisibility(View.GONE);
                    }
                }

                // 这里成功了再更新
                ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig().getCurrentCharacter();
                CharacterConfig clonedCharacterConfig = characterConfig.clone();
                clonedCharacterConfig.cur_config.updateData(ExtraConfigType.LLM, clickLLMInfo.id);
                CustomAgentConfig pendingConfig = CustomAgentConfig.createFromCharacter(clonedCharacterConfig);

                if (characterConfig.conversationId != null) {
                    ZegoBackendServerAPI.updateConversation(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, characterConfig.templateID,
                        pendingConfig, new AIAgentCommonCallBack<Void>() {
                            @Override
                            public void onCallback(int errorCode, String message, Void unused) {
                                if (errorCode == 0) {
                                    clickLLMInfo.select();
                                    refreshButtonUI();
                                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.Select_LLM);
                                    mPopupWindow.dismiss();
                                } else {
                                    ToastUtils.show("更新LLM 失败，errorCode:" + errorCode + ",message:" + message);
                                }
                            }
                        });
                } else {
                    ToastUtils.show("更新LLM 失败，会话不存在");
                }

            });

            // 分割线
            if (i == ZegoAIAgentConfigController.getConfig().llm_list.length - 1) {
                llmItemView.findViewById(R.id.divider).setVisibility(View.GONE);
            } else {
                llmItemView.findViewById(R.id.divider).setVisibility(View.VISIBLE);
            }
        }

        mPopupWindow = new PopupWindow(view, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT,
            true);
        mPopupWindow.setTouchable(true);
        mPopupWindow.setBackgroundDrawable(new ColorDrawable(0x00000000));    //要为popWindow设置一个背景才有效
        mPopupWindow.showAsDropDown(ZegoSwitchLLMButton.this, 0, Utils.dp2px(17f, getResources().getDisplayMetrics()));
    }

    private static final String TAG = "ZegoSwitchLLMButton";

    @Override
    public void onAppExtraConfigChanged(ZegoAIAgentConfigController.ExtraConfigType type, String newData,
        String oldData) {
        if (type != ZegoAIAgentConfigController.ExtraConfigType.LLM) {
            return;
        }
        refreshButtonUI();
    }
}
