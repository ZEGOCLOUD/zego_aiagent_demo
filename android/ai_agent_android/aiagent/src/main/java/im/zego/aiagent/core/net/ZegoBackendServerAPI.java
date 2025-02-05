package im.zego.aiagent.core.net;

import com.google.gson.JsonObject;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.CustomAgentConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.AgentRequestConfigList;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.ConversationRequestDataList;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.data.ImageUrlData;

/**
 * 后台接口都定义在这里
 */
public class ZegoBackendServerAPI {


    /**
     * 请求的Action
     */
    //模版
    public static final String Action_QueryAgentTemplate = "DescribeCustomAgentTemplate";
    //会话
    public static final String Action_QueryConversation = "DescribeConversationList";
    public static final String Action_CreateConversation = "CreateConversation";
    public static final String Action_DeleteConversation = "DeleteConversation";
    public static final String Action_UpdateConversation = "UpdateConversation";
    public static final String Action_ResetConversationMsg = "ResetConversationMsg";
    //语音对话
    public static final String Action_StartRtcChat = "StartRtcChat";
    public static final String Action_StopRtcChat = "StopRtcChat";
    //头像
    public static final String Action_UploadAgentAvatar = "UploadAgentAvatar";

    /**
     * 上传头像
     *
     * @param userID   userID
     * @param filePath 文件实际路径
     * @param callBack
     */
    public static void requestUploadAgentAvatar(String userID, String filePath,
        AIAgentCommonCallBack<ImageUrlData> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.UploadAgentAvatar_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("UserId", userID);
        jsonObject.addProperty("FileName", filePath);
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_UploadAgentAvatar, jsonObject.toString(), ImageUrlData.class,
                (errorCode, message, bean) -> {
                    if (errorCode == 0) {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.UploadAgentAvatar_Success);
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.UploadAgentAvatar_Failed);
                    }
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, bean);
                    }
                });

    }

    /**
     * 第一步：向后台查询可用的智能体列表，获取对应的配置
     * 对应pass接口：Action：DescribeCustomAgentTemplate,描述：查询可用的智能体模版。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     *
     * @param callBack 返回结果
     **/
    public static void queryCustomAgentTemplate(AIAgentCommonCallBack<AgentRequestConfigList> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RequestAgentTemp_Start);
        JsonObject jsonObject = new JsonObject();
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_QueryAgentTemplate, jsonObject.toString(), AgentRequestConfigList.class,
                (errorCode, message, bean) -> {
                    if (errorCode == 0) {
                        if (bean == null || !bean.isValid()) {
                            // 后台返回的数据有错误
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.RequestAgentTemp_Failed);
                        } else {
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.RequestAgentTemp_Success);
                        }
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RequestAgentTemp_Failed);
                    }
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, bean);
                    }
                });
    }



    /**
     * 第二步：查询所有该账号拥有的所有会话 对应pass接口：Action：DescribeConversationList,描述：获取会话列表，APP可以用做维护已存在的会话列表或用ZIM
     * SDK。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     *
     * @param userID   用户Id
     * @param callBack 返回结果
     **/
    public static void describeConversationList(String userID,
        AIAgentCommonCallBack<ConversationRequestDataList> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RequestConversation_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("UserId", userID);
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_QueryConversation, jsonObject.toString(), ConversationRequestDataList.class,
                (errorCode, message, bean) -> {
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, bean);
                    }
                    if (errorCode == 0) {
                        if (bean == null || !bean.isValid()) {
                            // 后台返回的数据有错误
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.RequestConversation_Failed);
                        } else {
                            ZegoAIAgentMonitor.getInstance()
                                .report(ZegoAIAgentMonitor.AppState.RequestConversation_Success);
                        }
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RequestConversation_Failed);
                    }
                });
    }



    /**
     * 创建会话，不依赖IM 对应pass接口：Action：CreateConversation,
     * 描述：创建会话，后续IM与RTC对话时使用。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     *
     * @param conversationId  会话Id，创建会话步骤得到的
     * @param userId          用户Id
     * @param agentId         智能体Id,以@RBT#开头的字符串
     * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
     * @param config          智能体配置模版
     * @param ChatHistoryMode 集成了ZIM 传0，没有集成传 1或者2
     * @param callBack        回调，返回结果
     **/
    public static void createConversation(String conversationId, String userId, String agentId, String agentTemplateId,
        CustomAgentConfig config, int ChatHistoryMode, AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildConversation_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("UserId", userId);
        jsonObject.addProperty("AgentId", agentId);
        jsonObject.addProperty("AgentTemplateId", agentTemplateId);
        if (ChatHistoryMode != -1) {
            jsonObject.addProperty("ChatHistoryMode", ChatHistoryMode);
        }
        jsonObject.add("CustomAgentConfig", config.toJsonObject());

        ZegoOKHttpClient.getInstance().asyncPostJsonRequest(ZegoBackendServerAPI.Action_CreateConversation, jsonObject.toString(), null,
            (errorCode, message, bean) -> {
                if (errorCode == 0) {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildConversation_Success);
                } else {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildConversation_Failed);
                }
                if (callBack != null) {
                    callBack.onCallback(errorCode, message, null);
                }
            });
    }

    /**
     * 更新会话 对应pass接口：Action：UpdateConversation, 描述：更新会话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     *
     * @param conversationId  会话Id，创建会话步骤得到的
     * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
     * @param config          智能体配置模版
     * @param callBack        回调，返回结果
     **/
    public static void updateConversation(String userID,String conversationId, String agentTemplateId, CustomAgentConfig config,
        AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ModifyConversation_Start);

        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("AgentTemplateId", agentTemplateId);
        jsonObject.addProperty("UserId", userID);
        jsonObject.add("CustomAgentConfig", config.toJsonObject());
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_UpdateConversation, jsonObject.toString(), Object.class,
                (errorCode, message, bean) -> {
                    if (errorCode == 0) {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ModifyConversation_Success);
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ModifyConversation_Failed);
                    }
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, null);
                    }
                });
    }

    public static void resetConversationMsg(String userId,String conversationId, AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ResetConversation_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("UserId", userId);
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_ResetConversationMsg, jsonObject.toString(), Object.class,
                (errorCode, message, bean) -> {
                    if (errorCode == 0) {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ResetConversation_Success);
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.ResetConversation_Failed);
                    }
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, null);
                    }
                });
    }

    public static void deleteConversation(String userID,String conversationId, AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveConversation_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("UserId", userID);
        ZegoOKHttpClient.getInstance()
            .asyncPostJsonRequest(ZegoBackendServerAPI.Action_DeleteConversation, jsonObject.toString(), Object.class,
                (errorCode, message, bean) -> {
                    if (errorCode == 0) {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveConversation_Success);
                    } else {
                        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveConversation_Failed);
                    }
                    if (callBack != null) {
                        callBack.onCallback(errorCode, message, null);
                    }
                });
    }

    /**
     * 发送开始RTC通话业务协议 对应pass接口：Action：StartRtcChat,
     * 描述：需要进行语音对话时，用于发起一次语音对话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： im.zego.aiagent.core.ui.ZegoVoiceCallWithExpressActivity
     *
     * @param conversationId 会话Id，创建会话步骤得到的
     * @param roomId         房间Id,可以随机字符串
     * @param streamId       本地推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
     * @param agentStreamId  智能体推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
     * @param callBack       回调，返回结果
     **/
    public static void startRtcChat(String userID,String conversationId, String roomId, String streamId, String agentStreamId,
        AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildTalk_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("RoomId", roomId);
        jsonObject.addProperty("StreamId", streamId);
        jsonObject.addProperty("AgentStreamId", agentStreamId);
        jsonObject.addProperty("UserId", userID);
        ZegoOKHttpClient.getInstance().asyncPostJsonRequest(ZegoBackendServerAPI.Action_StartRtcChat, jsonObject.toString(), Object.class,
            (errorCode, message, bean) -> {
                if (errorCode == 0 || errorCode == 410003101) {
                    // 410003101 重入，也当成功处理，后台已经创建了语音通话，可能原因是上次关闭的时候没有掉 StopTalk（可能是因为上次关闭进程被杀/网络原因）
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildTalk_Success);
                } else {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.BuildTalk_Failed);
                }
                if (callBack != null) {
                    callBack.onCallback(errorCode, message, null);
                }
            });
    }

    /**
     * 发送终止RTC通话业务协议 对应pass接口：Action：StopRtcChat,
     * 描述：用于结束已发起的语音对话，释放资源。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： im.zego.aiagent.core.ui.ZegoVoiceCallWithExpressActivity
     *
     * @param conversationId 会话Id，创建会话步骤得到的
     * @param callBack       回调，返回结果
     **/
    public static void stopRtcChat(String userID,String conversationId, AIAgentCommonCallBack<Void> callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveTalk_Start);
        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("ConversationId", conversationId);
        jsonObject.addProperty("UserId", userID);
        ZegoOKHttpClient.getInstance().asyncPostJsonRequest(ZegoBackendServerAPI.Action_StopRtcChat, jsonObject.toString(), Object.class,
            (errorCode, message, bean) -> {
                if (errorCode == 0) {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveTalk_Success);
                } else {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.RemoveTalk_Failed);
                }
                if (callBack != null) {
                    callBack.onCallback(errorCode, message, null);
                }
            });
    }

}
