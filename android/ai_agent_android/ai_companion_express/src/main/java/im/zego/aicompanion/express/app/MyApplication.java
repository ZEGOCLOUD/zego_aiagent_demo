package im.zego.aicompanion.express.app;

import android.app.Application;
import android.content.Context;
import android.os.Build;
import android.util.Log;
import com.tencent.mmkv.MMKV;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.AppUserInfo;
import im.zego.aiagent.core.net.NetworkMonitor;
import im.zego.aicompanion.express.ai.ZegoAIAgentExpressHelper;
import im.zego.aicompanion.express.log.Logger;
import im.zego.aicompanion.express.settings.Storage;
import im.zego.zegoexpress.ZegoExpressEngine;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import timber.log.Timber;
import xcrash.ICrashCallback;
import xcrash.XCrash;
import xcrash.XCrash.InitParameters;

public class MyApplication extends Application {

    private NetworkMonitor mNetworkMonitor = new NetworkMonitor();

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        // 日志
        Logger.debugMode(base);

        // 崩溃捕获
        String crashFilesDir = base.getExternalFilesDir(null) + "/crashes";
        ICrashCallback callback = new ICrashCallback() {
            @Override
            public void onCrash(String logPath, String emergency) throws Exception {
                File file = new File(logPath);
                String originalName = file.getName();

                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm");
                String formattedDate = dateFormat.format(new Date());
                File newFile = new File(crashFilesDir, formattedDate + "_" + originalName);
                boolean renameTo = file.renameTo(newFile);

                Timber.d(
                    "onCrash() called ,logPath:" + logPath + ",renameTo = [" + newFile.getName() + "], successed = ["
                        + renameTo + "]");
            }
        };
        XCrash.init(this, new InitParameters().setLogDir(crashFilesDir).setJavaRethrow(true).setJavaLogCountMax(10)
            .setJavaCallback(callback).setAnrCallback(callback).setNativeCallback(callback).setAnrLogCountMax(10));
        // 序列化
        MMKV.initialize(base);
    }

    @Override
    public void onCreate() {
        super.onCreate();

        mNetworkMonitor.startNetworkCallback(this);

        Timber.d("init() called with: Build.MANUFACTURER = [" + Build.MANUFACTURER + "], Build.VERSION.SDK_INT = ["
            + Build.VERSION.SDK_INT + "],targetSdkVersion:" + getApplicationInfo().targetSdkVersion
            + ",ZegoExpressEngine version:" + ZegoExpressEngine.getVersion());

        Timber.w("App Env = " + Storage.env());

        long appID = AiCompanionConfig.getAppID();
        String appSign = AiCompanionConfig.getAppSign();
        String serverSecret = AiCompanionConfig.getServerSecret();

        AppUserInfo defaultUserInfo = AppUserInfo.getDefaultUserInfo(this);

        ZegoAIAgentExpressHelper.getInstance()
            .initAICompanion(this, appID, appSign, serverSecret, defaultUserInfo.userID, defaultUserInfo.userName,
                defaultUserInfo.userAvatar);
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        mNetworkMonitor.stopNetworkCallback(this);

    }
}
