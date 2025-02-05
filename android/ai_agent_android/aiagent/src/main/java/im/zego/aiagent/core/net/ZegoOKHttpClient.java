package im.zego.aiagent.core.net;

import android.annotation.SuppressLint;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.gson.Gson;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.AIAgentCommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.data.ImageUrlData;
import java.io.File;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.HttpUrl;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import org.json.JSONObject;
import timber.log.Timber;

@SuppressLint("LogNotTimber")
public class ZegoOKHttpClient {

    public static final int ERROR_RESPONSE_EMPTY = -1;
    public static final int ERROR_JSON_FORMAT_INVALID = -2;
    public static final int ERROR_NETWORK_FAILED = -3;
    private volatile static ZegoOKHttpClient instance;
    private final OkHttpClient mOkHttpClient;

    private ZegoOKHttpClient() {
        OkHttpClient.Builder builder = new OkHttpClient.Builder().connectTimeout(15, TimeUnit.SECONDS)
            .writeTimeout(20, TimeUnit.SECONDS).readTimeout(20, TimeUnit.SECONDS);
        mOkHttpClient = builder.build();
    }

    public static ZegoOKHttpClient getInstance() {
        if (instance == null) {
            synchronized (ZegoOKHttpClient.class) {
                if (instance == null) {
                    instance = new ZegoOKHttpClient();
                }
            }
        }
        return instance;
    }

    private static final String TAG = "HttpConnection";
    private static final String BASE_URL_TEST = "https://aigc-chat-api.zegotech.cn";
    private static final String BASE_URL_RELEASE = "https://aigc-chat-api.zegotech.cn";
    private static final boolean IS_RELEASE = false;

    private final Gson mGson = new Gson();
    private final Handler mUIHandler = new Handler(Looper.getMainLooper());

    private static final String BASE_URL_TEST_ALIYUN_OSS = "https://zego-aigc-test.oss-accelerate.aliyuncs.com/";
    private static final String BASE_URL_RELEASE_ALIYUN_OSS = "https://zego-aigc-test.oss-accelerate.aliyuncs.com/";

    /**
     * 字节数组转 16 进制
     *
     * @param bytes 需要转换的 byte 数组
     * @return 转换后的 Hex 字符串
     */
    private static String bytesToHex(byte[] bytes) {
        StringBuffer md5str = new StringBuffer();
        //把数组每一字节换成 16 进制连成 md5 字符串
        int digital;
        for (int i = 0; i < bytes.length; i++) {
            digital = bytes[i];
            if (digital < 0) {
                digital += 256;
            }
            if (digital < 16) {
                md5str.append("0");
            }
            md5str.append(Integer.toHexString(digital));
        }
        return md5str.toString();
    }

