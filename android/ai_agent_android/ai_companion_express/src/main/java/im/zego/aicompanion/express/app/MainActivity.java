package im.zego.aicompanion.express.app;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import androidx.appcompat.app.AppCompatActivity;
import im.zego.aiagent.core.ZegoAIAgentSettings;
import im.zego.aicompanion.express.R;
import im.zego.aicompanion.express.settings.SettingsActivity;
import im.zego.aicompanion.express.settings.Storage;
import im.zego.zegoexpress.constants.ZegoAECMode;
import im.zego.zegoexpress.constants.ZegoANSMode;
import im.zego.zegoexpress.constants.ZegoAudioDeviceMode;
import im.zego.zegoexpress.constants.ZegoScenario;

// 应用启动页面
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        configuration = ViewConfiguration.get(this);

        ZegoAIAgentSettings.AEC = true;
        ZegoAIAgentSettings.AGC = true;
        ZegoAIAgentSettings.ANS = true;
        ZegoAIAgentSettings.ANS_MODE = ZegoANSMode.AI_BALANCED.value();
        ZegoAIAgentSettings.AEC_MODE = ZegoAECMode.AI.value();
        ZegoAIAgentSettings.SCENARIO = ZegoScenario.HIGH_QUALITY_CHATROOM.value();
        ZegoAIAgentSettings.AUDIO_DEVICE_MODE = ZegoAudioDeviceMode.GENERAL.value();
        ZegoAIAgentSettings.LOCAL_VAD = false;
        ZegoAIAgentSettings.Latency_Mode = false;
        ZegoAIAgentSettings.AUDIO_DUCK = 1;
        ZegoAIAgentSettings.ECHO_ADAPTIVE = true;
        ZegoAIAgentSettings.mediaPlayerVolume = 80;
        ZegoAIAgentSettings.playStreamVolume = 100;
        ZegoAIAgentSettings.defaultShowTestView = true;
        ZegoAIAgentSettings.autoDump = true;

        ZegoAIAgentSettings.MergeLLM = (Storage.env() == 3);

    }

    private Handler handler = new Handler(Looper.getMainLooper());
    private float downX, downY;
    private ViewConfiguration configuration;

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {

        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                downX = event.getX();
                downY = event.getY();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        performLongClickAction();
                    }
                }, ViewConfiguration.getLongPressTimeout());
                break;
            case MotionEvent.ACTION_MOVE:
                if (Math.abs(event.getX() - downX) > configuration.getScaledTouchSlop()
                    || Math.abs(event.getY() - downY) > configuration.getScaledTouchSlop()) {
                    // 用户移动了手指，取消长按检测
                    handler.removeCallbacksAndMessages(null);
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                handler.removeCallbacksAndMessages(null);
                break;
        }
        return super.dispatchTouchEvent(event);
    }

    private void performLongClickAction() {
        Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
        startActivity(intent);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        System.exit(0);
    }
}