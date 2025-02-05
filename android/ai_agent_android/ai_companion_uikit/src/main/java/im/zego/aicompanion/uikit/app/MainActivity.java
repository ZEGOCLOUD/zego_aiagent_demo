package im.zego.aicompanion.uikit.app;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import androidx.appcompat.app.AppCompatActivity;
import im.zego.aicompanion.uikit.R;
import im.zego.aicompanion.uikit.settings.SettingsActivity;


public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        configuration = ViewConfiguration.get(this);
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
                }, 3000);
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
        // 仅仅在 ZegoAIAgentFragment 页面的时候，长按才有设置弹出来，不会消耗事件。
        Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
        startActivity(intent);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        System.exit(0);
    }
}