    // Signature=md5(AppId + SignatureNonce + ServerSecret + Timestamp)
    private static String GenerateSignature(long appId, String signatureNonce, String serverSecret, long timestamp) {
        String str = String.valueOf(appId) + signatureNonce + serverSecret + String.valueOf(timestamp);
        String signature = "";
        try {
            //创建一个提供信息摘要算法的对象，初始化为 md5 算法对象
            MessageDigest md = MessageDigest.getInstance("MD5");
            //计算后获得字节数组
            byte[] bytes = md.digest(str.getBytes("utf-8"));
            //把数组每一字节换成 16 进制连成 md5 字符串
            signature = bytesToHex(bytes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return signature;
    }

    private static String getRequestUrl(String action) {
        String baseURI = IS_RELEASE ? BASE_URL_RELEASE : BASE_URL_TEST;
        //生成 16 进制随机字符串(16位)
        byte[] bytes = new byte[8];
        //使用SecureRandom获取高强度安全随机数生成器
        SecureRandom sr = new SecureRandom();
        sr.nextBytes(bytes);
        String signatureNonce = bytesToHex(bytes);
        long timestamp = System.currentTimeMillis() / 1000L;

        long appID = ZegoAIAgentConfigController.getInstance().appID;
        String serverSecret = ZegoAIAgentConfigController.getInstance().serverSecret;
        String signature = GenerateSignature(appID, signatureNonce, serverSecret, timestamp);

        HttpUrl.Builder urlBuilder = HttpUrl.parse(baseURI).newBuilder().addQueryParameter("Action", action)
            .addQueryParameter("AppId", String.valueOf(appID)).addQueryParameter("SignatureNonce", signatureNonce)
            .addQueryParameter("Timestamp", String.valueOf(timestamp)).addQueryParameter("Signature", signature)
            .addQueryParameter("SignatureVersion", "2.0");

        // 获取完整的 URL 字符串
        String url = urlBuilder.build().toString();
        return url;
    }

    // 使用 ContentResolver 获取文件的 MIME 类型
    private static String getMimeType(File file) {
        Uri fileUri = Uri.fromFile(file);
        String extension = MimeTypeMap.getFileExtensionFromUrl(fileUri.toString());
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase());
    }

    public void asyncPostImageAliyun(ImageUrlData imageData, String filePath, AIAgentCallBack callBack) {

        String baseURI = IS_RELEASE ? BASE_URL_TEST_ALIYUN_OSS : BASE_URL_RELEASE_ALIYUN_OSS;

        // 指定文件路径
        File file = new File(filePath);
        // 检测文件的 MIME 类型
        String mimeType = getMimeType(file);

        // 设置默认 MIME 类型（如果无法检测到）
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }

        // 创建 MultipartBody 请求体
        RequestBody requestBody = new MultipartBody.Builder().setType(MultipartBody.FORM)
            .addFormDataPart("bucket", imageData.FormData.bucket).addFormDataPart("key", imageData.FormData.key)
            .addFormDataPart("policy", imageData.FormData.policy)
            .addFormDataPart("x-amz-algorithm", imageData.FormData.x_amz_algorithm)
            .addFormDataPart("x-amz-credential", imageData.FormData.x_amz_credential)
            .addFormDataPart("x-amz-signature", imageData.FormData.x_amz_signature)
            .addFormDataPart("x-amz-date", imageData.FormData.x_amz_date)
            .addFormDataPart("file", file.getName(), RequestBody.create(file, MediaType.parse(mimeType))).build();

        // 发起请求并处理响应
        asyncPostRequest(baseURI, requestBody, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Timber.w(
                    "asyncPost onFailure() called with: call = [" + call.request() + "], e = [" + e.getMessage() + "]");
                mUIHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callBack != null) {
                            callBack.onResult(-99999, "aliyun post image failed:" + e.getMessage());
                        }
                    }
                });
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                mUIHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (response.isSuccessful()) {
                            if (callBack != null) {
                                callBack.onResult(0, "");
                            }
                        } else {
                            if (callBack != null) {
                                callBack.onResult(response.code(), response.message());
                            }
                        }
                    }
                });
            }
        });
    }

    private void asyncPostRequest(String url, RequestBody requestBody, Callback callback) {
        Request request = new Request.Builder().url(url).post(requestBody).build();

        ZegoOKHttpClient.getInstance().mOkHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NonNull Call call, @NonNull IOException e) {
                if (callback != null) {
                    callback.onFailure(call, e);
                }
            }

            @Override
            public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {
                if (callback != null) {
                    callback.onResponse(call, response);
                }
            }
        });
    }

    /**
     * @param action      动作
     * @param jsonString  请求体 json格式
     * @param classType   不需要的话，传 null 或者 Object.class
     * @param reqCallback
     * @param <T>
     */
    public <T> void asyncPostJsonRequest(String action, String jsonString, Class<T> classType,
        @Nullable AIAgentCommonCallBack<T> reqCallback) {
        String url = getRequestUrl(action);
        MediaType JSON = MediaType.parse("application/json; charset=utf-8");
        RequestBody requestBody = RequestBody.create(jsonString, JSON);

        Timber.d("postJsonRequest,json: " + jsonString + ", url: " + url);
        asyncPostRequest(url, requestBody, new Callback() {
            @Override
            public void onFailure(@NonNull Call call, @NonNull IOException e) {
                Timber.w(
                    "asyncPost onFailure() called with: call = [" + call.request() + "], e = [" + e.getMessage() + "]");
                if (reqCallback != null) {
                    mUIHandler.post(
                        () -> reqCallback.onCallback(ERROR_NETWORK_FAILED, "Network Error: " + e.getMessage(), null));
                }
            }

            @Override
            public void onResponse(@NonNull Call call, @NonNull Response response) throws IOException {

                String str;
                if (response.body() == null) {
                    Timber.w("postJsonRequest response.body() is null,action:[" + action + "]");
                    if (reqCallback != null) {
                        mUIHandler.post(
                            () -> reqCallback.onCallback(ERROR_RESPONSE_EMPTY, "Response Body Empty", null));
                    }
                    return;
                }
                try {
                    str = response.body().string();
                    Timber.d("postJsonRequest response.body().string() = [" + str + "]" + "post json: " + jsonString
                        + ", post action: " + action);
                } catch (Exception e) {
                    Timber.w("postJsonRequest response parse response.body().string() Exception");
                    if (reqCallback != null) {
                        mUIHandler.post(() -> reqCallback.onCallback(ERROR_RESPONSE_EMPTY,
                            "parse response.body().string() Exception", null));
                    }
                    return;
                }

                try {
                    JSONObject jsonObject = new JSONObject(str);
                    final int code = jsonObject.getInt("Code");
                    final String message = jsonObject.getString("Message");

                    T t;
                    if (classType == null || classType == Object.class) {
                        t = null;
                    } else {
                        JSONObject data = jsonObject.getJSONObject("Data");
                        t = mGson.fromJson(data.toString(), classType);
                    }
                    if (reqCallback != null) {
                        mUIHandler.post(() -> reqCallback.onCallback(code, message, t));
                    }
                    Timber.d("postJsonRequest response called with: code = [" + code + "], message = [" + message
                        + "], t = [" + t + "], action = [" + action + "]");
                } catch (Exception jsonException) {
                    if (reqCallback != null) {
                        mUIHandler.post(
                            () -> reqCallback.onCallback(ERROR_JSON_FORMAT_INVALID, "Json Parse Error", null));
                    }
                }
            }
        });
    }
}
