package im.zego.aiagent.core.utils;

import android.content.Context;
import android.widget.Toast;
import androidx.annotation.StringRes;
import timber.log.Timber;

public class ToastUtils {

    private static Context context;

    public static void context(Context context) {
        ToastUtils.context = context;
    }

    public static void show(String s) {
        if (context == null) {
            Timber.w("NO Context set,show Toast Failed: " + s);
            return;
        }
        Toast.makeText(context, s, Toast.LENGTH_SHORT).show();
    }

    public static void show(@StringRes int s) {
        if (context == null) {
            Timber.w("NO Context set,show Toast Failed");
            return;
        }
        Toast.makeText(context, s, Toast.LENGTH_SHORT).show();
    }
}
