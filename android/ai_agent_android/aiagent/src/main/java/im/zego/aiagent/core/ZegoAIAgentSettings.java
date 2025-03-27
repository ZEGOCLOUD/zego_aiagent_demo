package im.zego.aiagent.core;

import im.zego.zegoexpress.constants.ZegoAECMode;
import im.zego.zegoexpress.constants.ZegoANSMode;
import im.zego.zegoexpress.constants.ZegoAudioDeviceMode;
import im.zego.zegoexpress.constants.ZegoScenario;

public class ZegoAIAgentSettings {

    public static boolean AEC = true;
    public static boolean AGC = true;
    public static boolean ANS = true;
    public static int ANS_MODE = ZegoANSMode.AI_BALANCED.value();
    public static int AEC_MODE = ZegoAECMode.AI.value();
    public static int SCENARIO = ZegoScenario.HIGH_QUALITY_CHATROOM.value();
    public static int AUDIO_DEVICE_MODE = ZegoAudioDeviceMode.GENERAL.value();
    public static boolean LOCAL_VAD = false;
    public static boolean Latency_Mode = false;
    public static int AUDIO_DUCK = 1;
    public static boolean VOLUME_ADAPTIVE = true;
    public static int mediaPlayerVolume = 80;
    public static int playStreamVolume = 100;
    public static boolean defaultShowTestView = false;
    public static boolean autoDump = false;
    public static boolean autoPlayAcc = false;
}
