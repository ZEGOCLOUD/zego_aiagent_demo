package im.zego.aiagent.core.utils;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.res.AssetManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Random;

public class Utils {

    public static int dp2px(float v, DisplayMetrics displayMetrics) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, displayMetrics);
    }

    public static int sp2px(float v, DisplayMetrics displayMetrics) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, v, displayMetrics);
    }

    public static String generateRandomString(int length) {
        StringBuilder builder = new StringBuilder();
        Random random = new Random();
        while (builder.length() < length) {
            int nextInt = random.nextInt(10);
            if (builder.length() == 0 && nextInt == 0) {
                continue;
            }
            builder.append(nextInt);
        }
        return builder.toString();
    }

    private static String getLauncherActivity(Context context) {
        Intent intent = new Intent(Intent.ACTION_MAIN, null);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.setPackage(context.getPackageName());
        PackageManager pm = context.getPackageManager();
        List<ResolveInfo> info = pm.queryIntentActivities(intent, 0);
        if (info == null || info.size() == 0) {
            return "";
        }
        return info.get(0).activityInfo.name;
    }

    public static void startLauncherActivity(Context context) {
        Intent appIntent = new Intent();
        try {
            appIntent = new Intent(context, Class.forName(getLauncherActivity(context)));
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        context.startActivity(appIntent);
    }

    private static final String TAG = "Utils";
    /**
     * 从 assets 拷贝文件到 getExternalFilesDir(null) 目录
     *
     * @param context        上下文
     * @param assetFileName  assets 中的文件名
     * @param targetFileName 目标文件名（如果为 null，则使用 assetFileName）
     * @return 是否拷贝成功
     */
    public static boolean copyAssetToAppExternalFiles(Context context, String assetFileName, String targetFileName) {
        if (assetFileName == null || assetFileName.trim().isEmpty()) {
            Log.e(TAG, "Asset file name cannot be null or empty");
            return false;
        }

        AssetManager assetManager = context.getAssets();
        File targetDir = context.getExternalFilesDir(null); // 获取 /sdcard/Android/data/<package_name>/files 目录
        if (targetDir == null) {
            Log.e(TAG, "External files directory is not available");
            return false;
        }

        // 如果目标文件名为空，则使用 assets 文件名
        String finalTargetFileName = (targetFileName == null || targetFileName.trim().isEmpty())
            ? assetFileName : targetFileName;
        File targetFile = new File(targetDir, finalTargetFileName);

        if (targetFile.exists()) {
            Log.d(TAG, "File already exists: " + targetFile.getAbsolutePath());
            return true; // 文件已存在，直接返回成功
        }

        // 确保目标目录存在
        if (!targetDir.exists()) {
            if (!targetDir.mkdirs()) {
                Log.e(TAG, "Failed to create directory: " + targetDir.getAbsolutePath());
                return false;
            }
        }

        // 复制文件
        try (InputStream inputStream = assetManager.open(assetFileName);
            OutputStream outputStream = new FileOutputStream(targetFile)) {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, read);
            }
            Log.d(TAG, "File copied successfully to: " + targetFile.getAbsolutePath());
            return true;
        } catch (IOException e) {
            Log.e(TAG, "Failed to copy file: " + e.getMessage());
            return false;
        }
    }
}
