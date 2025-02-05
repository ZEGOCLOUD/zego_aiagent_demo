package im.zego.aiagent.core.sdkapi;

import android.app.Application;
import android.content.Context;
import androidx.fragment.app.Fragment;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.CommonCallBack;

public interface ZegoIMProxy {

    void initIM(Application application);

    void loginIMUser(String userID, String userName, String avatarUrl, AIAgentCallBack callBack);

    void logoutIMUser();

    void unInitIM();

    void sendZIMLocalSystemMessage(String text, String conversationID, CommonCallBack cb);

    void jumpToMessageActivity(Context context, int requestCode, String userID, String userName, String userAvatar);

    void registerConversationListListener(Context context);

    void queryUserInfo(String userID, AIAgentCallBack callBack);

    Fragment getZIMKitConversationFragment();
}
