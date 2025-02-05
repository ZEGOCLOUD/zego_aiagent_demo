package im.zego.aiagent.core.widget;

import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.squareup.picasso.Picasso;
import im.zego.aiagent.R;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.CustomAgentConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.CharacterConfig;
import im.zego.aiagent.core.net.ZegoBackendServerAPI;
import im.zego.aiagent.core.utils.ToastUtils;
import im.zego.aiagent.core.utils.Utils;
import java.util.ArrayList;

/**
 * 选择 TTS window
 */
public class ZegoSwitchTTSWindow {

    private static final String PLACEHOLDER_ID = "local_fake";

    private final View mParentView;
    private PopupWindow mMainPopupWindow;
    private PopupWindow mTTSChoosePopWindow;
    private ImageView mTTSIcon;
    private TextView mTTSTextView;
    //    private ConstraintLayout mLanguagePanel;
    private ConstraintLayout mVoicePanel;
    //    private final ArrayList<ButtonView> mLanguageButtonViews = new ArrayList<>();
    //    private final ArrayList<ButtonView> mVoiceButtonViews = new ArrayList<>();
    //    private final LanguageButtonGroupModel mLanguageButtonGroupModel = new LanguageButtonGroupModel();
    private final VoiceButtonGroupModel mVoiceButtonGroupModel = new VoiceButtonGroupModel();
    private ZegoAIAgentConfigController.TTSConfig mTTSConfig;

    //    private ZegoAIAgentConfigController.CharacterConfig mCharacterConfig;
    private int mMode = 0;  // 1 create, 0 modify,

    public static int MODE_CREATE = 1;
    public static int MODE_EDIT = 0;

    private PopupWindow.OnDismissListener mDismissListener;

    public ZegoSwitchTTSWindow(View parentView) {
        mParentView = parentView;
    }

    public void setDismissListener(PopupWindow.OnDismissListener l) {
        mDismissListener = l;
    }

    public void show(int mode) {
        mMode = mode;
        initData();
        showMainWindow();
        refreshMainWindowUI();
        mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
    }

    public void show() {
        mMode = 0;
        initData();
        showMainWindow();
        refreshMainWindowUI();
        //        mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
        mMainPopupWindow.showAtLocation(mParentView, Gravity.BOTTOM, 0, 0);
    }

    public void hide() {
        mMainPopupWindow.dismiss();
        mMainPopupWindow = null;
        //        mLanguagePanel = null;
        mVoicePanel = null;
        mTTSIcon = null;
        mTTSTextView = null;
        //        mLanguageButtonViews.clear();
        //        mVoiceButtonViews.clear();
        if (mTTSChoosePopWindow != null) {
            mTTSChoosePopWindow.dismiss();
            mTTSChoosePopWindow = null;
        }
    }

    private void initData() {
        mTTSConfig = ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.getCurrentTTSConfig();
    }

