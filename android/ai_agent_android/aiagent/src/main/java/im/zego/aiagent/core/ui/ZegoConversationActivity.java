package im.zego.aiagent.core.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;

public class ZegoConversationActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_zego_conversation);

        ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
        if (imProxy != null) {
            imProxy.registerConversationListListener(this);
            Fragment zimKitConversationFragment = imProxy.getZIMKitConversationFragment();
            getSupportFragmentManager().beginTransaction().replace(R.id.fragment_container, zimKitConversationFragment)
                .commitNow();
        }

        findViewById(R.id.chat_list_back).setOnClickListener(v -> {
            finish();
        });

        //创建智能体
        TextView create = findViewById(R.id.create_ai);
        create.setOnClickListener(v -> {
            ZegoAgentConfigActivity.createAIAgent(this);
        });

    }

    private boolean finishedInOnPauseLifeCycle = false;

    @Override
    public void onPause() {
        super.onPause();
        if (isFinishing()) {
            // 正常 finish,直接 clear
            // 比如反复进出此页面，不会引起时序的问题。
            finishedInOnPauseLifeCycle = true;
            clearResources();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (!finishedInOnPauseLifeCycle) {
            clearResources();
        }
    }

    private void clearResources() {
        //        ZegoAIAgentHelper.logoutZIMUser();
        //        ZegoAIAgentHelper.unInitAICompanion();
    }

    public static void startActivity(Context context) {
        Intent intent = new Intent(context, ZegoConversationActivity.class);
        context.startActivity(intent);
    }

}