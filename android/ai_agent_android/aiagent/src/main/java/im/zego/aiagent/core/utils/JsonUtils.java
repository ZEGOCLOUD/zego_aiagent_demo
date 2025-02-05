package im.zego.aiagent.core.utils;

import android.content.Context;
import android.content.res.AssetManager;
import java.io.InputStream;

public class JsonUtils {

    public static String loadJSONFromAsset(Context context, String fileName) {
        String json = null;
        try {
            AssetManager assetManager = context.getAssets();
            InputStream inputStream = assetManager.open(fileName);
            int size = inputStream.available();
            byte[] buffer = new byte[size];
            inputStream.read(buffer);
            inputStream.close();
            json = new String(buffer, "UTF-8");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return json;
    }
}
