package im.zego.aiagent.core.sdkapi;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.utils.AudioFileUtils;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.callback.IZegoEventHandler;
import im.zego.zegoexpress.callback.IZegoRoomLoginCallback;
import im.zego.zegoexpress.constants.ZegoANSMode;
import im.zego.zegoexpress.constants.ZegoAudioDeviceMode;
import im.zego.zegoexpress.constants.ZegoAudioSampleRate;
import im.zego.zegoexpress.constants.ZegoAudioSourceType;
import im.zego.zegoexpress.constants.ZegoDumpDataType;
import im.zego.zegoexpress.constants.ZegoPublishChannel;
import im.zego.zegoexpress.constants.ZegoRoomStateChangedReason;
import im.zego.zegoexpress.constants.ZegoScenario;
import im.zego.zegoexpress.constants.ZegoStreamEvent;
import im.zego.zegoexpress.constants.ZegoUpdateType;
import im.zego.zegoexpress.entity.ZegoAudioFrameParam;
import im.zego.zegoexpress.entity.ZegoCustomAudioConfig;
import im.zego.zegoexpress.entity.ZegoDumpDataConfig;
import im.zego.zegoexpress.entity.ZegoEngineConfig;
import im.zego.zegoexpress.entity.ZegoEngineProfile;
import im.zego.zegoexpress.entity.ZegoPlayStreamQuality;
import im.zego.zegoexpress.entity.ZegoPublishStreamQuality;
import im.zego.zegoexpress.entity.ZegoRoomConfig;
import im.zego.zegoexpress.entity.ZegoSoundLevelConfig;
import im.zego.zegoexpress.entity.ZegoSoundLevelInfo;
import im.zego.zegoexpress.entity.ZegoStream;
import im.zego.zegoexpress.entity.ZegoUser;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;
import timber.log.Timber;

public class ZegoVoiceCallExpressImpl implements ZegoVoiceCallProxy {

    // ----- 都是为了测试用本地音频文件推流  -----
    public static boolean customAudioCapture = false;
    public static String audioPath;
    private final Handler mUIHandler = new Handler(Looper.getMainLooper());
    public static SendMediaCallBack sendMediaCallBack;
    // --------------------------------------------
    // 设置页面开关参数
    public static boolean AEC = true;
    public static boolean AGC = true;
    public static boolean ANS = true;
    public static boolean AI_AGGRESSIVE = true;
    // --------------------------------------------

    @Override
    public void init(Application application) {
        ZegoEngineProfile profile = new ZegoEngineProfile();
        profile.appID = ZegoAIAgentConfigController.getInstance().appID;
        profile.appSign = ZegoAIAgentConfigController.getInstance().appSign;
        profile.scenario = ZegoScenario.STANDARD_VOICE_CALL;
        profile.application = application;

        ZegoEngineConfig config = new ZegoEngineConfig();
        HashMap<String, String> advanceConfig = new HashMap<String, String>();
        advanceConfig.put("notify_remote_device_unknown_status", "true");
        advanceConfig.put("notify_remote_device_init_status", "true");

        /**下面的设置用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
        advanceConfig.put("enforce_audio_loopback_in_sync", "true");  // 应答延迟优化
        /*********************************************************************************************************/

        if (customAudioCapture) {
            advanceConfig.put("ext_capture_and_inner_render", "true");
        }

        config.advancedConfig = advanceConfig;
        ZegoExpressEngine.setEngineConfig(config);

        ZegoExpressEngine.createEngine(profile, null);

        if (customAudioCapture) {
            // 设置音频源为自定义采集和渲染
            ZegoCustomAudioConfig customAudioConfig = new ZegoCustomAudioConfig();
            customAudioConfig.sourceType = ZegoAudioSourceType.CUSTOM;
            ZegoExpressEngine.getEngine().enableCustomAudioIO(true, customAudioConfig);
        }

    }

    @Override
    public void loginUser(String userID, String userName, String avatarUrl, AIAgentCallBack callBack) {
        // express 无用户登录
        if (callBack != null) {
            callBack.onResult(0, "");
        }
    }