    /**
     * 打开主设置页面
     */
    private void showMainWindow() {
        View window = LayoutInflater.from(mParentView.getContext()).inflate(R.layout.window_tts_settings, null, false);
        mMainPopupWindow = new PopupWindow(window, ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT, true);
        mMainPopupWindow.setTouchable(true);
        //        mMainPopupWindow.setBackgroundDrawable(new ColorDrawable(0x66000000));

        // 保存按钮
        window.findViewById(R.id.save).setOnClickListener(v -> {
            hide();

            if (mMode == 0) { //编辑模式的时候才 更新
                // 这里成功了再更新
                ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
                    .getCurrentCharacter();
                CharacterConfig clonedCharacterConfig = characterConfig.clone();
                clonedCharacterConfig.cur_config.updateData(ZegoAIAgentConfigController.ExtraConfigType.TTS,
                    mTTSConfig.id);
                clonedCharacterConfig.cur_config.updateData(ZegoAIAgentConfigController.ExtraConfigType.VOICE,
                    mVoiceButtonGroupModel.selectedButtonInfoID);
                CustomAgentConfig pendingConfig = CustomAgentConfig.createFromCharacter(clonedCharacterConfig);


                if (characterConfig.conversationId != null) {
                    ZegoBackendServerAPI.updateConversation(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, characterConfig.templateID,
                        pendingConfig, new AIAgentCommonCallBack<Void>() {
                            @Override
                            public void onCallback(int errorCode, String message, Void unused) {
                                if (errorCode == 0) {
                                    ZegoAIAgentConfigController.AppCurrentExtraConfig currentExtraConfig = ZegoAIAgentConfigController.getConfig()
                                        .getCurrentCharacter().cur_config;
                                    currentExtraConfig.updateData(ZegoAIAgentConfigController.ExtraConfigType.TTS,
                                        mTTSConfig.id);
                                    currentExtraConfig.updateData(ZegoAIAgentConfigController.ExtraConfigType.VOICE,
                                        mVoiceButtonGroupModel.selectedButtonInfoID);
                                } else {
                                    ToastUtils.show("保存失败,errorCode:" + errorCode + ",message:" + message);
                                }
                            }
                        });
                } else {
                    ToastUtils.show("保存失败，会话不存在");
                }
            } else {
                ZegoAIAgentConfigController.AppCurrentExtraConfig currentExtraConfig = ZegoAIAgentConfigController.getConfig()
                    .getCurrentCharacter().cur_config;
                currentExtraConfig.updateData(ZegoAIAgentConfigController.ExtraConfigType.TTS,
                    mTTSConfig.id);
                currentExtraConfig.updateData(ZegoAIAgentConfigController.ExtraConfigType.VOICE,
                    mVoiceButtonGroupModel.selectedButtonInfoID);
            }

            if (mDismissListener != null) {
                mDismissListener.onDismiss();
            }
        });
        // 返回按钮
        window.findViewById(R.id.cancel).setOnClickListener(v -> hide());
        // 点击空白区域隐藏
        window.findViewById(R.id.empty_panel).setOnClickListener(v -> hide());

        //        mLanguagePanel = window.findViewById(R.id.panel_language);
        mVoicePanel = window.findViewById(R.id.panel_timbre);
        window.findViewById(R.id.tts_name).setOnClickListener(v -> showTTSChooseWindow(mTTSConfig));
        window.findViewById(R.id.icon_arrow).setOnClickListener(v -> showTTSChooseWindow(mTTSConfig));
        window.findViewById(R.id.tts_icon).setOnClickListener(v -> showTTSChooseWindow(mTTSConfig));
        mTTSIcon = window.findViewById(R.id.tts_icon);
        mTTSTextView = window.findViewById(R.id.tts_name);
    }

