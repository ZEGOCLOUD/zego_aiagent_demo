package im.zego.aiagent.core.controller;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.util.Log;
import androidx.annotation.NonNull;
import com.google.gson.Gson;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.data.Conversation;
import im.zego.aiagent.core.data.LLMData;
import im.zego.aiagent.core.data.TTSData;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.utils.ToastUtils;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Objects;
import java.util.Random;
import timber.log.Timber;

/**
 * 管理 APP 各种 Config
 */
@SuppressLint("LogNotTimber")
public class ZegoAIAgentConfigController {

    private static final String TAG = "ConfigController";

    // app config
    public long appID;
    public String appSign;
    public String serverSecret;

    // 用户信息
    private AppUserInfo appUserInfo;

    /**
     * app 数据信息，保存比如 character/llm/tts 等配置， 用于与ui交互 后台请求数据需要填入到 appExtraConfig中
     */
    private AppExtraConfig appExtraConfig;

    private static ZegoAIAgentConfigController sInstance;

    public static ZegoAIAgentConfigController getInstance() {
        return sInstance;
    }

    public static void init(Context context, long appID, String appSign, String serverSecret) {
        ZegoAIAgentConfigController zegoAIAgentConfigController = new ZegoAIAgentConfigController();
        zegoAIAgentConfigController.appID = appID;
        zegoAIAgentConfigController.appSign = appSign;
        zegoAIAgentConfigController.serverSecret = serverSecret;
        zegoAIAgentConfigController.appUserInfo = AppUserInfo.getDefaultUserInfo(context);
        sInstance = zegoAIAgentConfigController;

        Log.d(TAG, "AppSettings init, userID: " + getUserInfo().userID);
    }

    public static AppExtraConfig getConfig() {
        return getInstance().appExtraConfig;
    }

    public static AppUserInfo getUserInfo() {
        return getInstance().appUserInfo;
    }

    public void setUserInfo(AppUserInfo userInfo) {
        appUserInfo = new AppUserInfo();
        appUserInfo.clone(userInfo);
        Log.d(TAG, "AppSettings setUserInfo, userID: " + appUserInfo.userID + ", name: " + appUserInfo.userName);
    }

    /**
     * 后台请求暂存
     */
    //模版查询请求结果
    private AgentRequestConfigList requestAgentConfigList = null;
    //会话查询请求结果
    private ConversationRequestDataList requestConversationDataList = null;

    public boolean isAgentConfigListEmpty() {
        if (requestAgentConfigList == null) {
            Log.e(TAG, "requestAgentConfigList is null ");
            return true;
        }

        if (requestAgentConfigList.CustomAgentConfigList.length == 0) {
            Log.e(TAG, "requestAgentConfigList.CustomAgentConfigList.length ");
            return true;
        }
        return false;
    }

    /**
     * 初始化appExtraConfig ， 从json中
     *
     * @param jsonString
     * @return AppExtraConfig
     */
    public AppExtraConfig initAppConfigFromJson(String jsonString) {
        Gson gson = new Gson();
        appExtraConfig = gson.fromJson(jsonString, AppExtraConfig.class);
        return appExtraConfig;
    }

