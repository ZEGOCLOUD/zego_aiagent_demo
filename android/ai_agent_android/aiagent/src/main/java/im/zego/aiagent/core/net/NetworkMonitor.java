package im.zego.aiagent.core.net;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import android.widget.Toast;
import im.zego.aiagent.core.utils.ToastUtils;
import timber.log.Timber;

public class NetworkMonitor {

    private ConnectivityManager.NetworkCallback networkCallback;
    private static final String TAG = "NetworkMonitor";

    public void startNetworkCallback(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(
            Context.CONNECTIVITY_SERVICE);

        NetworkRequest networkRequest = new NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build();

        networkCallback = new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                super.onAvailable(network);
                // 网络可用
                Timber.i("Network connected");
                //                Toast.makeText(context, "网络已连接", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onLost(Network network) {
                super.onLost(network);
                // 网络丢失
                Timber.w("网络连接已中断");
                ToastUtils.show("网络连接已中断");
            }
        };

        connectivityManager.registerNetworkCallback(networkRequest, networkCallback);
    }

    public void stopNetworkCallback(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(
            Context.CONNECTIVITY_SERVICE);
        if (networkCallback != null) {
            connectivityManager.unregisterNetworkCallback(networkCallback);
        }
    }
}