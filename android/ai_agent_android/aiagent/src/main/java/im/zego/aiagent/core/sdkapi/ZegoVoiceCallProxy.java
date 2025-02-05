package im.zego.aiagent.core.sdkapi;

import android.app.Application;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.zegoexpress.callback.IZegoEventHandler;

public interface ZegoVoiceCallProxy {

    void init(Application application);

    void loginUser(String userID, String userName, String avatarUrl, AIAgentCallBack callBack);

    void loginRoom(String roomID, AIAgentCallBack callBack);

    void setEventHandler(IZegoEventHandler eventHandler);

    void muteMicrophone(boolean mute);

    void logoutUser();

    void logoutRoom();

    void destroyEngine();

    void setPlayVolume(String streamID, int volume);

    void startDumpData();

    void stopDumpData();
}
