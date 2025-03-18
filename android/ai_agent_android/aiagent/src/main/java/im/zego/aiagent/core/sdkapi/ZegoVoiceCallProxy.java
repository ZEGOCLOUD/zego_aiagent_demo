package im.zego.aiagent.core.sdkapi;

import android.app.Application;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.zegoexpress.callback.IZegoEventHandler;
import im.zego.zegoexpress.callback.IZegoMediaPlayerLoadResourceCallback;

public interface ZegoVoiceCallProxy {

    void init(Application application);

    void loginUser(String userID, String userName, String avatarUrl, AIAgentCallBack callBack);

    void loginRoom(String roomID, AIAgentCallBack callBack);

    void setEventHandler(IZegoEventHandler eventHandler);

    void muteMicrophone(boolean mute);

    void logoutUser();

    void logoutRoom();

    void destroyEngine();

    void setPlayStreamVolume(String streamID, int volume);

    void startDumpData();

    boolean isDumpData();

    void stopDumpData();

    void loadAudio(String audio, IZegoMediaPlayerLoadResourceCallback callback);

    void startPlay();

    void stopPlay();

    void createMediaPlayer();

    void destroyMediaPlayer();

    int getMediaPlayerVolume();

    void setMediaPlayerVolume(int volume);

    int getPlayStreamVolume();

    void setPlayStreamVolume(int volume);
}
