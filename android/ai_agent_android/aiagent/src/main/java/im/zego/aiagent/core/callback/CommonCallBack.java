package im.zego.aiagent.core.callback;

public interface CommonCallBack {
    void onSuccess(Object data);

    void onFailed(int errorCode, String errorMsg);
}

