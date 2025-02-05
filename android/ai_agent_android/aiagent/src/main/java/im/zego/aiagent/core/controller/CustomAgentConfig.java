package im.zego.aiagent.core.controller;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.CharacterConfig;
import im.zego.aiagent.core.data.LLMData;
import im.zego.aiagent.core.data.TTSData;


/**
 * 后台交互数据，向后台更新会话或者创建会话时，传入的 AI 相关设置
 *
 * {
 * 	"AgentTemplateId": "xiaozhi",
 * 	"Name": "小智",
 * 	"Avatar": "https://zego-aigc-test.oss-accelerate.aliyuncs.com/airobotdemo/native_icon/xiaozhi/m_avatar_xiaozhi.png",
 * 	"Intro": "一个小百科，上知天文下知地理。懂得如何陪伴人类，还会角色扮演。\n（标签：聪慧、机灵）",
 * 	"System": "你是小智，成年女性，是**即构科技创造的陪伴助手**，上知天文下知地理，聪明睿智、热情友善。\n对话要求：1、按照人设要求与用户对话。\n2、不能超过100字。 ",
 * 	"LLM": {
 * 		"Type": "Doubao",
 * 		"Model": "ep-20240806100628-6dfw7"
 * 	    },
 * 	"TTS": {
 * 		"Type": "Huoshan",
 * 		"Voice": "BV700_streaming"
 *    },
 * 	"Source": "Zego",
 * 	"WelcomeMessage": "嗨,我是你的新朋友小智!初次见面很开心。我呢,可以回答你的各种问题,给你工作学习上提供帮助,还能随时陪你聊天。嗯,你想问点什么呢?",
 * 	"Sex": "女"
 * }
 *
 */
public class CustomAgentConfig {

    public String AgentTemplateId;
    public String Name;
    public String Avatar;
    public LLMData LLM;
    public TTSData TTS;
    public String Source;
    public String Sex;
    public String Intro;
    public String System;
    public String WelcomeMessage;

    public JsonObject toJsonObject() {
        // 创建 Gson 实例
        Gson gson = new Gson();
        // 将当前对象转为 JsonElement
        JsonElement jsonElement = gson.toJsonTree(this);
        // 转为 JsonObject
        return jsonElement.getAsJsonObject();
    }

    public static CustomAgentConfig createFrom(CustomAgentConfig customAgentConfig){
        CustomAgentConfig newConfig = new CustomAgentConfig();
        newConfig.AgentTemplateId = customAgentConfig.AgentTemplateId;
        newConfig.Name = customAgentConfig.Name;
        newConfig.Avatar = customAgentConfig.Avatar;
        newConfig.LLM = customAgentConfig.LLM;
        newConfig.TTS = customAgentConfig.TTS;
        newConfig.Source = customAgentConfig.Source;
        newConfig.Sex = customAgentConfig.Sex;
        newConfig.Intro = customAgentConfig.Intro;
        newConfig.System = customAgentConfig.System;
        newConfig.WelcomeMessage = customAgentConfig.WelcomeMessage;
        return newConfig;
    }

    public static CustomAgentConfig createFromCharacter(CharacterConfig characterConfig) {
        CustomAgentConfig custom = new CustomAgentConfig();
        custom.AgentTemplateId = characterConfig.templateID;
        custom.Avatar = characterConfig.avatar;
        custom.Name = characterConfig.name;
        custom.Sex = characterConfig.sex;
        custom.Source = characterConfig.source;
        custom.Intro = characterConfig.intro;

        //拼凑一个system
        custom.System = "角色：" + custom.Name + "\n" + "性别：" + custom.Sex + "\n" + "角色设定：" + custom.Intro + "\n";

        if (characterConfig.cur_config.llm_id != null) {
            custom.LLM = characterConfig.cur_config.getCurrentLLMConfig().raw_properties;
        }

        if (characterConfig.cur_config.tts_id != null) {
            custom.TTS = characterConfig.cur_config.getCurrentTTSConfig().raw_properties;
            if (characterConfig.cur_config.language_id != null) {
                custom.TTS.Voice = characterConfig.cur_config.getCurrentVoiceConfig().id;
            }
        }
        return custom;
    }
}
