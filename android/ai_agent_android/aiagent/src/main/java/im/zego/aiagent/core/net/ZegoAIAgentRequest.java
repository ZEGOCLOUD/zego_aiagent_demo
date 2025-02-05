package im.zego.aiagent.core.net;

import android.text.TextUtils;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.controller.CustomAgentConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.AgentRequestConfigList;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.utils.Utils;
import timber.log.Timber;

/**
 * AI Agent 网络协议，在后台接口的基础上加了一些业务逻辑
 */
public class ZegoAIAgentRequest {

    private static final String TAG = "ZegoAIAgentRequest";


    public static void requestUploadAgentAvatar(String filePath, CommonCallBack cb) {
        ZegoBackendServerAPI.requestUploadAgentAvatar(ZegoAIAgentConfigController.getUserInfo().userID, filePath,
            (errorCode, message, imageUrlData) -> {
                Timber.d(
                    "requestUploadAgentAvatar onResult() called with: errorCode = [" + errorCode + "], errorMsg = ["
                        + message + "],imageUrlData:" + imageUrlData);
                if (errorCode == 0) {
                    ZegoOKHttpClient.getInstance().asyncPostImageAliyun(imageUrlData, filePath, new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            Timber.d("asyncPostImageAliyun onResult() called with: errorCode = [" + errorCode
                                + "], errorMsg = [" + message + "]");
                            if (errorCode == 0) {
                                cb.onSuccess(imageUrlData);
                            } else {
                                cb.onFailed(errorCode, message);
                            }
                        }
                    });
                } else {
                    cb.onFailed(errorCode, message);
                }

            });
    }

    /**
     * 查询模版
     *
     * @param cb
     */
    public static void queryCustomAgentTemplate(CommonCallBack cb) {
        ZegoBackendServerAPI.queryCustomAgentTemplate(new AIAgentCommonCallBack<AgentRequestConfigList>() {
            @Override
            public void onCallback(int errorCode, String message, AgentRequestConfigList bean) {
                if (errorCode == 0) {
                    if (bean == null || !bean.isValid()) {
                        // 后台返回的数据有错误
                        cb.onFailed(errorCode, "backend data error!");
                    } else {
                        cb.onSuccess(bean);
                    }
                } else {
                    cb.onFailed(errorCode, message);
                }
            }
        });
    }

    /**
     * 查询会话列表
     *
     * @param cb
     */
    public static void requestQueryConversation(CommonCallBack cb) {
        ZegoBackendServerAPI.describeConversationList(ZegoAIAgentConfigController.getUserInfo().userID,
            (errorCode, errMsg, bean) -> {
                if (errorCode == 0) {
                    if (bean == null || !bean.isValid()) {
                        // 后台返回的数据有错误
                        cb.onFailed(errorCode, "backend data error!");
                    } else {
                        cb.onSuccess(bean);
                    }
                } else {
                    cb.onFailed(errorCode, errMsg);
                }
            });
    }

    public static void createConversationWithoutIM(String conversationId, String userId, String agentId,
        String agentTemplateId, CustomAgentConfig config, AIAgentCommonCallBack<Void> callBack) {
        ZegoBackendServerAPI.createConversation(conversationId, userId, agentId, agentTemplateId, config, 2, callBack);
    }


    public static void createConversation(String conversationId, String userId, String agentId, String agentTemplateId,
        CustomAgentConfig config, AIAgentCommonCallBack<Void> callBack) {
        int chatHistoryMode = 0;
        ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
        if (imProxy == null) {
            chatHistoryMode = 2;
        }
        ZegoBackendServerAPI.createConversation(conversationId, userId, agentId, agentTemplateId, config,
            chatHistoryMode, callBack);
    }


    /**
     * 创建当前会话
     *
     * @param cb
     */
    public static void requestCreateConversation(ZegoAIAgentConfigController.CharacterConfig characterConfig,
        CommonCallBack cb) {
        CustomAgentConfig customAgentConfigData = CustomAgentConfig.createFromCharacter(characterConfig);
        if (characterConfig.conversationId == null) {
            //创建 conversationId 和 conversationId
            String userID = ZegoAIAgentConfigController.getUserInfo().userID;

            characterConfig.conversationId = subString(userID, 5) + "_" + subString(characterConfig.templateID, 9) + "_"
                + System.currentTimeMillis() % 100000L + "_" + Utils.generateRandomString(4);
            characterConfig.agentId = "@RBT#_" + characterConfig.conversationId;

            createConversation(characterConfig.conversationId, userID, characterConfig.agentId,
                characterConfig.templateID, customAgentConfigData, new AIAgentCommonCallBack<Void>() {
                    @Override
                    public void onCallback(int errorCode, String message, Void unused) {
                        if (errorCode == 0) {
                            cb.onSuccess(null);
                        } else {
                            cb.onFailed(errorCode, message);
                        }
                    }
                });
        } else {
            // 已经会话了，不用重复创建
            Timber.d(
                "requestCreateConversation no need, conversation already exist, id: " + characterConfig.conversationId
                    + ", agentID: " + characterConfig.agentId);
            cb.onSuccess(null);
        }
    }

    private static String subString(String s, int length) {
        if (TextUtils.isEmpty(s)) {
            return "";
        }
        String s1;
        if (s.length() >= length) {
            s1 = s.substring(s.length() - length);
        } else {
            s1 = s;
        }
        return s1;
    }

    ;

    /**
     * 修改会话
     *
     * @param cb
     */
    public static void requestUpdateConversation(CommonCallBack cb) {
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        CustomAgentConfig customAgentConfigData = CustomAgentConfig.createFromCharacter(characterConfig);
        if (characterConfig.conversationId != null) {
            ZegoBackendServerAPI.updateConversation(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, characterConfig.templateID,
                customAgentConfigData, new AIAgentCommonCallBack<Void>() {
                    @Override
                    public void onCallback(int errorCode, String message, Void unused) {
                        if (errorCode == 0) {
                            cb.onSuccess(null);
                        } else {
                            cb.onFailed(errorCode, message);
                        }
                    }
                });
        } else {
            cb.onFailed(-1, "requestUpdateConversation failed, conversation empty!!");
        }
    }

    /**
     * reset会话消息
     *
     * @param cb
     */
    public static void requestResetConversationMsg(CommonCallBack cb) {
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        if (characterConfig.conversationId != null) {
            ZegoBackendServerAPI.resetConversationMsg(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId,
                new AIAgentCommonCallBack<Void>() {
                    @Override
                    public void onCallback(int errorCode, String message, Void unused) {
                        if (errorCode == 0) {
                            cb.onSuccess(null);
                        } else {
                            cb.onFailed(errorCode, message);
                        }
                    }
                });
        } else {
            cb.onFailed(-1, "requestResetConversationMsg failed, conversation empty!!");
        }
    }

    /**
     * 删除会话
     *
     * @param cb
     */
    public static void requestDeleteConversation(CommonCallBack cb) {
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        if (characterConfig.conversationId != null) {
            ZegoBackendServerAPI.deleteConversation(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, new AIAgentCommonCallBack<Void>() {
                @Override
                public void onCallback(int errorCode, String message, Void unused) {
                    if (errorCode == 0) {
                        cb.onSuccess(null);
                    } else {
                        cb.onFailed(errorCode, message);
                    }
                }
            });
        } else {
            cb.onFailed(-1, "requestDeleteConversation failed, conversation empty!!");
        }
    }

    public static void startRtcChat(AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        if (characterConfig.conversationId != null) {
            ZegoBackendServerAPI.startRtcChat(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, characterConfig.getRoomID(),
                characterConfig.getStreamID(), characterConfig.getAgentStreamID(), callBack);
        } else {
            if (callBack != null) {
                callBack.onCallback(-1, "startRtcChat 错误：请先创建会话", null);
            }
        }
    }


    public static void stopRtcChat(AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        if (characterConfig.conversationId != null) {
            ZegoBackendServerAPI.stopRtcChat(ZegoAIAgentConfigController.getUserInfo().userID,characterConfig.conversationId, callBack);
        } else {
            if (callBack != null) {
                callBack.onCallback(-1, "stopRtcChat 错误：请先创建会话", null);
            }
        }
    }
}
