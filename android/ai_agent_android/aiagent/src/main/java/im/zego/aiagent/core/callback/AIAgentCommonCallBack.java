package im.zego.aiagent.core.callback;

public interface AIAgentCommonCallBack<T> {

    void onCallback(int errorCode, String message, T t);
}
