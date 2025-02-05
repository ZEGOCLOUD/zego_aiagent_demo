package im.zego.aiagent.core.utils;

import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.UUID;

public class PhotoGallery {

    /**
     * 图片是不是大于10M
     *
     * @param context
     * @param uri
     * @return
     */
    public static boolean isImageSizeLessThan10MB(Context context, Uri uri) {
        Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
        if (cursor != null) {
            int sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE);
            cursor.moveToFirst();
            long sizeInBytes = cursor.getLong(sizeIndex);
            cursor.close();

            return sizeInBytes <= 10 * 1024 * 1024;
        }
        return false;
    }

    public static int getRotationAngle(String imagePath) {
        int rotation = 0;
        try {
            ExifInterface exif = new ExifInterface(imagePath);
            int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    rotation = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    rotation = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    rotation = 270;
                    break;
                default:
                    rotation = 0;
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rotation;
    }

    /**
     * 获取相册图片， 保存到本地， 相册图片的地址不能随意获取
     *
     * @param context
     * @param uri
     * @param destinationDirectory
     * @return
     * @throws IOException
     */
    public static String saveUriToFile(Context context, Uri uri, String destinationDirectory) {
        ContentResolver contentResolver = context.getContentResolver();
        String filePath = null;
        File destinationFile = null;
        // 获取文件扩展名
        String extension = getFileExtension(context, uri);
        if (extension == null) {
            extension = ""; // 如果无法获取扩展名，可以留空或设置默认
        }

        File dir = new File(destinationDirectory);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        // 生成唯一文件名
        String uniqueFileName = "file_" + UUID.randomUUID() + extension;
        destinationFile = new File(destinationDirectory, uniqueFileName);

        // 使用 try-with-resources 确保资源被正确关闭
        try (InputStream inputStream = contentResolver.openInputStream(
            uri); FileOutputStream outputStream = new FileOutputStream(destinationFile)) {

            if (inputStream == null) {
                return null;
            }

            byte[] buffer = new byte[1024];
            int length;
            while ((length = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, length);
            }

            outputStream.flush();
            filePath = destinationFile.getAbsolutePath();
        } catch (IOException e) {
            // 记录错误信息，或者处理异常
            Log.e("saveUriToFile", "Error saving file", e);
            // 可以选择在这里抛出一个运行时异常，让调用者处理
        }

        return filePath;
    }

    public static Bitmap rotateBitmap(Bitmap bitmap, int degrees) {
        if (degrees == 0 || bitmap == null) {
            return bitmap; // 无需旋转，直接返回
        }
        Matrix matrix = new Matrix();
        matrix.postRotate(degrees); // 设置旋转角度
        try {
            Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix,
                true);
            return rotatedBitmap; // 返回旋转后的 Bitmap
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
            return bitmap; // 如果内存不足，返回原图
        }
    }

    public static void saveBitmapToFile(Bitmap bitmap, String outputPath, Bitmap.CompressFormat format, int quality)
        throws IOException {
        FileOutputStream out = null;
        try {
            File file = new File(outputPath);
            if (!file.exists()) {
                file.getParentFile().mkdirs(); // 创建目录
                file.createNewFile(); // 创建文件
            }

            out = new FileOutputStream(file);
            bitmap.compress(format, quality, out); // 保存图片
            out.flush(); // 确保写入磁盘
        } finally {
            if (out != null) {
                out.close();
            }
        }
    }

    /**
     * 旋转
     *
     * @param imagePath
     * @return
     */
    public static Bitmap checkRotateImage(String imagePath) {
        // 1. 从路径加载图片
        Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
        try {

            // 2. 获取图片的旋转角度
            int rotation = getRotationAngle(imagePath);

            // 3. 如果需要旋转，应用旋转
            if (rotation != 0) {
                bitmap = rotateBitmap(bitmap, rotation);
            }

            // 4. 保存旋转后的图片到原路径
            if (imagePath.toLowerCase().endsWith(".png")) {
                saveBitmapToFile(bitmap, imagePath, Bitmap.CompressFormat.PNG, 90);
            } else if (imagePath.toLowerCase().endsWith(".jpg") || imagePath.toLowerCase().endsWith(".jpeg")) {
                saveBitmapToFile(bitmap, imagePath, Bitmap.CompressFormat.JPEG, 90);
            } else {
                Log.e("PhotoGallery", "createBitmapByRotate unknow pic format,");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return bitmap;
    }

    //检测有效格式， png, jpg
    public static boolean isSupportedImage(Context context, Uri uri) {
        String lowerCaseFileName = getFileExtension(context, uri).toLowerCase();
        if (lowerCaseFileName.endsWith(".png") || lowerCaseFileName.endsWith(".jpg") || lowerCaseFileName.endsWith(
            ".jpeg")) {
            return true;
        }
        return false;
    }

    // 获取文件扩展名的方法
    public static String getFileExtension(Context context, Uri uri) {
        String extension = null;

        // 尝试使用 MIME type 获取文件扩展名
        String mimeType = context.getContentResolver().getType(uri);
        if (mimeType != null) {
            extension = "." + mimeType.split("/")[1];
        } else {
            // 如果 MIME type 不可用，则尝试从文件名获取
            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                @SuppressLint("Range") String displayName = cursor.getString(
                    cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                if (displayName != null && displayName.contains(".")) {
                    extension = displayName.substring(displayName.lastIndexOf("."));
                }
                cursor.close();
            }
        }
        return extension;
    }
}
