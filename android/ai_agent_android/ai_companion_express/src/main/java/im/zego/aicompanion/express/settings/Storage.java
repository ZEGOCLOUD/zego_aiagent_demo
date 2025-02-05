package im.zego.aicompanion.express.settings;

import com.tencent.mmkv.MMKV;

public class Storage {

    // 0, alpha , 1 beta,  2, prod
    public static int env() {
        return getInt("env", 2);
    }

    public static void set_env(int value) {
        putInt("env", value);
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

    public static boolean ai_aggressive() {
        return getBool("ai_aggressive", true);
    }

    public static void set_ai_aggressive(boolean value) {
        putBoolean("ai_aggressive", value);
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

}
