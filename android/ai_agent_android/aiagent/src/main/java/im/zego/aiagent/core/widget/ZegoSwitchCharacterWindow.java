package im.zego.aiagent.core.widget;

import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import com.squareup.picasso.Picasso;
import im.zego.aiagent.R;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.utils.Utils;
import java.util.ArrayList;

/**
 * 选择角色 window
 */
public class ZegoSwitchCharacterWindow {

    private static final String PLACEHOLDER_ID = "local_fake";
    private final View mParentView;
    private final ZegoAIAgentConfigController.CharacterConfig[] mCharacterList;
    private PopupWindow mMainPopupWindow;
    private CharacterButtonGroupModel mModel;
    private final ArrayList<ButtonView> mButtonViewList = new ArrayList<>();
    private CharacterSelectListener mListener;


    public ZegoSwitchCharacterWindow(View parentView, ZegoAIAgentConfigController.CharacterConfig[] characterList) {
        mParentView = parentView;
        mCharacterList = characterList;
    }

    public void show(CharacterSelectListener listener) {
        mListener = listener;
        mModel = new CharacterButtonGroupModel(mCharacterList);

        View window = LayoutInflater.from(mParentView.getContext())
            .inflate(R.layout.window_character_choose, null, false);
        ConstraintLayout layout = window.findViewById(R.id.panel_character);
        inflateButtonList(layout, mModel, mButtonViewList);
        // 点击空白区域关掉选框
        window.findViewById(R.id.empty_panel).setOnClickListener(v -> {
            hide();
        });
        // 保存按钮
        window.findViewById(R.id.ok).setOnClickListener(v -> {
            for (ZegoAIAgentConfigController.CharacterConfig characterConfig : mCharacterList) {
                if (characterConfig.templateID.equals(mModel.selectedButtonInfoID)) {
                    mListener.OnCharacterSelected(characterConfig);
                    break;
                }
            }
            hide();
        });

        mMainPopupWindow = new PopupWindow(window,
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
        mMainPopupWindow.setTouchable(true);
        mMainPopupWindow.setBackgroundDrawable(new ColorDrawable(0x00000000));
        mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
    }

    public void hide() {
        mMainPopupWindow.dismiss();
        mMainPopupWindow = null;
        mListener = null;
        mButtonViewList.clear();
    }

    /**
     * 填充主 UI 里面的 button 列表
     *
     * @param parentLayout 父布局
     * @param model        数据层
     * @param buttonViews  生成的 button view 列表
     */
    private void inflateButtonList(ConstraintLayout parentLayout, CharacterButtonGroupModel model,
        ArrayList<ButtonView> buttonViews) {
        // 清空旧数据
        buttonViews.clear();
        parentLayout.removeAllViews();

        int buttonCount = model.buttonInfoList.size();
        // 是否添加空 View，ConstraintLayout 一行两个元素平均沾满宽度，所以如果是奇数个按钮则需要添加一个空 View
        if (buttonCount % 2 == 1) {
            buttonCount++;
            model.buttonInfoList.add(new ButtonInfo(PLACEHOLDER_ID, buttonCount - 1, null));
        }

        // 创建按钮
        for (int i = 0; i < buttonCount; i++) {
            ButtonInfo buttonInfo = model.buttonInfoList.get(i);
            ButtonView buttonView = new ButtonView(parentLayout, mModel, buttonInfo);
            // 设置选择态
            buttonView.changeStyle(model.isButtonSelected(buttonInfo));
            // placeholder 不可见
            if (i == buttonCount - 1 && PLACEHOLDER_ID.equals(buttonInfo.id)) {
                buttonView.setVisibility(View.INVISIBLE);
            } else {
                buttonView.setVisibility(View.VISIBLE);
            }
            // 监听点击事件
            buttonView.setOnClickListener(v -> {
                model.select(buttonInfo.id);
                inflateButtonList(parentLayout, model, buttonViews);
            });
            buttonViews.add(buttonView);
        }
        // layout
        ConstraintSet constraintSet = new ConstraintSet();
        constraintSet.clone(parentLayout);
        for (int i = 0; i < buttonCount; i++) {
            ButtonView buttonView = buttonViews.get(i);
            int viewID = buttonView.mView.getId();

            constraintSet.constrainWidth(viewID, Utils.dp2px(150f, mParentView.getResources().getDisplayMetrics()));
            constraintSet.constrainHeight(viewID, Utils.dp2px(147f, mParentView.getResources().getDisplayMetrics()));
            // set top
            if (i >= 2) {
                View topView = buttonViews.get(i - 2).mView;
                constraintSet.connect(viewID, ConstraintSet.TOP, topView.getId(), ConstraintSet.BOTTOM);
                constraintSet.setMargin(viewID, ConstraintSet.TOP,
                    Utils.dp2px(13f, mParentView.getResources().getDisplayMetrics()));
            } else {
                constraintSet.connect(viewID, ConstraintSet.TOP, parentLayout.getId(), ConstraintSet.TOP);
            }
            // set bottom
            if (i < buttonCount - 2) {
                View bottomView = buttonViews.get(i + 2).mView;
                constraintSet.connect(viewID, ConstraintSet.BOTTOM, bottomView.getId(), ConstraintSet.TOP);
            } else {
                constraintSet.connect(viewID, ConstraintSet.BOTTOM, parentLayout.getId(), ConstraintSet.BOTTOM);
            }
            if (i % 2 == 0) {
                // set right
                View rightView = buttonViews.get(i + 1).mView;
                constraintSet.connect(viewID, ConstraintSet.RIGHT, rightView.getId(), ConstraintSet.LEFT);
                constraintSet.connect(viewID, ConstraintSet.LEFT, parentLayout.getId(), ConstraintSet.LEFT);
                constraintSet.setMargin(viewID, ConstraintSet.RIGHT,
                    Utils.dp2px(6f, mParentView.getResources().getDisplayMetrics()));
            } else {
                // set left
                View leftView = buttonViews.get(i - 1).mView;
                constraintSet.connect(viewID, ConstraintSet.LEFT, leftView.getId(), ConstraintSet.RIGHT);
                constraintSet.connect(viewID, ConstraintSet.RIGHT, parentLayout.getId(), ConstraintSet.RIGHT);
                constraintSet.setMargin(viewID, ConstraintSet.LEFT,
                    Utils.dp2px(6f, mParentView.getResources().getDisplayMetrics()));
            }
        }
        constraintSet.applyTo(parentLayout);
    }

    /**
     * 负责单个按钮的显示样式
     */
    private static class ButtonView {

        private final View mView;
        private final View mBgView;

        private ButtonView(ConstraintLayout parentView, CharacterButtonGroupModel model, ButtonInfo buttonInfo) {
            mView = LayoutInflater.from(parentView.getContext()).inflate(R.layout.window_character_item, null, false);
            mView.setId(buttonInfo.index);
            mBgView = mView.findViewById(R.id.background);
            ImageView iconView = mView.findViewById(R.id.icon);
            Picasso.get().load(buttonInfo.icon).fit().centerCrop().into(iconView);
            parentView.addView(mView);
            changeStyle(model.isButtonSelected(buttonInfo));
        }

        public void changeStyle(boolean isSelect) {
            if (isSelect) {
                mBgView.setBackgroundResource(R.drawable.rounded_character_selected);
            } else {
                mBgView.setBackgroundResource(R.drawable.rounded_character_unselected);
            }
        }

        public void setVisibility(int visibility) {
            mView.setVisibility(visibility);
        }

        public void setOnClickListener(View.OnClickListener listener) {
            mView.setOnClickListener(listener);
        }
    }

    private static class CharacterButtonGroupModel {

        protected ArrayList<ButtonInfo> buttonInfoList = new ArrayList<>();
        protected String selectedButtonInfoID;

        public CharacterButtonGroupModel(ZegoAIAgentConfigController.CharacterConfig[] characterList) {
            for (int i = 0; i < characterList.length; i++) {
                if (characterList[i].templateID.equals(
                    ZegoAIAgentConfigController.getConfig().getCurrentCharacter().templateID)) {
                    selectedButtonInfoID = characterList[i].templateID;
                }
                buttonInfoList.add(new ButtonInfo(characterList[i].templateID, i, characterList[i].getEntry()));
            }
        }

        public void select(String buttonID) {
            selectedButtonInfoID = buttonID;
        }

        public boolean isButtonSelected(ButtonInfo button) {
            if (selectedButtonInfoID == null) {
                return false;
            }
            return selectedButtonInfoID.equals(button.id);
        }
    }

    public static class ButtonInfo {

        public String id;
        public int index;
        public Uri icon;

        public ButtonInfo(String id, int index, Uri uri) {
            this.id = id;
            this.index = index;
            this.icon = uri;
        }
    }

    /**
     * 角色选择回调
     */
    public interface CharacterSelectListener {

        void OnCharacterSelected(ZegoAIAgentConfigController.CharacterConfig character);
    }
}
