package im.zego.aicompanion.express.app;


import im.zego.aicompanion.express.settings.Storage;

// 联系 ZEGO 技术支持获取相关配置
public class AiCompanionConfig {

    static class Alpha {

        //mEnv 0
        public static long appID = ;
        public static String appSign = ;
        public static String serverSecret = ;

    }


    static class Beta {

        //mEnv 1
        public static long appID = ;
        public static String serverSecret = ;
        public static String appSign = ;

    }

    static class Prod {

        //mEnv 2
        public static long appID = ;
        public static String serverSecret = ;
        public static String appSign = ;

    }


    static class Delta {

        //mEnv 3
        public static long appID = ;
        public static String serverSecret = ;
        public static String appSign = ;

    }

    static class Gamma {

        //mEnv 4
        public static long appID = ;
        public static String serverSecret = ;
        public static String appSign = ;

    }

    public static long getAppID() {
        int env = Storage.env();
        if (env == 0) {
            return Alpha.appID;
        } else if (env == 1) {
            return Beta.appID;
        } else if (env == 3) {
            return Delta.appID;
        } else if (env == 4) {
            return Gamma.appID;
        } else {
            return Prod.appID;
        }
    }

    public static String getServerSecret() {
        int env = Storage.env();
        if (env == 0) {
            return Alpha.serverSecret;
        } else if (env == 1) {
            return Beta.serverSecret;
        } else if (env == 3) {
            return Delta.serverSecret;
        } else if (env == 4) {
            return Gamma.serverSecret;
        } else {
            return Prod.serverSecret;
        }
    }

    public static String getAppSign() {
        int env = Storage.env();
        if (env == 0) {
            return Alpha.appSign;
        } else if (env == 1) {
            return Beta.appSign;
        } else if (env == 3) {
            return Delta.appSign;
        } else if (env == 4) {
            return Gamma.appSign;
        } else {
            return Prod.appSign;
        }
    }
}