    /**
     * 请求获取 AgentConfig
     *
     * @param cb
     */
    public void requestAgentConfigAndGetConversation(CommonCallBack cb) {

        if (appExtraConfig == null) {
            Log.e(TAG, "appExtraConfig not init, please read json for config");
            cb.onFailed(-3, "appExtraConfig 配置为空");
            return;
        }

        // 向后台请求AI角色配置
        ZegoAIAgentRequest.queryCustomAgentTemplate(new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                requestAgentConfigList = (AgentRequestConfigList) data;
                if (requestAgentConfigList != null && requestAgentConfigList.CustomAgentConfigList.length > 0) {

                    //查询默认模板
                    for (int i = 0; i < requestAgentConfigList.CustomAgentConfigList.length; i++) {
                        appExtraConfig.character_list.add(new CharacterConfig());
                        updateCharacterConfig(appExtraConfig.character_list.get(i),
                            requestAgentConfigList.CustomAgentConfigList[i], true);
                    }

                    //向后台请求会话列表
                    requestGetConversation(new CommonCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            requestConversationDataList = (ConversationRequestDataList) data;
                            if (requestConversationDataList != null) {

                                //默认模板的自动创建, 倒序， xiaozhi排第一个
                                for (int i = appExtraConfig.character_list.size() - 1; i >= 0; i--) {
                                    CharacterConfig characterConfig = appExtraConfig.character_list.get(i);
                                    Conversation c = getConversationByAgentTemplateId(characterConfig.templateID);

                                    // 根据AI角色配置，创建会话或者更新会话
                                    if (c != null) {
                                        //已经有了
                                        characterConfig.conversationId = c.ConversationId;
                                        characterConfig.agentId = c.AgentId;
                                        characterConfig.create = true;
                                        characterConfig.isDefault = true;
                                        updateCharacterConfig(characterConfig, c.CustomAgentConfig, false);
                                    } else {
                                        //没有，去创建
                                        ZegoAIAgentRequest.requestCreateConversation(characterConfig,
                                            new CommonCallBack() {
                                                @Override
                                                public void onSuccess(Object data) {
                                                    characterConfig.create = true;
                                                    characterConfig.isDefault = true;
                                                }

                                                @Override
                                                public void onFailed(int errorCode, String errorMsg) {
                                                    ToastUtils.show("创建会话失败：errorCode:" + errorCode +",errorMsg:" + errorMsg);
                                                }
                                            });

                                    }
                                }

                                if (requestConversationDataList.ConversationList != null) {
                                    ArrayList<CharacterConfig> temp_list = new ArrayList<>();
                                    //查询会话， 找到自己已经创建的。
                                    for (Conversation c : requestConversationDataList.ConversationList) {
                                        //非模版的会话
                                        CharacterConfig config = getCharacterConfigByID(c.AgentTemplateId);
                                        if (config == null) {
                                            config = new CharacterConfig();
                                            config.conversationId = c.ConversationId;
                                            config.agentId = c.AgentId;
                                            config.create = true;
                                            //非默认
                                            config.isDefault = false;
                                            updateCharacterConfig(config, c.CustomAgentConfig, false);
                                            temp_list.add(config);
                                        }
                                    }
                                    if (!temp_list.isEmpty()) {
                                        appExtraConfig.character_list.addAll(temp_list);
                                    }
                                }

                            }

                            cb.onSuccess(appExtraConfig.character_list);
                        }

                        @Override
                        public void onFailed(int errorCode, String errorMsg) {
                            cb.onFailed(-2, "查询会话失败");
                        }
                    });
                } else {
                    Log.w(TAG, "========== requestQueryAgentConfig result is null or no child ");
                    cb.onFailed(-1, "拉取配置失败");
                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                Log.e(TAG, "requestQueryAgentConfig errorCode: " + errorCode + ", errorMsg: " + errorMsg);
                cb.onFailed(errorCode, errorMsg);
            }
        });
    }

    /**
     * 查询会话
     */
    public void requestGetConversation(CommonCallBack cb) {
        ZegoAIAgentRequest.requestQueryConversation(new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                requestConversationDataList = (ConversationRequestDataList) data;

                cb.onSuccess(data);
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                cb.onFailed(errorCode, errorMsg);
                Log.e(TAG, "requestQueryConversation errorCode: " + errorCode + ", errorMsg: " + errorMsg);
            }
        });
    }

    public Conversation getConversationByAgentTemplateId(String agentTemplateId) {
        if (requestConversationDataList.ConversationList != null && requestConversationDataList.Total > 0) {
            for (int i = 0; i < requestConversationDataList.ConversationList.length; i++) {
                Conversation conversation = requestConversationDataList.ConversationList[i];
                if (agentTemplateId.equals(conversation.AgentTemplateId)) {
                    return conversation;
                }
            }
        }
        return null;
    }

    public CharacterConfig getCharacterConfigByID(String id) {

        if (id != null) {
            for (CharacterConfig config : appExtraConfig.character_list) {
                if (config.templateID != null) {
                    if (config.templateID.equals(id)) {
                        return config;
                    }
                }
            }
        }
        return null;
    }

    public void updateCharacterConfig(CharacterConfig characterConfig, CustomAgentConfig agentConfigData,
        boolean useTemplate) {

        if (useTemplate) {
            characterConfig.templateID = agentConfigData.AgentTemplateId;
        }

        characterConfig.avatar = agentConfigData.Avatar;
        characterConfig.name = agentConfigData.Name;
        characterConfig.source = agentConfigData.Source;
        characterConfig.sex = agentConfigData.Sex;
        characterConfig.intro = agentConfigData.Intro;

        if (agentConfigData.LLM != null) {
            characterConfig.cur_config.llm_id = getLLMID(agentConfigData.LLM);
        }

        if (agentConfigData.TTS != null) {
            TTSConfig ttsConfig = getTTS(agentConfigData.TTS);
            if (ttsConfig != null) {
                characterConfig.cur_config.tts_id = ttsConfig.id;
                characterConfig.cur_config.voice_id = getVoiceID(ttsConfig, agentConfigData.TTS);
                characterConfig.cur_config.language_id = getLanguageID(ttsConfig, agentConfigData.TTS);
            }
        }
    }

    //从请求回包获取 llmid
    public String getLLMID(LLMData llm) {

        for (LLMConfig llmConfig : appExtraConfig.llm_list) {
            if (llmConfig.is_supported && llmConfig.raw_properties.Model.equals(llm.Model)
                && llmConfig.raw_properties.Type.equals(llm.Type)) {

                return llmConfig.id;
            }

        }
        Log.e(TAG, "getLLMID null ");
        return null;
    }

    //从请求回包获取 tts
    public TTSConfig getTTS(TTSData tts) {
        TTSConfig result = null;
        for (TTSConfig ttsconfig : appExtraConfig.tts_list) {
            if (ttsconfig.raw_properties.Type.equals(tts.Type)) {

                result = ttsconfig;
                break;
            }
        }
        if (result == null) {
            Timber.d("getTTS return null, TTSData: " + tts);
        }
        return result;
    }

    //从请求回包获取 voiceid
    public String getVoiceID(TTSConfig ttsConfig, TTSData tts) {
        String result = null;
        for (VoiceConfig voiceConfig : ttsConfig.voice_list) {
            if (voiceConfig.id.equals(tts.Voice)) {
                result = voiceConfig.id;
                break;
            }
        }
        if (result == null) {
            Timber.d("getVoiceID return null, TTSData: " + tts);
        }
        return result;
    }

    //从请求回包获取 languageid
    public String getLanguageID(TTSConfig ttsConfig, TTSData tts) {
        String result = null;
        for (VoiceConfig voiceConfig : ttsConfig.voice_list) {
            if (voiceConfig.id.equals(tts.Voice)) {
                result = voiceConfig.language[0].id;
                break;
            }
        }
        if (result == null) {
            Timber.d("getLanguageID return null, TTSData: " + tts);
        }
        return result;
    }

    /**
     * 当前用户信息
     */
    public static class AppUserInfo {

        public String userID;
        public String userName;
        public String userAvatar;

        /**
         * 生成默认的用户信息，每个手机一个账号
         *
         * @return 用户信息
         */
        public static AppUserInfo getDefaultUserInfo(Context context) {
            AppUserInfo appUserInfo = new AppUserInfo();
            appUserInfo.userID = generateUserID(context, "au_");
            appUserInfo.userName = "user_android";
            appUserInfo.userAvatar = "https://zego-aigc-test.oss-accelerate.aliyuncs.com/airobotdemo/robot_ravatar.png";
            return appUserInfo;
        }

        /**
         * 生成 string 类型 ID
         *
         * @param prefix ID 前缀
         * @return ID
         */
        private static String generateUserID(Context context, String prefix) {
            SharedPreferences sp = context.getSharedPreferences("aicompanion", Context.MODE_PRIVATE);
            String randomID =
                prefix + System.currentTimeMillis() % 1000000 + new Random(System.currentTimeMillis()).nextInt(99);
            String cacheID = sp.getString(prefix, randomID);
            if (cacheID.equals(randomID)) {
                sp.edit().putString(prefix, randomID).apply();
            }
            return cacheID;
        }

        private void clone(AppUserInfo userInfo) {
            this.userID = userInfo.userID;
            this.userName = userInfo.userName;
            this.userAvatar = userInfo.userAvatar;
        }
    }

    /******************************Agent模版请求结果数据结构*************************************/
    public static class AgentRequestConfigList {

        public CustomAgentConfig[] CustomAgentConfigList = null;

        public boolean isValid() {
            return CustomAgentConfigList != null && CustomAgentConfigList.length > 0;
        }
    }

    /*******************************会话请求结果**************************************************/
    public static class ConversationRequestDataList {

        public int Total;
        public Conversation[] ConversationList;

        public boolean isValid() {

            return true;
        }
    }

    /**********************************************************************************************/

    /**
     * 从json文件读取出来的 llm 和 tts 的配置，后续需要从后台拉取
     */
    public static class AppExtraConfig {

        public LLMConfig[] llm_list;
        public TTSConfig[] tts_list;
        public ArrayList<CharacterConfig> character_list = new ArrayList<>();

        public int mCurrentCharacterIndex = 0;

        public boolean isValid() {
            if (llm_list == null || tts_list == null || character_list == null
                || mCurrentCharacterIndex >= character_list.size()) {
                return false;
            }
            for (TTSConfig ttsConfig : tts_list) {
                if (ttsConfig.voice_list == null) {
                    return false;
                }
                for (VoiceConfig voiceConfig : ttsConfig.voice_list) {
                    if (voiceConfig.language == null) {
                        return false;
                    }
                }
            }
            return true;
        }

        public CharacterConfig getCurrentCharacter() {
            if (character_list == null || character_list.isEmpty()) {
                return null;
            }
            return character_list.get(mCurrentCharacterIndex);
        }
    }

    public static class CharacterConfig implements ISelectable {

        public String templateID;                       // 机器人 ID，每个用户的每个角色类型都对应一个机器人 ID，拼装规则类似：kind_userid，防止不同用户使用同一个机器人冲突
        public String name;
        public String avatar;
        public String source;
        public String sex;
        public String intro;

        public String conversationId;  //  _au_8043821_5023964804_and
        public String agentId; //不是模版id, @RBT#_au_8043821_5023964804_and , zim userID,conversationID

        public boolean create = false;
        public boolean isDefault = false;

        public AppCurrentExtraConfig cur_config = new AppCurrentExtraConfig();

        @NonNull
        public CharacterConfig clone() {

            CharacterConfig t = this;

            CharacterConfig c = new CharacterConfig();
            c.templateID = t.templateID;
            c.name = t.name;
            c.avatar = t.avatar;
            c.source = t.source;
            c.sex = t.sex;
            c.intro = t.intro;
            c.conversationId = t.conversationId;
            c.agentId = t.agentId;
            c.create = t.create;
            c.isDefault = t.isDefault;

            c.cur_config.llm_id = t.cur_config.llm_id;
            c.cur_config.tts_id = t.cur_config.tts_id;
            c.cur_config.voice_id = t.cur_config.voice_id;
            c.cur_config.language_id = t.cur_config.language_id;

            return c;
        }

        public CharacterConfig copy(CharacterConfig copy) {

            this.templateID = copy.templateID;
            this.name = copy.name;
            this.avatar = copy.avatar;
            this.source = copy.source;
            this.sex = copy.sex;
            this.intro = copy.intro;
            this.conversationId = copy.conversationId;
            this.agentId = copy.agentId;
            this.create = copy.create;
            this.isDefault = copy.isDefault;

            this.cur_config.llm_id = copy.cur_config.llm_id;
            this.cur_config.tts_id = copy.cur_config.tts_id;
            this.cur_config.voice_id = copy.cur_config.voice_id;
            this.cur_config.language_id = copy.cur_config.language_id;

            return this;
        }

        @Override
        public boolean isSelected() {

            if (conversationId != null
                && ZegoAIAgentConfigController.getConfig().getCurrentCharacter().conversationId != null) {
                return this.conversationId.equals(
                    ZegoAIAgentConfigController.getConfig().getCurrentCharacter().conversationId);
            }
            return false;
        }

        @Override
        public void select() {
            ArrayList<CharacterConfig> characterConfigs = ZegoAIAgentConfigController.getConfig().character_list;
            for (int i = 0; i < characterConfigs.size(); i++) {
                if (characterConfigs.get(i).conversationId != null && conversationId != null) {
                    if (characterConfigs.get(i).conversationId.equals(conversationId)) {
                        ZegoAIAgentConfigController.getConfig().mCurrentCharacterIndex = i;
                        break;
                    }
                }
            }
        }

        @Override
        public String toString() {
            return "CharacterConfig{" + "templateID='" + templateID + '\'' + ", name='" + name + '\'' + ", avatar='"
                + avatar + '\'' + ", source='" + source + '\'' + ", sex='" + sex + '\'' + ", intro='" + intro + '\''
                + ", conversationId='" + conversationId + '\'' + ", agentId='" + agentId + '\'' + ", create=" + create
                + ", isDefault=" + isDefault + ", cur_config=" + cur_config + '}';
        }

        public String getRoomID() {
            return "ar_" + conversationId;
        }

        public String getStreamID() {
            return generateCameraStreamID(getRoomID(), ZegoAIAgentConfigController.getUserInfo().userID);
        }

        public String getAgentStreamID() {
            return generateCameraStreamID(getRoomID(), ZegoAIAgentConfigController.getUserInfo().userID) + "_robot";
        }

        public static String generateCameraStreamID(String roomID, String userID) {
            return roomID + "_" + userID + "_main";
        }

        public Uri getAvatar() {
            if (isDefault) {
                return Uri.parse("file:///android_asset/icon/" + templateID + "/m_avatar_" + templateID + ".png");
            } else {
                return Uri.parse(avatar);
            }
        }

        public Uri getBackground() {
            if (isDefault) {
                return Uri.parse("file:///android_asset/icon/" + templateID + "/m_bg_" + templateID + ".png");
            } else {
                return Uri.parse(avatar);
            }
        }

        public Uri getCalling() {
            if (isDefault) {
                return Uri.parse("file:///android_asset/icon/" + templateID + "/m_calling_" + templateID + ".png");
            } else {
                return Uri.parse(avatar);
            }
        }

        public Uri getEntry() {
            if (isDefault) {
                return Uri.parse("file:///android_asset/icon/" + templateID + "/m_entry_" + templateID + ".png");
            } else {
                return Uri.parse(avatar);
            }
        }
    }

    /**
     * LLM 配置
     */
    public static class LLMConfig implements ISelectable {

        public String id;
        public String name;
        public String icon;
        public boolean is_supported = false;
        public LLMData raw_properties;

        @Override
        public boolean isSelected() {
            return Objects.equals(ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.llm_id, id);
        }

        @Override
        public void select() {
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.updateData(ExtraConfigType.LLM,
                id);
        }
    }

    /**
     * TTS 配置
     */
    public static class TTSConfig implements ISelectable {

        public String id;
        public String name;
        public String icon;
        public boolean is_supported = false;
        public TTSData raw_properties;
        public VoiceConfig[] voice_list;

        @Override
        public boolean isSelected() {
            return ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.tts_id.equals(id);
        }

        @Override
        public void select() {
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.updateData(ExtraConfigType.TTS,
                id);
        }
    }

    /**
     * 音色配置
     */
    public static class VoiceConfig implements ISelectable {

        public String id;
        public String name;
        public LanguageConfig[] language;

        @Override
        public boolean isSelected() {
            return ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.voice_id.equals(id);
        }

        @Override
        public void select() {
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.updateData(ExtraConfigType.VOICE,
                id);
        }
    }

    /**
     * 语言配置，不同音色支持的语言不同
     */
    public static class LanguageConfig implements ISelectable {

        public String id;
        public String name;

        @Override
        public boolean isSelected() {
            return ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.language_id.equals(id);
        }

        @Override
        public void select() {
            ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.updateData(
                ExtraConfigType.LANGUAGE, id);
        }
    }

    /**
     * 当前配置，当前选择哪个 llm / tts / 音色 / 语言 等
     */
    public static class AppCurrentExtraConfig {

        public String llm_id;
        public String tts_id;
        public String voice_id;
        public String language_id;

        private transient final ArrayList<WeakReference<ConfigDataObserver>> mObservers = new ArrayList<>();

        public String toJson() {
            Gson gson = new Gson();
            return gson.toJson(this).replace("\\", "");
        }

        @Override
        public String toString() {
            return "AppCurrentExtraConfig{" + "llm_id='" + llm_id + '\'' + ", tts_id='" + tts_id + '\'' + ", voice_id='"
                + voice_id + '\'' + ", language_id='" + language_id + '\'' + '}';
        }

        public void updateData(ExtraConfigType type, String newData) {
            String oldData = null;
            switch (type) {
                case LLM:
                    oldData = llm_id;
                    llm_id = newData;
                    break;
                case TTS:
                    oldData = tts_id;
                    tts_id = newData;
                    break;
                case VOICE:
                    oldData = voice_id;
                    voice_id = newData;
                    break;
                case LANGUAGE:
                    oldData = language_id;
                    language_id = newData;
                    break;
                default:
                    break;
            }

            if (!newData.equals(oldData)) {
                ArrayList<WeakReference<ConfigDataObserver>> removeObservers = new ArrayList<>();
                for (WeakReference<ConfigDataObserver> observer : mObservers) {
                    ConfigDataObserver o = observer.get();
                    if (o != null) {
                        o.onAppExtraConfigChanged(type, newData, oldData);
                    } else {
                        removeObservers.add(observer);
                    }
                }
                if (!removeObservers.isEmpty()) {
                    mObservers.removeAll(removeObservers);
                }
            }
        }

        /**
         * 监听配置改变
         *
         * @param observer 观察者弱引用
         */
        public void addDataChangedObserver(WeakReference<ConfigDataObserver> observer) {
            mObservers.add(observer);
        }

        /**
         * 获取当前选中的 llm 配置
         *
         * @return 当前选中的 llm 配置
         */
        public LLMConfig getCurrentLLMConfig() {
            AppExtraConfig extraConfig = ZegoAIAgentConfigController.getConfig();
            if (extraConfig != null && extraConfig.llm_list != null) {
                for (LLMConfig llmConfig : extraConfig.llm_list) {
                    if (llmConfig.id.equals(llm_id)) {
                        return llmConfig;
                    }
                }
            }
            return null;
        }

        /**
         * 获取当前 tts 配置
         *
         * @return 当前 tts 配置
         */
        public TTSConfig getCurrentTTSConfig() {
            AppExtraConfig extraConfig = ZegoAIAgentConfigController.getConfig();
            if (extraConfig != null && extraConfig.tts_list != null) {
                for (TTSConfig ttsConfig : extraConfig.tts_list) {
                    if (ttsConfig.id.equals(tts_id)) {
                        return ttsConfig;
                    }
                }
            }
            return null;
        }

        /**
         * 获取当前音色配置
         *
         * @return 当前音色配置
         */
        public VoiceConfig getCurrentVoiceConfig() {
            TTSConfig currentTTSConfig = getCurrentTTSConfig();
            if (currentTTSConfig != null && currentTTSConfig.voice_list != null) {
                for (VoiceConfig voiceConfig : currentTTSConfig.voice_list) {
                    if (voiceConfig.id.equals(voice_id)) {
                        return voiceConfig;
                    }
                }
            }
            return null;
        }

        /**
         * 获取当前语言配置
         *
         * @return 当前语言配置
         */
        public LanguageConfig getCurrentLanguageConfig() {
            VoiceConfig currentVoiceConfig = getCurrentVoiceConfig();
            if (currentVoiceConfig != null && currentVoiceConfig.language != null) {
                for (LanguageConfig languageConfig : currentVoiceConfig.language) {
                    if (languageConfig.id.equals(language_id)) {
                        return languageConfig;
                    }
                }
            }
            return null;
        }
    }

    public enum ExtraConfigType {
        LLM, TTS, VOICE, LANGUAGE,
    }

    public interface ConfigDataObserver {

        void onAppExtraConfigChanged(ExtraConfigType type, String newData, String oldData);
    }

    public interface ISelectable {

        boolean isSelected();

        void select();
    }
}
