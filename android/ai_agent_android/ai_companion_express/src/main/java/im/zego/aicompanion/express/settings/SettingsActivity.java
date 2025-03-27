package im.zego.aicompanion.express.settings;


import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Process;
import android.provider.OpenableColumns;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts.RequestMultiplePermissions;
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.databinding.DataBindingUtil;
import androidx.fragment.app.FragmentActivity;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.ZegoAIAgentSettings;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.sdkapi.ZegoVoiceCallExpressImpl;
import im.zego.aiagent.core.utils.AudioFileUtils;
import im.zego.aicompanion.express.R;
import im.zego.aicompanion.express.app.AiCompanionConfig;
import im.zego.aicompanion.express.app.MainActivity;
import im.zego.aicompanion.express.databinding.ActivitySettingsBinding;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.constants.ZegoAECMode;
import im.zego.zegoexpress.constants.ZegoANSMode;
import im.zego.zegoexpress.constants.ZegoAudioDeviceMode;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class SettingsActivity extends AppCompatActivity {

    private static final String TAG = "SettingsActivity";

    private ActivitySettingsBinding binding;
    private ActivityResultLauncher<Intent> pickAudioFileLauncher = registerForActivityResult(
        new StartActivityForResult(), new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                //Get uri, followed by the process of converting uri to file.
                if (result.getResultCode() == Activity.RESULT_OK) {
                    String filesDir = getExternalFilesDir(null).getPath() + File.separator + "fileCache";
                    File dir = new File(filesDir);
                    if (!dir.exists()) {
                        dir.mkdirs();
                    }
                    Uri uri = result.getData().getData();
                    String fileName = getFileName(SettingsActivity.this, uri);
                    File file = new File(filesDir, fileName);
                    if (file.exists()) {
                        file.delete();
                    }
                    saveFileFromUri(SettingsActivity.this, uri, file.getPath());
                    ZegoVoiceCallExpressImpl.customAudioCapture = true;
                    ZegoVoiceCallExpressImpl.capAudioPath = file.getPath();
                    binding.localAudioFile.setText(ZegoVoiceCallExpressImpl.capAudioPath);
                    int sampleRate = AudioFileUtils.getWavSampleRate(ZegoVoiceCallExpressImpl.capAudioPath);
                    if (sampleRate == -1) {
                        binding.localAudioFileSampleRate.setText("");
                    } else {
                        binding.localAudioFileSampleRate.setText(sampleRate + " Hz");
                    }
                } else {
                    ZegoVoiceCallExpressImpl.customAudioCapture = false;
                    ZegoVoiceCallExpressImpl.capAudioPath = "";
                    binding.localAudioFile.setText("");
                    binding.localAudioFileSampleRate.setText("");
                    binding.useLocalAudioFile.setChecked(false);
                }
            }
        });
    private ActivityResultLauncher<String[]> pickAudioFilePermissionLauncher = registerForActivityResult(
        new RequestMultiplePermissions(), new ActivityResultCallback<Map<String, Boolean>>() {
            @Override
            public void onActivityResult(Map<String, Boolean> result) {
                boolean allGranted = true;
                for (Map.Entry<String, Boolean> entry : result.entrySet()) {
                    String permission = entry.getKey();
                    boolean isGranted = entry.getValue();
                    if (!isGranted) {
                        allGranted = false;
                        break;
                    }
                }
                if (allGranted) {
                    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.setType("audio/*");
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    pickAudioFileLauncher.launch(intent);
                } else {
                    ZegoVoiceCallExpressImpl.customAudioCapture = false;
                    ZegoVoiceCallExpressImpl.capAudioPath = "";
                    binding.localAudioFile.setText("");
                    binding.localAudioFileSampleRate.setText("");
                }
            }
        });

    private ActivityResultLauncher<Intent> pickAudioAccLauncher = registerForActivityResult(
        new StartActivityForResult(), new ActivityResultCallback<ActivityResult>() {
            @Override
            public void onActivityResult(ActivityResult result) {
                //Get uri, followed by the process of converting uri to file.
                if (result.getResultCode() == Activity.RESULT_OK) {
                    String filesDir = getExternalFilesDir(null).getPath() + File.separator + "fileCache";
                    File dir = new File(filesDir);
                    if (!dir.exists()) {
                        dir.mkdirs();
                    }
                    Uri uri = result.getData().getData();
                    String fileName = getFileName(SettingsActivity.this, uri);
                    File file = new File(filesDir, fileName);
                    if (file.exists()) {
                        file.delete();
                    }
                    saveFileFromUri(SettingsActivity.this, uri, file.getPath());
                    ZegoVoiceCallExpressImpl.customAudioAcc = true;
                    ZegoVoiceCallExpressImpl.accAudioPath = file.getPath();
                    binding.localAudioAcc.setText(ZegoVoiceCallExpressImpl.accAudioPath);
                } else {
                    ZegoVoiceCallExpressImpl.customAudioAcc = false;
                    ZegoVoiceCallExpressImpl.accAudioPath = "";
                    binding.localAudioAcc.setText("");
                    binding.useLocalAudioAcc.setChecked(false);
                }
            }
        });

    private ActivityResultLauncher<String[]> pickAudioAccPermissionLauncher = registerForActivityResult(
        new RequestMultiplePermissions(), new ActivityResultCallback<Map<String, Boolean>>() {
            @Override
            public void onActivityResult(Map<String, Boolean> result) {
                boolean allGranted = true;
                for (Map.Entry<String, Boolean> entry : result.entrySet()) {
                    String permission = entry.getKey();
                    boolean isGranted = entry.getValue();
                    if (!isGranted) {
                        allGranted = false;
                        break;
                    }
                }
                if (allGranted) {
                    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                    intent.setType("audio/*");
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    pickAudioAccLauncher.launch(intent);
                } else {
                    ZegoVoiceCallExpressImpl.customAudioCapture = false;
                    ZegoVoiceCallExpressImpl.capAudioPath = "";
                    binding.localAudioFile.setText("");
                    binding.localAudioFileSampleRate.setText("");
                }
            }
        });


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.binding = DataBindingUtil.setContentView(this, R.layout.activity_settings);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        ArrayAdapter<CharSequence> envAdapter;
        envAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item,
            Arrays.asList("alpha", "beta", "prod", "delta", "gamma","trial"));
        envAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        binding.spinnerEnv.setAdapter(envAdapter);
        // 0, alpha , 1 beta,  2, prod
        if (envAdapter.getCount() <= Storage.env()) {
            Storage.set_env(0);
        }
        binding.spinnerEnv.setSelection(Storage.env());
        binding.spinnerEnv.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                Storage.set_env(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        binding.shareLog.setOnClickListener(v -> {
            ZegoAIAgentHelper.shareLogFiles(v.getContext());
        });

        binding.deleteLog.setOnClickListener(v -> {
            ZegoAIAgentHelper.deleteLogFiles(v.getContext());
        });

        binding.restart.setOnClickListener(v -> {
            restartApplication(v.getContext());
        });
        binding.showAppLogFiles.setOnClickListener(v -> {
            ZegoAIAgentHelper.showAppLog(v.getContext());
        });
        binding.showCrashFiles.setOnClickListener(v -> {
            ZegoAIAgentHelper.showCrashLog(v.getContext());
        });

        binding.showAsrFiles.setOnClickListener(v -> {
            ZegoAIAgentHelper.showASRLog(v.getContext());
        });

        binding.useLocalAudioAcc.setChecked(ZegoVoiceCallExpressImpl.customAudioAcc);
        binding.useLocalAudioAcc.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    List<String> permissions = requestReadSDCardPermissionIfNeed(SettingsActivity.this);
                    pickAudioAccPermissionLauncher.launch(permissions.toArray(new String[0]));
                } else {
                    ZegoVoiceCallExpressImpl.customAudioAcc = false;
                    ZegoVoiceCallExpressImpl.accAudioPath = "";
                    binding.localAudioAcc.setText("");
                }
            }
        });

        binding.useLocalAudioFile.setChecked(ZegoVoiceCallExpressImpl.customAudioCapture);
        binding.useLocalAudioFile.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    List<String> permissions = requestReadSDCardPermissionIfNeed(SettingsActivity.this);
                    pickAudioFilePermissionLauncher.launch(permissions.toArray(new String[0]));
                } else {
                    ZegoVoiceCallExpressImpl.customAudioCapture = false;
                    ZegoVoiceCallExpressImpl.capAudioPath = "";
                    binding.localAudioFile.setText("");
                    binding.localAudioFileSampleRate.setText("");
                }
            }
        });
        binding.localAudioFile.setText(ZegoVoiceCallExpressImpl.capAudioPath);
        int sampleRate = AudioFileUtils.getWavSampleRate(ZegoVoiceCallExpressImpl.capAudioPath);
        if (sampleRate == -1) {
            binding.localAudioFileSampleRate.setText("");
        } else {
            binding.localAudioFileSampleRate.setText(sampleRate + " Hz");
        }

        binding.appId.setText(AiCompanionConfig.getAppID() + "");
        binding.userId.setText(ZegoAIAgentConfigController.getUserInfo().userID);
        binding.userName.setText(getPackageName());
        binding.expressVersion.setText(ZegoExpressEngine.getVersion());
        binding.appVersionName.setText(getString(R.string.app_name));

        binding.enableAec.setChecked(ZegoAIAgentSettings.AEC);
        binding.enableAec.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                Storage.set_aec(isChecked);
                ZegoAIAgentSettings.AEC = isChecked;
            }
        });

        List<String> aecModeList = Arrays.stream(ZegoAECMode.values()).map(Enum::name).collect(Collectors.toList());
        ArrayAdapter<String> aecAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, aecModeList);
        aecAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

        binding.spinnerAecMode.setAdapter(aecAdapter);

        if (aecAdapter.getCount() <= ZegoAIAgentSettings.AEC_MODE) {
            ZegoAIAgentSettings.AEC_MODE = 0;
            Storage.set_aec_mode(ZegoAIAgentSettings.AEC_MODE);
        }
        binding.spinnerAecMode.setSelection(ZegoAIAgentSettings.AEC_MODE);
        binding.spinnerAecMode.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                Storage.set_aec_mode(position);
                ZegoAIAgentSettings.AEC_MODE = position;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        binding.enableAgc.setChecked(ZegoAIAgentSettings.AGC);
        binding.enableAgc.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                Storage.set_agc(isChecked);
                ZegoAIAgentSettings.AGC = isChecked;
            }
        });

        binding.enableAns.setChecked(ZegoAIAgentSettings.ANS);
        binding.enableAns.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                Storage.set_ans(isChecked);
                ZegoAIAgentSettings.ANS = isChecked;
            }
        });

        List<String> ansModeList = Arrays.stream(ZegoANSMode.values()).map(Enum::name).collect(Collectors.toList());
        ArrayAdapter<String> ansAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, ansModeList);
        ansAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        binding.spinnerAnsMode.setAdapter(ansAdapter);
        if (ansAdapter.getCount() <= ZegoAIAgentSettings.ANS_MODE) {
            ZegoAIAgentSettings.ANS_MODE = 0;
            Storage.set_ans_mode(ZegoAIAgentSettings.ANS_MODE);
        }
        binding.spinnerAnsMode.setSelection(ZegoAIAgentSettings.ANS_MODE);
        binding.spinnerAnsMode.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                Storage.set_ans_mode(position);
                ZegoAIAgentSettings.ANS_MODE = position;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        binding.localVad.setChecked(ZegoAIAgentSettings.LOCAL_VAD);
        binding.localVad.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                Storage.set_local_vad(isChecked);
                ZegoAIAgentSettings.LOCAL_VAD = isChecked;
            }
        });

        binding.latencyMode.setChecked(ZegoAIAgentSettings.Latency_Mode);
        binding.latencyMode.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                Storage.set_latency_mode(isChecked);
                ZegoAIAgentSettings.Latency_Mode = isChecked;
            }
        });

        List<String> audioDeivceModeList = Arrays.stream(ZegoAudioDeviceMode.values()).map(Enum::name)
            .collect(Collectors.toList());
        ArrayAdapter<String> audioDeviceModeAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item,
            audioDeivceModeList);
        audioDeviceModeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        binding.spinnerAudioDeviceMode.setAdapter(audioDeviceModeAdapter);
        //  audioDeivceMode 枚举值是从1开始的，也就是 第一个枚举值 postion 是 0 ，所以要 - 1
        if (audioDeviceModeAdapter.getCount() < ZegoAIAgentSettings.AUDIO_DEVICE_MODE) {
            int position = 1;
            ZegoAIAgentSettings.AUDIO_DEVICE_MODE = position + 1;
            Storage.set_audio_device_mode(position + 1);
        }
        binding.spinnerAudioDeviceMode.setSelection(ZegoAIAgentSettings.AUDIO_DEVICE_MODE - 1);
        binding.spinnerAudioDeviceMode.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                //  audioDeivceMode 枚举值是从1开始的，也就是 第一个枚举值postion 是 0 ，所以要 + 1
                int deviceMode = position + 1;
                Storage.set_audio_device_mode(deviceMode);
                ZegoAIAgentSettings.AUDIO_DEVICE_MODE = deviceMode;
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        boolean open = ZegoAIAgentSettings.AUDIO_DUCK == 1;
        binding.audioDucking.setChecked(open);
        binding.audioDucking.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                int open = isChecked ? 1 : 0;
                ZegoAIAgentSettings.AUDIO_DUCK = open;
            }
        });

        binding.echoAdapter.setChecked(ZegoAIAgentSettings.VOLUME_ADAPTIVE);
        binding.echoAdapter.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                ZegoAIAgentSettings.VOLUME_ADAPTIVE = isChecked;
            }
        });
    }

    public static void restartApplication(Context context) {
        // 创建一个Intent，指向你的应用的主Activity
        Intent intent = new Intent(context, MainActivity.class);
        intent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK); // 添加FLAG_ACTIVITY_NEW_TASK以确保在新的任务栈中启动
        context.startActivity(intent);

        // 结束当前进程
        Process.killProcess(Process.myPid());
        System.exit(0); // 退出虚拟机，这将终止当前应用进程
    }

    public static void saveFileFromUri(Context context, Uri uri, String destinationPath) {
        InputStream is = null;
        BufferedOutputStream bos = null;
        try {
            is = context.getContentResolver().openInputStream(uri);
            bos = new BufferedOutputStream(new FileOutputStream(destinationPath, false));
            byte[] buf = new byte[1024];

            int actualBytes;
            while ((actualBytes = is.read(buf)) != -1) {
                bos.write(buf, 0, actualBytes);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
                if (bos != null) {
                    bos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    public static String getFileName(@NonNull Context context, Uri uri) {
        String mimeType = context.getContentResolver().getType(uri);
        String filename = null;

        if (mimeType == null && context != null) {
            filename = getName(uri.toString());
        } else {
            Cursor returnCursor = context.getContentResolver().query(uri, null, null, null, null);
            if (returnCursor != null) {
                int nameIndex = returnCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                returnCursor.moveToFirst();
                filename = returnCursor.getString(nameIndex);
                returnCursor.close();
            }
        }

        return filename;
    }

    private static String getName(String filename) {
        if (filename == null) {
            return null;
        }
        int index = filename.lastIndexOf('/');
        return filename.substring(index + 1);
    }


    public List<String> requestReadSDCardPermissionIfNeed(FragmentActivity activity) {
        List<String> permissions = new ArrayList<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            int targetSdkVersion = activity.getApplicationInfo().targetSdkVersion;
            if (targetSdkVersion >= Build.VERSION_CODES.TIRAMISU) {
                permissions.add(Manifest.permission.READ_MEDIA_IMAGES);
                permissions.add(Manifest.permission.READ_MEDIA_AUDIO);
                permissions.add(Manifest.permission.READ_MEDIA_VIDEO);
            } else {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
            }
        } else {
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
        }
        return permissions;
    }
}