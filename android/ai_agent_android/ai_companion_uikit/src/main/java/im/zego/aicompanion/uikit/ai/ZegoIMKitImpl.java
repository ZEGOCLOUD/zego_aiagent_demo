package im.zego.aicompanion.uikit.ai;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import com.zegocloud.uikit.plugin.signaling.ZegoSignalingPlugin;
import com.zegocloud.zimkit.common.ZIMKitConstant;
import com.zegocloud.zimkit.components.conversation.interfaces.ZIMKitConversationListListener;
import com.zegocloud.zimkit.components.conversation.model.DefaultAction;
import com.zegocloud.zimkit.components.conversation.ui.ZIMKitConversationFragment;
import com.zegocloud.zimkit.components.message.model.ZIMKitHeaderBar;
import com.zegocloud.zimkit.components.message.ui.ZIMKitMessageActivity;
import com.zegocloud.zimkit.components.message.ui.ZIMKitMessageFragment;
import com.zegocloud.zimkit.services.ZIMKit;
import com.zegocloud.zimkit.services.ZIMKitConfig;
import com.zegocloud.zimkit.services.callback.QueryUserCallback;
import com.zegocloud.zimkit.services.config.message.ZIMKitMessageOperationName;
import com.zegocloud.zimkit.services.internal.ZIMKitAdvancedKey;
import com.zegocloud.zimkit.services.internal.ZIMKitCore;
import com.zegocloud.zimkit.services.model.ZIMKitConversation;
import com.zegocloud.zimkit.services.model.ZIMKitMessage;
import com.zegocloud.zimkit.services.model.ZIMKitUser;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.CharacterConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.ui.ZegoVoiceCallActivity;
import im.zego.aiagent.core.utils.Utils;
import im.zego.aiagent.core.widget.Constant;
import im.zego.aiagent.core.widget.ZegoClearLLMContextButton;
import im.zego.aiagent.core.widget.ZegoSwitchLLMButton;
import im.zego.zim.ZIM;
import im.zego.zim.callback.ZIMEventHandler;
import im.zego.zim.entity.ZIMConversation;
import im.zego.zim.entity.ZIMConversationChangeInfo;
import im.zego.zim.entity.ZIMCustomMessage;
import im.zego.zim.entity.ZIMError;
import im.zego.zim.enums.ZIMConversationEvent;
import im.zego.zim.enums.ZIMConversationType;
import im.zego.zim.enums.ZIMErrorCode;
import im.zego.zim.enums.ZIMMessageType;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.util.Optional;
import timber.log.Timber;


public class ZegoIMKitImpl implements ZegoIMProxy {

    private ZIMEventHandler zimEventHandler;

