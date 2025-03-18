package im.zego.aicompanion.uikit.settings;

import com.tencent.mmkv.MMKV;

public class Storage {

    // 0, alpha , 1 beta,  2, prod
    public static int env() {
        return getInt("env", 2);
    }

    public static void set_env(int value) {
        putInt("env", value);
    }

    public static boolean has_env() {
        return MMKV.defaultMMKV().contains("env");
    }

    public static boolean aec() {
        return getBool("aec", true);
    }

    public static void set_aec(boolean value) {
        putBoolean("aec", value);
    }

    public static boolean agc() {
        return getBool("agc", true);
    }

    public static void set_agc(boolean value) {
        putBoolean("agc", value);
    }

    public static boolean ans() {
        return getBool("ans", true);
    }

    public static void set_ans(boolean value) {
        putBoolean("ans", value);
    }

    //public enum ZegoANSMode {
    //    SOFT(0),
    //    MEDIUM(1),
    //    AGGRESSIVE(2),
    //    AI(3),
    //    AI_BALANCED(4),
    //    AI_LOW_LATENCY(5),
    //    AI_AGGRESSIVE(6);
    public static int ans_mode() {
        return getInt("ans_mode", 4);
    }

    public static void set_ans_mode(int value) {
        putInt("ans_mode", value);
    }

    //  public enum ZegoAECMode {
    //    AGGRESSIVE(0),
    //    MEDIUM(1),
    //    SOFT(2),
    //    AI(3);
    public static int aec_mode() {
        return getInt("aec_mode", 3);
    }

    public static void set_aec_mode(int value) {
        putInt("aec_mode", value);
    }

    public static boolean local_vad() {
        return getBool("local_vad", false);
    }

    public static void set_local_vad(boolean value) {
        putBoolean("local_vad", value);
    }

    public static boolean latency_mode() {
        return getBool("latency_mode", false);
    }

    public static void set_latency_mode(boolean value) {
        putBoolean("latency_mode", value);
    }

    //public enum ZegoAudioDeviceMode {
    //    COMMUNICATION(1),
    //    GENERAL(2),
    //    AUTO(3),
    //    COMMUNICATION2(4),
    //    COMMUNICATION3(5),
    //    GENERAL2(6),
    //    GENERAL3(7),
    //    COMMUNICATION4(8);
    public static int audio_device_mode() {
        return getInt("audio_device_mode", 2);
    }

    private static final String TAG = "Storage";

    public static void set_audio_device_mode(int value) {
        putInt("audio_device_mode", value);
    }

    private static int getInt(String key, int defValue) {
        return MMKV.defaultMMKV().getInt(key, defValue);
    }

    public static void putInt(String key, int defValue) {
        MMKV.defaultMMKV().putInt(key, defValue);
    }

    private static boolean getBool(String key, boolean defValue) {
        return MMKV.defaultMMKV().getBoolean(key, defValue);
    }

    private static void putBoolean(String key, boolean defValue) {
        MMKV.defaultMMKV().putBoolean(key, defValue);
    }

    private static String getString(String key, String defValue) {
        return MMKV.defaultMMKV().getString(key, defValue);
    }

    private static void putString(String key, String defValue) {
        MMKV.defaultMMKV().putString(key, defValue);
    }

    public static void remove(String key) {
        MMKV.defaultMMKV().remove(key);
    }

    public static void removeAll(String key) {
        MMKV.defaultMMKV().clearAll();
    }



}