    /**
     * 打开 tts 选择页面
     */
    private void showTTSChooseWindow(ZegoAIAgentConfigController.TTSConfig selectedTTSConfig) {
        mMainPopupWindow.dismiss();
        if (mTTSChoosePopWindow != null) {
            mTTSChoosePopWindow.dismiss();
        }
        View window = LayoutInflater.from(mParentView.getContext()).inflate(R.layout.window_tts_choose, null, false);
        mTTSChoosePopWindow = new PopupWindow(window, ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT, true);
        mTTSChoosePopWindow.setTouchable(true);
        //        mTTSChoosePopWindow.setBackgroundDrawable(new ColorDrawable(0x66000000));
        mTTSChoosePopWindow.showAsDropDown(mParentView, 0, 0);

        // 点击空白区域隐藏面板
        window.findViewById(R.id.empty_panel).setOnClickListener(v -> hide());

        LinearLayout ttsContainer = window.findViewById(R.id.panel_tts);
        ZegoAIAgentConfigController.TTSConfig[] ttsConfigs = ZegoAIAgentConfigController.getConfig().tts_list;
        for (int i = 0; i < ttsConfigs.length; i++) {
            ZegoAIAgentConfigController.TTSConfig ttsConfig = ttsConfigs[i];
            View subView = LayoutInflater.from(mParentView.getContext())
                .inflate(R.layout.window_item_tts_choose, null, false);

            Picasso.get().load(ttsConfig.icon).fit().centerCrop().into((ImageView) subView.findViewById(R.id.icon_tts));
            ((TextView) subView.findViewById(R.id.text_tts)).setText(ttsConfig.name);
            if (selectedTTSConfig.id.equals(ttsConfig.id)) {
                subView.findViewById(R.id.icon_selected).setVisibility(View.VISIBLE);
            } else {
                subView.findViewById(R.id.icon_selected).setVisibility(View.GONE);
            }

            subView.setOnClickListener(v -> {
                // 设置当前选中的 tts
                mTTSConfig = ttsConfig;

                // 刷新按钮选中状态
                for (int j = 0; j < ttsConfigs.length; j++) {
                    View sub = ttsContainer.getChildAt(j);
                    ZegoAIAgentConfigController.TTSConfig tc = ttsConfigs[j];
                    if (tc.id.equals(mTTSConfig.id)) {
                        sub.findViewById(R.id.icon_selected).setVisibility(View.VISIBLE);
                    } else {
                        sub.findViewById(R.id.icon_selected).setVisibility(View.GONE);
                    }
                }

                // 刷新主页面 UI
                if (mTTSConfig.isSelected()) {
                    // 没改 tts，tts 和 AppSettings.getConfig().cur_config 的一致，则用 cur_config 刷 UI
                    refreshMainWindowUI();
                } else {
                    // 改了 tts，voice/language 设置第一个值为默认值
                    refreshMainWindowUI(mTTSConfig, mTTSConfig.voice_list[0]);
                    //                    refreshMainWindowUI(mTTSConfig, mTTSConfig.voice_list[0], mTTSConfig.voice_list[0].language[0]);
                }
                mTTSChoosePopWindow.dismiss();
                mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
            });
            ttsContainer.addView(subView, i);
        }

        window.findViewById(R.id.icon_back).setOnClickListener(v -> {
            mTTSChoosePopWindow.dismiss();
            mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
        });
    }

    /**
     * 用默认配置刷新主 UI
     */
    private void refreshMainWindowUI() {
        refreshMainWindowUI(
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.getCurrentTTSConfig(),
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.getCurrentVoiceConfig());
        //                ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.getCurrentLanguageConfig());
    }

    /**
     * 用指定配置刷新主 UI
     *
     * @param ttsConfig   当前选中的 tts 配置
     * @param voiceConfig 当前选中的音色配置
     */
    private void refreshMainWindowUI(ZegoAIAgentConfigController.TTSConfig ttsConfig,
        ZegoAIAgentConfigController.VoiceConfig voiceConfig) {//, ZegoAIAgentConfigController.LanguageConfig languageConfig) {
        // 刷新 TTS
        mTTSTextView.setText(ttsConfig.name);
        Picasso.get().load(ttsConfig.icon).fit().centerCrop().into(mTTSIcon);
        // 刷新 language
        //        mLanguageButtonGroupModel.refresh(voiceConfig);
        //        mLanguageButtonGroupModel.select(languageConfig.id);
        //        inflateButtonList(mLanguagePanel, mLanguageButtonGroupModel, mLanguageButtonViews, true);
        // 刷新 voice
        mVoiceButtonGroupModel.refresh(null);
        mVoiceButtonGroupModel.select(voiceConfig.id);
        inflateButtonList(mVoicePanel, mVoiceButtonGroupModel, false);
    }

