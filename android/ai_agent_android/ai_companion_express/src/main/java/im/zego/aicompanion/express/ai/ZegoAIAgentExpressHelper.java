package im.zego.aicompanion.express.ai;

import android.app.Application;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.ConversationRequestDataList;
import im.zego.aiagent.core.controller.CustomAgentConfig;
import im.zego.aiagent.core.net.ZegoBackendServerAPI;

public class ZegoAIAgentExpressHelper {

    private ZegoAIAgentExpressHelper() {
    }

    private static final class SingletonHolder {

        private static final ZegoAIAgentExpressHelper INSTANCE = new ZegoAIAgentExpressHelper();
    }

    public static ZegoAIAgentExpressHelper getInstance() {
        return SingletonHolder.INSTANCE;
    }

    /**
     * 初始化 AI 陪伴服务，初始化时需要填入用户账号信息，用户需要确保 userID 唯一
     *
     * @param application  application
     * @param appID        app id
     * @param appSign      app sign
     * @param serverSecret 服务key
     * @param userID       用户id
     * @param userName     用户名称
     * @param avatarUrl    用户头像url
     **/
    public void initAICompanion(Application application, long appID, String appSign, String serverSecret, String userID,
        String userName, String avatarUrl) {
        // 初始化 AIAgent 服务
        ZegoAIAgentHelper.initAICompanion(application, appID, appSign, serverSecret, userID, userName, avatarUrl);
    }

    /**
     * 反初始化AI陪伴相关设置
     **/
    public void unInitAICompanion() {
        ZegoAIAgentHelper.unInitAICompanion();
    }

    /**
     * 第一步：查询所有该账号的缺省智能体配置模版，并解释其配置内容保存在本地
     * 对应pass接口：Action：DescribeCustomAgentTemplate,描述：查询可用的智能体模版。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     * @param callBack 返回结果
     **/
    public void queryCustomAgentTemplate(
        AIAgentCommonCallBack<ZegoAIAgentConfigController.AgentRequestConfigList> callBack) {
        ZegoBackendServerAPI.queryCustomAgentTemplate(callBack);
    }

    /**
     * 第二步：查询所有该账号拥有的所有会话 对应pass接口：Action：DescribeConversationList,描述：获取会话列表，APP可以用做维护已存在的会话列表或用ZIM
     * SDK。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     * @param userID   用户Id
     * @param callBack 返回结果
     **/
    public void describeConversationList(String userID, AIAgentCommonCallBack<ConversationRequestDataList> callBack) {
        ZegoBackendServerAPI.describeConversationList(userID, callBack);
    }

    /**
     * 创建会话，不依赖IM 对应pass接口：Action：CreateConversation,
     * 描述：创建会话，后续IM与RTC对话时使用。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     * @param conversationId  会话Id，创建会话步骤得到的
     * @param userId          用户Id
     * @param agentId         智能体Id,以@RBT#开头的字符串
     * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
     * @param config          智能体配置模版
     * @param callBack        回调，返回结果
     **/
    public void createConversationWithoutIM(String conversationId, String userId, String agentId,
        String agentTemplateId, CustomAgentConfig config, AIAgentCommonCallBack<Void> callBack) {
        ZegoBackendServerAPI.createConversation(conversationId, userId, agentId, agentTemplateId, config, 2, callBack);
    }

    /**
     * 更新会话 对应pass接口：Action：UpdateConversation, 描述：更新会话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： ZegoAIAgentHelper.requestAppConfigAndGetConversation
     * @param conversationId  会话Id，创建会话步骤得到的
     * @param agentTemplateId 智能体配置模版Id，如果存在则config参数可为空，如果不存在则需要提供config参数
     * @param config          智能体配置模版
     * @param callBack        回调，返回结果
     **/
    public void updateConversation(String userID,String conversationId, String agentTemplateId, CustomAgentConfig config,
        AIAgentCommonCallBack<Void> callBack) {
        ZegoBackendServerAPI.updateConversation(userID,conversationId, agentTemplateId, config, callBack);
    }

    /**
     * 发送开始RTC通话业务协议 对应pass接口：Action：StartRtcChat,
     * 描述：需要进行语音对话时，用于发起一次语音对话。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： im.zego.aiagent.core.ui.ZegoVoiceCallWithExpressActivity
     * @param conversationId 会话Id，创建会话步骤得到的
     * @param roomId         房间Id,可以随机字符串
     * @param streamId       本地推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
     * @param agentStreamId  智能体推流Id，可以随机字符串，但要符合ZegoRTC的流id规范，具体参考官网文档
     * @param callBack       回调，返回结果
     **/
    public void startRtcChat(String userID,String conversationId, String roomId, String streamId, String agentStreamId,
        AIAgentCommonCallBack<Void> callBack) {
        ZegoBackendServerAPI.startRtcChat(userID,conversationId, roomId, streamId, agentStreamId, callBack);
    }

    /**
     * 发送终止RTC通话业务协议 对应pass接口：Action：StopRtcChat,
     * 描述：用于结束已发起的语音对话，释放资源。https://zegocloud.feishu.cn/wiki/KOLEwLlEni2qDjkmBujczjMcnGc
     * <br> 参考： im.zego.aiagent.core.ui.ZegoVoiceCallWithExpressActivity
     * @param conversationId 会话Id，创建会话步骤得到的
     * @param callBack       回调，返回结果
     **/
    public void stopRtcChat(String userID,String conversationId, AIAgentCommonCallBack<Void> callBack) {
        ZegoBackendServerAPI.stopRtcChat(userID,conversationId, callBack);
    }
}