    @Override
    public void initIM(Application application) {
        ZIMKitConfig zimKitConfig = new ZIMKitConfig();
        zimKitConfig.resourceID = "zegouikit_call";
        zimKitConfig.inputConfig.smallButtons.clear();
        zimKitConfig.inputConfig.expandButtons.clear();
        zimKitConfig.inputConfig.emojis.clear();
        zimKitConfig.advancedConfig.put(ZIMKitAdvancedKey.showLoadingWhenSend, "true");
        zimKitConfig.advancedConfig.put(ZIMKitAdvancedKey.send_message_by_server, "true");
        zimKitConfig.advancedConfig.put(ZIMKitAdvancedKey.max_title_width, "100");
        zimKitConfig.messageConfig.textMessageConfig.operations = new ArrayList<>(
            Arrays.asList(ZIMKitMessageOperationName.COPY, ZIMKitMessageOperationName.MULTIPLE_CHOICE,
                ZIMKitMessageOperationName.DELETE));
        String hintTex = "一起聊聊天吧（文生图，拍照识别等功能，敬请期待）";
        SpannableString hintSpannableStr = new SpannableString(hintTex);
        hintSpannableStr.setSpan(new AbsoluteSizeSpan(15, true), 0, 6, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        hintSpannableStr.setSpan(new AbsoluteSizeSpan(12, true), 6, 24, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        zimKitConfig.inputConfig.inputHint = hintSpannableStr;
        ZIMKit.initWith(application, ZegoAIAgentConfigController.getInstance().appID,
            ZegoAIAgentConfigController.getInstance().appSign, zimKitConfig);
        ZIMKit.initNotifications();

        zimEventHandler = new ZIMEventHandler() {
            @Override
            public void onConversationChanged(ZIM zim, ArrayList<ZIMConversationChangeInfo> conversationChangeInfoList) {
                Timber.d("onConversationChanged() called with: zim = [" + zim + "], conversationChangeInfoList = ["
                    + conversationChangeInfoList + "]");
                Optional<ZIMConversationChangeInfo> findXiaozhi = conversationChangeInfoList.stream()
                    .filter(zimConversationChangeInfo -> {
                        String conversationID = zimConversationChangeInfo.conversation.conversationID;
                        return conversationID.contains("xiaozhi");
                    }).findAny();
                if (findXiaozhi.isPresent()) {
                    // 如果是 xiaozhi,并且是 会话创建或者是已经有名字了，假如没有置顶，才设置置顶
                    ZIMConversationChangeInfo changeInfo = findXiaozhi.get();
                    boolean isAdd = changeInfo.event == ZIMConversationEvent.ADDED;
                    ZIMConversation conversation = changeInfo.conversation;
                    if (isAdd || !TextUtils.isEmpty(conversation.conversationName)) {
                        if (!conversation.isPinned) {
                            ZegoSignalingPlugin.getInstance()
                                .updateConversationPinnedState(true, conversation.conversationID,
                                    ZIMConversationType.PEER, null);
                        }
                    }
                }
            }
        };
        ZegoSignalingPlugin.getInstance().registerZIMEventHandler(zimEventHandler);
    }

    @Override
    public void loginIMUser(String userID, String userName, String avatarUrl, AIAgentCallBack callBack) {
        ZIMKit.connectUser(userID, userName, avatarUrl, errorInfo -> {
            if (callBack != null) {
                callBack.onResult(errorInfo.code.value(), errorInfo.message);
            }
        });
    }

    @Override
    public void logoutIMUser() {
        ZIMKit.disconnectUser();
    }

    @Override
    public void unInitIM() {
        ZIMKit.unInitNotifications();
        ZegoSignalingPlugin.getInstance().unregisterZIMEventHandler(zimEventHandler);
    }

    @Override
    public void jumpToMessageActivity(Context context, int requestCode, String userID, String userName,
        String userAvatar) {
        // 定制消息页面 title bar
        ZIMKit.registerMessageListListener(fragment -> createMessagePageHeaderBar(fragment));

        //跳转消息页面
        Bundle bundle = new Bundle();
        bundle.putString(ZIMKitConstant.MessagePageConstant.KEY_TYPE,
            ZIMKitConstant.MessagePageConstant.TYPE_SINGLE_MESSAGE);
        bundle.putString(ZIMKitConstant.MessagePageConstant.KEY_AVATAR, userAvatar);
        bundle.putString(ZIMKitConstant.MessagePageConstant.KEY_ID, userID);
        bundle.putString(ZIMKitConstant.MessagePageConstant.KEY_TITLE, userName);
        bundle.putBoolean(ZIMKitConstant.MessagePageConstant.KEY_PUSH, false);
        Intent intent = new Intent(context, ZIMKitMessageActivity.class);
        intent.putExtra(ZIMKitConstant.RouterConstant.KEY_BUNDLE, bundle);
        context.startActivity(intent, bundle);

        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.JumpToMessageActivity);
    }

    @Override
    public void registerConversationListListener(Context context) {
        ZIMKit.registerConversationListListener(new ZIMKitConversationListListener() {

            //点击进入具体对话
            @Override
            public void onConversationListClick(ZIMKitConversationFragment conversationFragment,
                ZIMKitConversation conversation, DefaultAction defaultAction) {
                // 在这里添加自己的事件处理逻辑，例如，跳转到消息页面。
                //                defaultAction.toMessage();

                Timber.d("onConversationListClick,conversation: " + conversation.getZimConversation() + ",character_list:"
                    + ZegoAIAgentConfigController.getConfig().character_list);
                for (ZegoAIAgentConfigController.CharacterConfig characterConfig : ZegoAIAgentConfigController.getConfig().character_list) {
                    if (characterConfig != null && conversation != null) {
                        if (Objects.equals(conversation.getId(), characterConfig.agentId)) {
                            characterConfig.select();
                        }
                    }
                }

                CharacterConfig currentCharacter = ZegoAIAgentConfigController.getConfig().getCurrentCharacter();
                if (currentCharacter != null) {
                    ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
                    if (imProxy != null) {
                        imProxy.jumpToMessageActivity(context, Constant.REQUEST_CODE_MESSAGE_PAGE_GROUP,
                            currentCharacter.agentId, currentCharacter.name, currentCharacter.avatar);
                    }
                }
            }

            //删除对话
            @Override
            public void onConversationDeleted(ZIMConversation conversation, int position) {
                ZIMKitConversationListListener.super.onConversationDeleted(conversation, position);

                for (ZegoAIAgentConfigController.CharacterConfig characterConfig : ZegoAIAgentConfigController.getConfig().character_list) {
                    if (characterConfig != null && conversation != null) {
                        if (characterConfig.agentId.equals(conversation.conversationID)) {
                            characterConfig.select();
                        }
                    }
                }
                ZegoAIAgentRequest.requestDeleteConversation(new CommonCallBack() {
                    @Override
                    public void onSuccess(Object data) {
                        Timber.i("requestDeleteConversation onSuccess");
                    }

                    @Override
                    public void onFailed(int errorCode, String errorMsg) {
                        Timber.e("requestDeleteConversation onFailed : " + errorCode + ", " + errorMsg);
                    }
                });
            }

            //delete 按钮隐藏
            @Override
            public boolean shouldHideSwipeDeleteItem(ZIMConversation conversation, int position) {
                for (ZegoAIAgentConfigController.CharacterConfig characterConfig : ZegoAIAgentConfigController.getConfig().character_list) {
                    if (characterConfig.agentId.equals(conversation.conversationID)) {
                        if (characterConfig.isDefault) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                }
                return false;
            }
        });
    }

    @Override
    public void queryUserInfo(String userID, AIAgentCallBack callBack) {
        ZIMKit.queryUserInfo(userID, new QueryUserCallback() {
            @Override
            public void onQueryUser(ZIMKitUser userInfo, ZIMError error) {
                if (callBack != null) {
                    callBack.onResult(error.code.value(), error.message);
                }
            }
        });
    }

    @Override
    public Fragment getZIMKitConversationFragment() {
        return new ZIMKitConversationFragment();
    }

    private ZIMKitHeaderBar createMessagePageHeaderBar(ZIMKitMessageFragment fragment) {
        if (fragment != null) {
            Context context = fragment.getContext();
            String conversationID = fragment.getConversationID();
            String conversationName = fragment.getConversationName();
            ZIMKitHeaderBar headerBar = new ZIMKitHeaderBar();

            // 左侧按钮 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            LinearLayout leftContainer = new LinearLayout(context);
            leftContainer.setGravity(Gravity.CENTER_VERTICAL);
            leftContainer.setOrientation(LinearLayout.HORIZONTAL);

            // 返回按钮，设置了 left 按钮之后返回按钮要手动设置
            ImageView backButton = new ImageView(context);
            LinearLayout.LayoutParams backButtonParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            backButton.setLayoutParams(backButtonParams);
            backButton.setBackgroundColor(Color.WHITE);
            backButton.setImageResource(im.zego.aiagent.R.mipmap.zimkit_icon_return);
            backButton.setOnClickListener(v -> {
                FragmentActivity activity = fragment.getActivity();
                if (activity != null) {
                    activity.finish();
                }
            });
            leftContainer.addView(backButton);

            // 切换大模型按钮
            ZegoSwitchLLMButton switchLLMButton = new ZegoSwitchLLMButton(context);
            leftContainer.addView(switchLLMButton);
            headerBar.setLeftView(leftContainer);
            // 左侧按钮 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 右侧按钮
            LinearLayout rightContainer = new LinearLayout(context);
            rightContainer.setGravity(Gravity.CENTER_VERTICAL);
            rightContainer.setOrientation(LinearLayout.HORIZONTAL);

            // 通话按钮
            Button callButton = new Button(context);
            LinearLayout.LayoutParams callButtonParams = new LinearLayout.LayoutParams(
                Utils.dp2px(40f, context.getResources().getDisplayMetrics()),
                Utils.dp2px(40f, context.getResources().getDisplayMetrics()));
            callButton.setLayoutParams(callButtonParams);
            callButton.setBackgroundResource(im.zego.aiagent.R.mipmap.icon_audio);
            callButton.setOnClickListener(v -> {
                ZegoVoiceCallActivity.startActivity(context);
            });
            rightContainer.addView(callButton);

            // 更多按钮
            Button moreButton = new Button(context);
            LinearLayout.LayoutParams moreButtonParams = new LinearLayout.LayoutParams(
                Utils.dp2px(40f, context.getResources().getDisplayMetrics()),
                Utils.dp2px(40f, context.getResources().getDisplayMetrics()));
            moreButtonParams.leftMargin = Utils.dp2px(4f, context.getResources().getDisplayMetrics());
            moreButtonParams.rightMargin = Utils.dp2px(4f, context.getResources().getDisplayMetrics());
            moreButton.setLayoutParams(moreButtonParams);
            moreButton.setBackgroundResource(im.zego.aiagent.R.mipmap.icon_more);
            moreButton.setOnClickListener(v -> {
                // 清除上下文按钮
                ZegoClearLLMContextButton cleanContextView = new ZegoClearLLMContextButton(context);
                final PopupWindow popWindow = new PopupWindow(cleanContextView, ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT, true);
                cleanContextView.init(conversationID, popWindow);
                popWindow.setTouchable(true);
                popWindow.setBackgroundDrawable(new ColorDrawable(0x00000000));    //要为popWindow设置一个背景才有效
                popWindow.showAsDropDown(moreButton, 0, Utils.dp2px(15f, context.getResources().getDisplayMetrics()));
            });
            rightContainer.addView(moreButton);
            headerBar.setRightView(rightContainer);
            // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 右侧按钮
            return headerBar;
        }
        return null;
    }

    public void sendZIMLocalSystemMessage(String text, String conversationID, CommonCallBack cb) {
        ZIMCustomMessage zimCustomMessage = new ZIMCustomMessage(text, 0);
        ZIM.getInstance().insertMessageToLocalDB(zimCustomMessage, conversationID, ZIMConversationType.PEER,
            ZegoAIAgentConfigController.getUserInfo().userID, (imMessage, errorInfo) -> {
                if (errorInfo.code == ZIMErrorCode.SUCCESS) {
                    ZIMKitMessage zimKitMessage = new ZIMKitMessage();
                    zimKitMessage.type = ZIMMessageType.CUSTOM;
                    zimKitMessage.zim = imMessage;
                    ArrayList<ZIMKitMessage> messageList = new ArrayList<>();
                    messageList.add(zimKitMessage);
                    ZIMKitCore.getInstance().getZimkitNotifyList().notifyAllListener(zimKitDelegate -> {
                        zimKitDelegate.onMessageReceived(conversationID, ZIMConversationType.PEER, messageList);
                    });
                    cb.onSuccess(null);
                } else {
                    cb.onFailed(errorInfo.code.value(), errorInfo.message);
                }
            });
    }

}