    /**
     * 填充主 UI 里面的 button 列表
     *
     * @param parentLayout    父布局
     * @param model           数据层 //     * @param buttonViews     生成的 button view 列表
     * @param isLanguagePanel 是否是 language panel
     */
    private void inflateButtonList(ConstraintLayout parentLayout, BaseButtonGroupModel model, boolean isLanguagePanel) {
        // 清空旧数据
        parentLayout.removeAllViews();

        int marginTop = Utils.dp2px(13f, mParentView.getResources().getDisplayMetrics());
        int buttonHeight = Utils.dp2px(44f, mParentView.getResources().getDisplayMetrics());
        int marginHorizontal = Utils.dp2px(6f, mParentView.getResources().getDisplayMetrics());

        // 使用 RecyclerView 代替 ConstraintLayout
        RecyclerView recyclerView = new RecyclerView(parentLayout.getContext());
        recyclerView.setLayoutManager(new GridLayoutManager(parentLayout.getContext(), 2));
        ButtonAdapter adapter = new ButtonAdapter(model, buttonHeight, isLanguagePanel);
        recyclerView.setAdapter(adapter);

        // 添加自定义的ItemDecoration来实现按钮间距
        recyclerView.addItemDecoration(new ButtonItemDecoration(marginTop, marginHorizontal));

        // 设置RecyclerView的布局参数
        ConstraintLayout.LayoutParams layoutParams = new ConstraintLayout.LayoutParams(
            ConstraintLayout.LayoutParams.MATCH_PARENT, ConstraintLayout.LayoutParams.WRAP_CONTENT);
        //        layoutParams.setMargins(marginHorizontal, marginTop, marginHorizontal, marginTop);
        recyclerView.setLayoutParams(layoutParams);
        parentLayout.addView(recyclerView);
    }

    // 自定义的ItemDecoration，设置按钮的水平和垂直间距
    public static class ButtonItemDecoration extends RecyclerView.ItemDecoration {

        private final int marginTop;
        private final int marginHorizontal;

        public ButtonItemDecoration(int marginTop, int marginHorizontal) {
            this.marginTop = marginTop;
            this.marginHorizontal = marginHorizontal;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);

            // 设置垂直间距（仅在第一行以上的按钮需要）
            if (position >= 2) {
                outRect.top = marginTop;
            }

