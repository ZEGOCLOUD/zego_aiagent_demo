package im.zego.aiagent.core;

import android.app.Activity;
import android.app.Application;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.FileProvider;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentMonitor;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallProxy;
import im.zego.aiagent.core.utils.JsonUtils;
import im.zego.aiagent.core.utils.ToastUtils;
import im.zego.aiagent.core.utils.ZipUtils;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import timber.log.Timber;

public class ZegoAIAgentHelper {

    private static final String TAG = "ZegoAIAgentHelper";
    private static ZegoVoiceCallProxy voiceCallProxy;
    private static ZegoIMProxy imProxy;

    /**
     * 初始化 AI 陪伴服务 初始化时需要填入用户账号信息，用户需要确保 userID 唯一
     *
     * @param application  安卓 application
     * @param appID        app id
     * @param appSign      app sign
     * @param serverSecret 服务key
     * @param userID       用户 ID
     * @param userName     用户名称
     * @param userAvatar   用户头像
     */
    public static void initAICompanion(Application application, long appID, String appSign, String serverSecret,
        String userID, String userName, String userAvatar) {

        Timber.d("init() called with: appID = [" + appID + "], userID = [" + userID + "],userName:" + userName
            + ",userAvatar:" + userAvatar);

        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.AppInit_Start);

        // 初始化 app 设置
        ZegoAIAgentConfigController.init(application, appID, appSign, serverSecret);

        ZegoAIAgentConfigController.AppUserInfo userInfo = new ZegoAIAgentConfigController.AppUserInfo();
        userInfo.userID = userID;
        userInfo.userName = userName;
        userInfo.userAvatar = userAvatar;
        ZegoAIAgentConfigController.getInstance().setUserInfo(userInfo);

