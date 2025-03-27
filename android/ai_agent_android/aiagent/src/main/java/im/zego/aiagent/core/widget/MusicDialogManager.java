package im.zego.aiagent.core.widget;

import android.content.Context;
import android.content.res.AssetManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallProxy;
import im.zego.aiagent.core.utils.Utils;
import im.zego.zegoexpress.callback.IZegoMediaPlayerLoadResourceCallback;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import timber.log.Timber;

public class MusicDialogManager {

    private Context context;
    private AlertDialog alertDialog;
    private int isPlayingIndex = -1;
    private List<String> musicList;
    private MusicAdapter musicAdapter;

    public MusicDialogManager(Context context) {
        this.context = context;
        loadMusicFromAssets();

        Timber.d("MusicDialogManager: " + musicList);
    }

    private void loadMusicFromAssets() {
        musicList = new ArrayList<>();
        AssetManager assetManager = context.getAssets();
        try {
            String[] files = assetManager.list("");
            if (files != null) {
                for (String file : files) {
                    if (file.endsWith(".mp3") || file.endsWith(".wav")) {
                        Utils.copyAssetToAppExternalFiles(context, file, file);
                        musicList.add(file);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(context, "Error loading music files", Toast.LENGTH_SHORT).show();
        }
    }

    public void loadAndPlayAcc(String name) {
        int index = musicList.indexOf(name);
        loadAndPlayAcc(index);
    }

    public void loadAndPlayAcc(int index) {
        if (index >= 0 && index < musicList.size()) {
            ZegoVoiceCallProxy rtcFunction = ZegoAIAgentHelper.getVoiceCallProxy();
            if (isPlayingIndex != -1) {
                rtcFunction.stopPlay();
            }

            isPlayingIndex = index;
            String path = context.getExternalFilesDir(null) + File.separator + musicList.get(index);
            rtcFunction.loadAudio(path, new IZegoMediaPlayerLoadResourceCallback() {
                @Override
                public void onLoadResourceCallback(int errorCode) {
                    if (errorCode == 0) {
                        Toast.makeText(context, musicList.get(index) + " loaded and playing", Toast.LENGTH_SHORT)
                            .show();
                        rtcFunction.startPlay();
                    } else {
                        Toast.makeText(context, "Failed to load " + musicList.get(index), Toast.LENGTH_SHORT).show();
                        isPlayingIndex = -1;
                    }
                    if (musicAdapter != null) {
                        musicAdapter.notifyDataSetChanged();
                    }
                }
            });
        }
    }

    private void stopPlaying() {
        ZegoVoiceCallProxy rtcFunction = ZegoAIAgentHelper.getVoiceCallProxy();
        rtcFunction.stopPlay();
        isPlayingIndex = -1;
        if (musicAdapter != null) {
            musicAdapter.notifyDataSetChanged();
        }
    }

    public void showMusicDialog() {
        if (alertDialog == null) {
            AlertDialog.Builder builder = new AlertDialog.Builder(context);
            builder.setTitle("Music List");

            View dialogView = LayoutInflater.from(context).inflate(R.layout.dialog_music_list, null);
            builder.setView(dialogView);

            RecyclerView recyclerView = dialogView.findViewById(R.id.music_recycler_view);
            recyclerView.setLayoutManager(new LinearLayoutManager(context));
            musicAdapter = new MusicAdapter();
            recyclerView.setAdapter(musicAdapter);

            builder.setPositiveButton("Close", null);
            alertDialog = builder.create();
        }
        alertDialog.show();
    }

    private class MusicAdapter extends RecyclerView.Adapter<MusicAdapter.MusicViewHolder> {

        @Override
        public MusicViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(context).inflate(R.layout.item_music, parent, false);
            return new MusicViewHolder(view);
        }

        @Override
        public void onBindViewHolder(MusicViewHolder holder, int position) {
            String musicName = musicList.get(position);
            holder.musicName.setText(musicName);

            holder.musicSwitch.setOnCheckedChangeListener(null);
            holder.musicSwitch.setChecked(position == isPlayingIndex);

            holder.musicSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    int currentPosition = holder.getAdapterPosition();
                    if (currentPosition == RecyclerView.NO_POSITION) {
                        return;
                    }

                    if (isChecked) {
                        if (currentPosition != isPlayingIndex) {
                            loadAndPlayAcc(currentPosition);
                        }
                    } else {
                        if (currentPosition == isPlayingIndex) {
                            stopPlaying();
                        }
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return musicList.size();
        }

        class MusicViewHolder extends RecyclerView.ViewHolder {

            TextView musicName;
            Switch musicSwitch;

            MusicViewHolder(View itemView) {
                super(itemView);
                musicName = itemView.findViewById(R.id.music_name);
                musicSwitch = itemView.findViewById(R.id.music_switch);
            }
        }
    }
}