            // 设置水平间距
            if (position % 2 == 0) { // 左侧按钮
                outRect.right = marginHorizontal / 2;
            } else { // 右侧按钮
                outRect.left = marginHorizontal / 2;
            }
        }
    }

    // RecyclerView Adapter
    public class ButtonAdapter extends RecyclerView.Adapter<ButtonAdapter.ButtonViewHolder> {

        private final BaseButtonGroupModel model;
        private final int buttonHeight;
        private final boolean isLanguagePanel;

        public ButtonAdapter(BaseButtonGroupModel model, int buttonHeight, boolean isLanguagePanel) {
            this.model = model;
            this.buttonHeight = buttonHeight;
            this.isLanguagePanel = isLanguagePanel;
        }

        @NonNull
        @Override
        public ButtonViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            TextView buttonView = new TextView(parent.getContext());
            buttonView.setGravity(Gravity.CENTER);
            buttonView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f);

            // 设置按钮的高度
            RecyclerView.LayoutParams params = new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                buttonHeight);
            buttonView.setLayoutParams(params);
            return new ButtonViewHolder(buttonView);
        }

        @Override
        public void onBindViewHolder(ButtonViewHolder holder, int position) {
            ButtonInfo buttonInfo = model.buttonInfoList.get(position);
            holder.bind(buttonInfo, model.isButtonSelected(buttonInfo));

            holder.itemView.setOnClickListener(v -> {
                model.select(buttonInfo.id);
                if (isLanguagePanel) {
                    mVoiceButtonGroupModel.refresh(buttonInfo.id);
                } else {
                    ZegoAIAgentConfigController.TTSConfig ttsConfig = ZegoAIAgentConfigController.getConfig()
                        .getCurrentCharacter().cur_config.getCurrentTTSConfig();
                    for (ZegoAIAgentConfigController.VoiceConfig voiceConfig : ttsConfig.voice_list) {
                        if (voiceConfig.id.equals(buttonInfo.id)) {
                            break;
                        }
                    }
                }
                notifyDataSetChanged();
                //                refreshStyleVoiceButtonList();
            });
        }

        @Override
        public int getItemCount() {
            return model.buttonInfoList.size();
        }

        public class ButtonViewHolder extends RecyclerView.ViewHolder {

            private final TextView mView;

            public ButtonViewHolder(View itemView) {
                super(itemView);
                mView = (TextView) itemView;
            }

            public void bind(ButtonInfo buttonInfo, boolean isSelected) {
                mView.setText(buttonInfo.name);
                changeStyle(isSelected);
            }

            private void changeStyle(boolean isSelected) {
                if (isSelected) {
                    mView.setTextColor(Color.parseColor("#0055FF"));
                    mView.setBackgroundResource(R.drawable.rounded_tts_button_selected);
                    mView.setTypeface(null, Typeface.BOLD);
                } else {
                    mView.setTextColor(Color.parseColor("#000000"));
                    mView.setBackgroundResource(R.drawable.rounded_tts_button_unselected);
                    mView.setTypeface(null, Typeface.NORMAL);
                }
            }
        }
    }

    private static class BaseButtonGroupModel {

        protected ArrayList<ButtonInfo> buttonInfoList = new ArrayList<>();
        protected String selectedButtonInfoID;
        protected ButtonInfo selectedButtonInfo;

        public ArrayList<ButtonInfo> getButtonInfoList() {
            return buttonInfoList;
        }

        public void select(String buttonID) {
            selectedButtonInfoID = buttonID;

            for (ButtonInfo info : buttonInfoList) {
                if (isButtonSelected(info)) {
                    selectedButtonInfo = info;
                    break;
                }
            }
        }

        public boolean isButtonSelected(ButtonInfo button) {
            if (selectedButtonInfoID == null) {
                return false;
            }
            return selectedButtonInfoID.equals(button.id);
        }
    }

    private static class LanguageButtonGroupModel extends BaseButtonGroupModel {

        public void refresh(ZegoAIAgentConfigController.VoiceConfig voiceConfig) {
            buttonInfoList.clear();
            for (int i = 0; i < voiceConfig.language.length; i++) {
                ZegoAIAgentConfigController.LanguageConfig languageConfig = voiceConfig.language[i];
                ButtonInfo buttonInfo = new ButtonInfo(languageConfig.id, i, languageConfig.name);
                buttonInfoList.add(buttonInfo);
            }
        }
    }

    private class VoiceButtonGroupModel extends BaseButtonGroupModel {

        public void refresh(String languageConfigID) {
            buttonInfoList.clear();
            ZegoAIAgentConfigController.TTSConfig ttsConfig = mTTSConfig;
            for (int i = 0; i < ttsConfig.voice_list.length; i++) {
                ZegoAIAgentConfigController.VoiceConfig voiceConfig = ttsConfig.voice_list[i];
                //                ZegoAIAgentConfigController.LanguageConfig[] languageConfigList = voiceConfig.language;
                //                boolean findLanguage = false;
                //                for (ZegoAIAgentConfigController.LanguageConfig l : languageConfigList) {
                //                    if (l.id.equals(languageConfigID)) {
                //                        findLanguage = true;
                //                        break;
                //                    }
                //                }
                //                if (findLanguage) {
                //                    ButtonInfo buttonInfo = new ButtonInfo(voiceConfig.id, i, voiceConfig.name);
                //                    buttonInfoList.add(buttonInfo);
                //                }
                ButtonInfo buttonInfo = new ButtonInfo(voiceConfig.id, i, voiceConfig.name);
                buttonInfoList.add(buttonInfo);
            }
        }
    }

    public static class ButtonInfo {

        public String id;
        public int index;
        public String name;

        public ButtonInfo(String id, int index, String name) {
            this.id = id;
            this.index = index;
            this.name = name;
        }
    }
}