        // 初始化 IMKit
        if (imProxy != null) {
            imProxy.initIM(application);
        }

        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.AppInit_Finish);
    }

    /**
     * 反初始化AI陪伴相关设置
     **/
    public static void unInitAICompanion() {
        if (imProxy != null) {
            imProxy.unInitIM();
        }
        if (voiceCallProxy != null) {
            voiceCallProxy.destroyEngine();
        }
    }

    /**
     * 主要做了： 1. 加载本地 llm 和 tts 配置 2. 向后台请求AI角色配置 3. 向后台请求会话列表，并且根据AI角色配置，按需创建会话或者更新会话
     *
     * @param cb 拉取回调，成功：返回当前支持的角色列表，失败：返回错误码和错误信息
     */
    public static void requestAppConfigAndGetConversation(Context context,
        AIAgentCommonCallBack<ArrayList<ZegoAIAgentConfigController.CharacterConfig>> cb) {
        // 加载本地 llm 和 tts 配置
        String json = JsonUtils.loadJSONFromAsset(context, "AIAgentConfig.json");
        ZegoAIAgentConfigController.getInstance().initAppConfigFromJson(json);

        ZegoAIAgentConfigController.getInstance().requestAgentConfigAndGetConversation(new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (cb != null) {
                    cb.onCallback(0, "", ZegoAIAgentConfigController.getConfig().character_list);
                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                if (cb != null) {
                    cb.onCallback(errorCode, errorMsg, null);
                }
            }
        });

    }

    /**
     * 登陆 ZIM
     */
    public static void loginZIM(AIAgentCallBack callBack) {
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.LoginZIM_Start);
        String userID = ZegoAIAgentConfigController.getUserInfo().userID;
        String userName = ZegoAIAgentConfigController.getUserInfo().userName;
        String userAvatar = ZegoAIAgentConfigController.getUserInfo().userAvatar;
        if (imProxy != null) {
            imProxy.loginIMUser(userID, userName, userAvatar, (errorCode, message) -> {
                if (errorCode == 0) {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.LoginZIM_Success);
                } else {
                    ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.LoginZIM_Failed);
                }
                if (callBack != null) {
                    callBack.onResult(errorCode, message);
                }
            });
        } else {
            if (callBack != null) {
                callBack.onResult(-1, "NO ZIMKit ERROR");
            }
        }
    }

    /**
     * 登出 ZIM
     */
    public static void logoutZIMUser() {
        if (imProxy != null) {
            imProxy.logoutIMUser();
        }
    }

    /**
     * 启动聊天页面
     *
     * @param activity    当前 activity
     * @param requestCode 启动参数，AI Agent 会以该参数启动消息页面，应用需要监听 onActivityResult 对应的 requestCode 后调用 @see
     *                    #{onMessageActivityResult} 函数
     * @param character   待聊天的 AI 角色
     */
    public static void startMessageActivity(Activity activity, int requestCode,
        ZegoAIAgentConfigController.CharacterConfig character) {
        character.select();
        ZegoAIAgentConfigController.CharacterConfig characterConfig = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();
        ZegoAIAgentRequest.requestCreateConversation(characterConfig, new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                if (imProxy != null) {
                    loginZIM(new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            if (errorCode == 0) {
                                imProxy.jumpToMessageActivity(activity, requestCode,
                                    ZegoAIAgentConfigController.getConfig().getCurrentCharacter().agentId,
                                    ZegoAIAgentConfigController.getConfig().getCurrentCharacter().name,
                                    ZegoAIAgentConfigController.getConfig().getCurrentCharacter().avatar);
                            } else {
                                ToastUtils.show("loginZIM 错误: + message");
                            }
                        }
                    });
                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                Toast.makeText(activity, "requestCreateConversation 错误: " + errorMsg, Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * 离开聊天页面，做必要的清理工作
     */
    public static void onMessageActivityResult() {
        // 1. 退出 zim
        logoutZIMUser();

        // 3. 重置 AppMonitor，打印生命周期
        ZegoAIAgentMonitor.getInstance().report(ZegoAIAgentMonitor.AppState.LeaveMessageActivity);
        ZegoAIAgentMonitor.getInstance().printAll();
        ZegoAIAgentMonitor.getInstance().reset();
    }

    public static void shareLogFiles(Context context) {
        List<String> logPaths = getLogFilePaths(context);
        File zipFile = new File(createZipFile(context, logPaths));

        if (zipFile.exists()) {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("application/zip");

            Uri contentUri;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                String authority = context.getPackageName() + ".aiAgent.fileProvider";
                contentUri = FileProvider.getUriForFile(context, authority, zipFile);
                context.grantUriPermission(context.getPackageName(), contentUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } else {
                contentUri = Uri.fromFile(zipFile);
            }
            intent.putExtra(Intent.EXTRA_STREAM, contentUri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            context.startActivity(Intent.createChooser(intent, "分享文件"));

        } else {
            ToastUtils.show("分享文件不存在");
        }
    }

    public static void showAppLog(Context context) {
        File externalFilesDir = context.getExternalFilesDir(null);
        String uikitLogs = externalFilesDir + File.separator + "uikit_log";
        showFileListDialog(context, uikitLogs, "app日志目录");
    }

    public static void showCrashLog(Context context) {
        File externalFilesDir = context.getExternalFilesDir(null);
        String crashLogs = externalFilesDir + File.separator + "crashes";
        showFileListDialog(context, crashLogs, "崩溃堆栈目录");
    }

    private static void showFileListDialog(Context context, String dirPath, String title) {
        String[] files = getFileList(dirPath);
        AlertDialog.Builder builder = new AlertDialog.Builder(context);

        int index = dirPath.indexOf("files");
        String localPath = dirPath.substring(index);
        builder.setTitle(title + ": " + "\n包名/" + localPath + "/");

        if (files.length == 0) {
            builder.setMessage("当前目录下没有文件");
        } else {
            // 设置列表项点击事件
            builder.setItems(files, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    String selectedFile = files[which];

                    File file = new File(dirPath, selectedFile);
                    String originalName = file.getName();

                    File newFile;
                    if (!originalName.endsWith(".txt")) {
                        newFile = new File(dirPath, originalName + ".txt");
                        file.renameTo(newFile);
                    } else {
                        newFile = file;
                    }

                    String authority = context.getPackageName() + ".aiAgent.fileProvider";
                    Uri uri = FileProvider.getUriForFile(context, authority, newFile);
                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.setDataAndType(uri, "text/plain");
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

                    try {
                        context.startActivity(intent);
                    } catch (ActivityNotFoundException e) {
                        ToastUtils.show("无法打开文本文件，没有可用的应用");
                    }
                }
            });
        }

        // 创建并显示对话框
        builder.create().show();
    }

    private static String[] getFileList(String dirPath) {
        File directory = new File(dirPath);
        File[] files = directory.listFiles();
        if (files != null) {
            return Arrays.stream(files).map(File::getName).toArray(String[]::new);
        }
        return new String[0];
    }

    public static void deleteLogFiles(Context context) {
        List<String> logPaths = getLogFilePaths(context);
        for (String logPath : logPaths) {
            deleteFileOrDirectory(new File(logPath));
        }
    }

    private static String createZipFile(Context context, List<String> files) {
        String outputZipFilePath = context.getExternalFilesDir(null) + File.separator + "zegolog.zip";
        Timber.d("createZipFile() called with: files = [" + files + "],zipFile:" + outputZipFilePath);

        File zipFile = new File(outputZipFilePath);
        if (zipFile.exists()) {
            zipFile.delete();
        }
        ZipUtils.createZipFile(files, outputZipFilePath);
        return outputZipFilePath;
    }

    private static @NonNull List<String> getLogFilePaths(Context context) {
        File externalFilesDir = context.getExternalFilesDir(null);

        String uikitLogs = externalFilesDir + File.separator + "uikit_log";
        String zimLogs = externalFilesDir + File.separator + "ZIMLogs";
        String crashFiles = externalFilesDir + File.separator + "crashes";
        List<String> expressLogs = ZipUtils.findFilesWithPrefix(externalFilesDir.getAbsolutePath(), "zegoavlog");

        List<String> logPaths = new ArrayList<>();
        logPaths.add(uikitLogs);
        logPaths.add(zimLogs);
        logPaths.add(crashFiles);
        if (!expressLogs.isEmpty()) {
            logPaths.addAll(expressLogs);
        }
        return logPaths;
    }

    private static void deleteFileOrDirectory(File fileOrDirectory) {
        // 检查是否是一个文件
        if (fileOrDirectory.isFile()) {
            // 如果是文件，直接删除
            boolean success = fileOrDirectory.delete();
            if (!success) {
                // 日志记录或异常处理：文件删除失败
                System.out.println("Failed to delete file: " + fileOrDirectory.getAbsolutePath());
            }
        } else if (fileOrDirectory.isDirectory()) {
            // 如果是目录，递归删除目录中的所有文件和子目录
            File[] files = fileOrDirectory.listFiles();
            if (files != null) {
                for (File file : files) {
                    deleteFileOrDirectory(file); // 递归调用
                }
            }
            // 删除目录本身
            boolean success = fileOrDirectory.delete();
            if (!success) {
                // 日志记录或异常处理：目录删除失败
                System.out.println("Failed to delete directory: " + fileOrDirectory.getAbsolutePath());
            }
        } else {
            // 日志记录或异常处理：给定的路径不存在
            System.out.println("The file or directory does not exist: " + fileOrDirectory.getAbsolutePath());
        }
    }

    public static void setVoiceCallProxy(ZegoVoiceCallProxy voiceCallProxy) {
        ZegoAIAgentHelper.voiceCallProxy = voiceCallProxy;
    }

    public static ZegoVoiceCallProxy getVoiceCallProxy() {
        return voiceCallProxy;
    }

    public static ZegoIMProxy getImProxy() {
        return imProxy;
    }

    public static void setImProxy(ZegoIMProxy imProxy) {
        ZegoAIAgentHelper.imProxy = imProxy;
    }
}
