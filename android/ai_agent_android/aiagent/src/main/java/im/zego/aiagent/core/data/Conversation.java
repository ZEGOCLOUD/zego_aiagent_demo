package im.zego.aiagent.core.data;

import im.zego.aiagent.core.controller.CustomAgentConfig;

/**
 * 后台交互数据，向后台查询会话时，返回的数据结构
 *
 * {
 * 	"ConversationId": "au_9195214_5888921484_and",
 * 	"UserId": "au_9195214",
 * 	"AgentId": "@RBT#_au_9195214_5888921484_and",
 * 	"AgentTemplateId": "zhangzhiyu",
 * 	"CustomAgentConfig": {
 * 		"AgentTemplateId": "zhangzhiyu",
 * 		"Name": "张知予",
 * 		"Avatar": "https://zego-aigc-test.oss-accelerate.aliyuncs.com/airobotdemo/native_icon/zhangzhiyu/m_avatar_zhangzhiyu.png",
 * 		"Intro": "跨国集团继承人、地下摇滚乐队贝斯手。自幼接受精英教育，热爱音乐，毕业后成为家族企业执行总裁。\n（叛逆年下）",
 * 		"System": "角色：张知予\n性别：男\n角色设定：跨国集团继承人、地下摇滚乐队贝斯手。自幼接受精英教育，热爱音乐，毕业后成为家族企业执行总裁。\n（叛逆年下）\n",
 * 		"LLM": {
 * 			"Type": "Doubao",
 * 			"Model": "ep-20240806100628-6dfw7"
 * 		        },
 * 		"TTS": {
 * 			"Type": "Minimax",
 * 			"Voice": "qiongyao_nanzhu"
 *        },
 * 		"Source": "Zego",
 * 		"WelcomeMessage": "",
 * 		"Sex": "男"    * 	},
 * 	"ChatConfig": {},
 * 	"IsChatting": false
 * }
 *
 */
public class Conversation {

    // 后台交互的 ConversationId
    public String ConversationId;

    public String UserId;

    // 被后台用作zim 的 userID,也就是 zim 的 ConversationId
    public String AgentId;

    // 关联的 AI 智能体属性
    public String AgentTemplateId;

    // 用于会话展示的 AI 的 一些配置
    public CustomAgentConfig CustomAgentConfig;

    public ChatConfig ChatConfig;
    public boolean IsChatting;
}