    @Override
    public void loginRoom(String roomID, AIAgentCallBack callBack) {
        ZegoExpressEngine.getEngine().setRoomScenario(ZegoScenario.STANDARD_VOICE_CALL);
        ZegoExpressEngine.getEngine().setAudioDeviceMode(ZegoAudioDeviceMode.GENERAL);

        if (AEC) {
            ZegoExpressEngine.getEngine().enableAEC(AEC);
        }
        if (AGC) {
            ZegoExpressEngine.getEngine().enableAGC(AGC);
        }
        if (ANS) {
            ZegoExpressEngine.getEngine().enableANS(ANS);
        }
        /**下面设置用来做远近人声降噪的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
        if (AI_AGGRESSIVE) {
            ZegoExpressEngine.getEngine().setANSMode(ZegoANSMode.AI_AGGRESSIVE);
        }

        ZegoAIAgentConfigController.CharacterConfig curUser = ZegoAIAgentConfigController.getConfig()
            .getCurrentCharacter();

        ZegoAIAgentConfigController.AppUserInfo userInfo = ZegoAIAgentConfigController.getUserInfo();
        ZegoUser user = new ZegoUser(userInfo.userID, userInfo.userName);
        ZegoRoomConfig roomConfig = new ZegoRoomConfig();
        roomConfig.isUserStatusNotify = true;

        ZegoExpressEngine.getEngine().loginRoom(curUser.getRoomID(), user, roomConfig, new IZegoRoomLoginCallback() {
            @Override
            public void onRoomLoginResult(int errorCode, JSONObject extendedData) {

                /**下面用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
                String expParam = "{\"method\":\"liveroom.audio.set_publish_latency_mode\",\"params\":{\"mode\":1,\"channel\":0}}";
                ZegoExpressEngine.getEngine().callExperimentalAPI(expParam);
                String deviceExpParam = "{\"method\":\"liveroom.audio.set_device_latency_mode\",\"params\": {\"mode\":2}}";
                ZegoExpressEngine.getEngine().callExperimentalAPI(deviceExpParam);
                /*********************************************************************************************************/

                if (errorCode == 0) {
//                    startSoundLevelMonitor();
                    muteMicrophone(false);
                    // 开始推流
                    String streamID = ZegoAIAgentConfigController.getConfig().getCurrentCharacter().getStreamID();
                    ZegoExpressEngine.getEngine().startPublishingStream(streamID, ZegoPublishChannel.MAIN);

                    if (customAudioCapture) {
                        File file = new File(audioPath);
                        if (file.exists() && file.length() > 0) {
                            isCaptureMedia = true;
                            captureMedia(new SendMediaCallBack() {
                                @Override
                                public void onSendFinished() {
                                    isCaptureMedia = false; // 停止发送
                                    String message = "文件 " + ZegoVoiceCallExpressImpl.audioPath + " 发送完毕";
                                    Timber.d(message);

                                    mUIHandler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            if (sendMediaCallBack != null) {
                                                sendMediaCallBack.onSendFinished();
                                            }
                                        }
                                    });
                                }

                                @Override
                                public void onError() {

                                }
                            });
                        } else {
                            if (sendMediaCallBack != null) {
                                sendMediaCallBack.onError();
                            }
                        }

                    }
                }
                if (callBack != null) {
                    callBack.onResult(errorCode, extendedData.toString());
                }
            }
        });
    }

    private static final String TAG = "ZegoVoiceCallExpressImp";

    @Override
    public void setEventHandler(IZegoEventHandler eventHandler) {
        ZegoExpressEngine.getEngine().setEventHandler(new IZegoEventHandler() {

            @Override
            public void onRoomStreamUpdate(String roomID, ZegoUpdateType updateType, ArrayList<ZegoStream> streamList,
                JSONObject extendedData) {
                Timber.d("onRoomStreamUpdate() called with: roomID = [" + roomID + "], updateType = [" + updateType
                    + "], streamList = [" + streamList + "], extendedData = [" + extendedData + "]");
                if (updateType == ZegoUpdateType.ADD) {
                    String robotStreamId = ZegoAIAgentConfigController.getConfig().getCurrentCharacter()
                        .getAgentStreamID();
                    for (int i = 0; i < streamList.size(); i++) {
                        ZegoStream item = streamList.get(i);
                        if (item.streamID.equals(robotStreamId)) {
                            ZegoExpressEngine.getEngine().startPlayingStream(robotStreamId);
                            /**下面用来做应答延迟优化的，需要集成对应版本的ZegoExpressEngine sdk，请联系即构同学**/
                            String expParam =
                                "{\"method\":\"liveroom.audio.set_play_latency_mode\",\"params\":{\"mode\":1,\"stream_id\":\""
                                    + robotStreamId + "\"}}";
                            ZegoExpressEngine.getEngine().callExperimentalAPI(expParam);
                            /*********************************************************************************************************/
                        }
                    }
                }
            }

            @Override
            public void onRoomStateChanged(String roomID, ZegoRoomStateChangedReason reason, int errorCode,
                JSONObject extendedData) {
                super.onRoomStateChanged(roomID, reason, errorCode, extendedData);
                Timber.d("onRoomStateChanged() called with: roomID = [" + roomID + "], reason = [" + reason
                    + "], errorCode = [" + errorCode + "], extendedData = [" + extendedData + "]");
            }


            @Override
            public void onIMRecvCustomCommand(String roomID, ZegoUser fromUser, String command) {
                super.onIMRecvCustomCommand(roomID, fromUser, command);
                Timber.d("onIMRecvCustomCommand() called with: roomID = [" + roomID + "], fromUser.userID = ["
                    + fromUser.userID + ", userName=" + fromUser.userName + "], command = [" + command + "]");
                if (eventHandler != null) {
                    eventHandler.onIMRecvCustomCommand(roomID, fromUser, command);
                }
            }

            @Override
            public void onCapturedSoundLevelInfoUpdate(ZegoSoundLevelInfo soundLevelInfo) {
                if (eventHandler != null) {
                    eventHandler.onCapturedSoundLevelInfoUpdate(soundLevelInfo);
                }
            }

            @Override
            public void onPlayerStreamEvent(ZegoStreamEvent eventID, String streamID, String extraInfo) {
                super.onPlayerStreamEvent(eventID, streamID, extraInfo);
                Timber.d("onPlayerStreamEvent() called with: eventID = [" + eventID + "], streamID = [" + streamID
                    + "], extraInfo = [" + extraInfo + "]");
            }

            @Override
            public void onPublisherStreamEvent(ZegoStreamEvent eventID, String streamID, String extraInfo) {
                super.onPublisherStreamEvent(eventID, streamID, extraInfo);
                Timber.d("onPublisherStreamEvent() called with: eventID = [" + eventID + "], streamID = [" + streamID
                    + "], extraInfo = [" + extraInfo + "]");
                if (eventHandler != null) {
                    eventHandler.onPublisherStreamEvent(eventID, streamID, extraInfo);
                }
            }

            @Override
            public void onDebugError(int errorCode, String funcName, String info) {
                super.onDebugError(errorCode, funcName, info);
                Timber.d("onDebugError() called with: errorCode = [" + errorCode + "], funcName = [" + funcName
                    + "], info = [" + info + "]");
            }

            @Override
            public void onFatalError(int errorCode) {
                super.onFatalError(errorCode);
                Timber.d("onFatalError() called with: errorCode = [" + errorCode + "]");
            }

            @Override
            public void onPublisherQualityUpdate(String streamID, ZegoPublishStreamQuality quality) {
                super.onPublisherQualityUpdate(streamID, quality);
                if (eventHandler != null) {
                    eventHandler.onPublisherQualityUpdate(streamID, quality);
                }

            }

            @Override
            public void onPlayerQualityUpdate(String streamID, ZegoPlayStreamQuality quality) {
                super.onPlayerQualityUpdate(streamID, quality);
                if (eventHandler != null) {
                    eventHandler.onPlayerQualityUpdate(streamID, quality);
                }
            }

            @Override
            public void onPublisherCapturedAudioFirstFrame() {
                super.onPublisherCapturedAudioFirstFrame();
                Timber.d("onPublisherCapturedAudioFirstFrame() called");
            }


            @Override
            public void onPublisherSendAudioFirstFrame(ZegoPublishChannel channel) {
                super.onPublisherSendAudioFirstFrame(channel);
                Timber.d("onPublisherSendAudioFirstFrame() called with: channel = [" + channel + "]");
            }
        });
    }

    @Override
    public void muteMicrophone(boolean mute) {
        ZegoExpressEngine.getEngine().muteMicrophone(mute);
    }

    @Override
    public void logoutUser() {
        // Express 无用户登录
    }

    @Override
    public void logoutRoom() {
        //        stopCaptureMedia();
        ZegoExpressEngine.getEngine().stopSoundLevelMonitor();
        ZegoExpressEngine.getEngine().logoutRoom();
    }

    @Override
    public void destroyEngine() {
        ZegoExpressEngine.destroyEngine(null);
    }

    //下面代码是用来做soundlevel跟vad信息侦听的，接入方应检查自己业务中是否还有其它地方调用，防止相互覆盖
    public void startSoundLevelMonitor() {
        ZegoSoundLevelConfig soundLevelConfig = new ZegoSoundLevelConfig();
        soundLevelConfig.enableVAD = true;
        soundLevelConfig.millisecond = 100;
        ZegoExpressEngine.getEngine().startSoundLevelMonitor(soundLevelConfig);
    }

    @Override
    public void setPlayVolume(String streamID, int volume) {
        Timber.d("setPlayVolume() called with: streamID = [" + streamID + "], volume = [" + volume + "]");
        ZegoExpressEngine.getEngine().setPlayVolume(streamID, volume);
    }

    @Override
    public void startDumpData() {
        ZegoDumpDataConfig config = new ZegoDumpDataConfig();
        config.dataType = ZegoDumpDataType.AUDIO;
        ZegoExpressEngine.getEngine().startDumpData(config);
    }

    @Override
    public void stopDumpData() {
        ZegoExpressEngine.getEngine().stopDumpData();
    }


    ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(1);
    byte[] mediaByte;
    byte[] temp;
    ByteBuffer mediaBuffer;
    int position = 0;
    float duration = 0.01f; // 10ms
    private ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
    boolean isCaptureMedia = false;
    private Thread captureThread;

    private void captureMedia(SendMediaCallBack callBack) {
        final int sampleRate = AudioFileUtils.getWavSampleRate(ZegoVoiceCallExpressImpl.audioPath);
        final int audioChannels = AudioFileUtils.getWavAudioChannels(ZegoVoiceCallExpressImpl.audioPath);
        final int bytesPerSample = AudioFileUtils.getWavBitsPerSample(ZegoVoiceCallExpressImpl.audioPath);
        Log.d(TAG, "captureMedia() called with: sampleRate = [" + sampleRate + "], audioChannels = [" + audioChannels
            + "], bytesPerSample=[" + bytesPerSample + "], duration = [" + duration + "]");

        captureThread = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (mediaBuffer != null) {
                        mediaBuffer.clear();
                    }
                    InputStream is = Files.newInputStream(new File(audioPath).toPath());
                    mediaByte = new byte[is.available()];
                    is.read(mediaByte);
                    is.close();
                    mediaBuffer = ByteBuffer.allocateDirect(mediaByte.length);
                    mediaBuffer.put(mediaByte);
                    mediaBuffer.flip();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                scheduledExecutorService.scheduleWithFixedDelay(new Runnable() {
                    @Override
                    public void run() {
                        if (isCaptureMedia && mediaBuffer.hasRemaining()) {

                            int dataLength = (int) (duration * sampleRate * audioChannels * bytesPerSample);
                            int length =
                                position + dataLength > mediaByte.length ? mediaByte.length - position : dataLength;

                            temp = new byte[length];
                            mediaBuffer.get(temp, 0, length);
                            ByteBuffer passingBuffer = ByteBuffer.allocateDirect(temp.length);
                            passingBuffer.put(temp);
                            if (sampleRate == -1) {
                                audioFrameParam.sampleRate = ZegoAudioSampleRate.ZEGO_AUDIO_SAMPLE_RATE_32K;
                            } else {
                                audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(sampleRate);
                            }
                            passingBuffer.flip();
                            ZegoExpressEngine.getEngine()
                                .sendCustomAudioCapturePCMData(passingBuffer, length, audioFrameParam);

                            position = position + length;
                            if (!mediaBuffer.hasRemaining()) {
                                // 文件发送完毕
                                if (callBack != null) {
                                    callBack.onSendFinished();
                                }
                            }
                        } else {
                            Timber.d("关闭线程池");
                            scheduledExecutorService.shutdown();
                        }
                    }
                }, 0, (int) (duration * 1000), TimeUnit.MILLISECONDS);
            }
        });
        captureThread.start();
    }

    public interface SendMediaCallBack {

        void onSendFinished();

        void onError();
    }
}
