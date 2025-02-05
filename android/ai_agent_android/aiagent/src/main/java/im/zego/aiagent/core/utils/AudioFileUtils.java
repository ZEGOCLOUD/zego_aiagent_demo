package im.zego.aiagent.core.utils;

import android.text.TextUtils;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class AudioFileUtils {

    public static int getWavSampleRate(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return -1;
        }
        File wavFile = new File(filePath);
        if (!wavFile.exists() || wavFile.length() == 0) {
            return -1;
        }
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(wavFile);
            // 跳过RIFF头和文件大小
            fis.skip(4 + 4);

            // 跳过"WAVE"标记
            fis.skip(4);

            // 查找"fmt "块
            while (true) {
                // 读取块的标识符（4字节）
                String chunkId = readString(fis, 4);
                // 读取块的大小（4字节）
                int chunkSize = readIntLE(fis);
                if ("fmt ".equals(chunkId)) {
                    // 读取格式数据
                    // 格式块的第一个字段是音频格式（2字节）
                    short audioFormat = readShort(fis);
                    // 第二个字段是通道数（2字节）
                    short numChannels = readShort(fis);
                    // 第三个字段是采样率（4字节）
                    int sampleRate = readIntLE(fis);

                    // 可以在这里读取其他字段，但为了获取采样率，我们可以在这里停止
                    return sampleRate;
                } else {
                    // 如果不是"fmt "块，跳过这个块
                    fis.skip(chunkSize);
                }
            }
        } catch (Exception e) {
            return -1;
        }
    }

    public static int getWavAudioChannels(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return -1;
        }
        File wavFile = new File(filePath);
        if (!wavFile.exists() || wavFile.length() == 0) {
            return -1;
        }
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(wavFile);
            // 跳过RIFF头和文件大小
            fis.skip(4 + 4);

            // 跳过"WAVE"标记
            fis.skip(4);

            // 查找"fmt "块
            while (true) {
                // 读取块的标识符（4字节）
                String chunkId = readString(fis, 4);
                // 读取块的大小（4字节）
                int chunkSize = readIntLE(fis);
                if ("fmt ".equals(chunkId)) {
                    // 读取格式数据
                    short audioFormat = readShort(fis);
                    short numChannels = readShort(fis);
                    // 我们只关心声道数，所以在这里停止
                    return numChannels;
                } else {
                    // 如果不是"fmt "块，跳过这个块
                    fis.skip(chunkSize);
                }
            }
        } catch (Exception e) {
            return -1;
        } finally {
            try {
                if (fis != null) {
                    fis.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static int getWavBitsPerSample(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return -1;
        }
        File wavFile = new File(filePath);
        if (!wavFile.exists() || wavFile.length() == 0) {
            return -1;
        }
        FileInputStream fis = null;
        try {
            fis = new FileInputStream(wavFile);
            // 跳过RIFF头和文件大小
            fis.skip(4 + 4);

            // 跳过"WAVE"标记
            fis.skip(4);

            // 查找"fmt "块
            while (true) {
                // 读取块的标识符（4字节）
                String chunkId = readString(fis, 4);
                // 读取块的大小（4字节）
                int chunkSize = readIntLE(fis);
                if ("fmt ".equals(chunkId)) {
                    // 读取格式数据
                    short audioFormat = readShort(fis);
                    short numChannels = readShort(fis);
                    int sampleRate = readIntLE(fis);
                    int byteRate = readIntLE(fis);
                    short blockAlign = readShort(fis);
                    short bitsPerSample = readShort(fis);
                    int bytesPerSample = bitsPerSample / 8;
                    return bytesPerSample;
                } else {
                    // 如果不是"fmt "块，跳过这个块
                    fis.skip(chunkSize);
                }
            }
        } catch (Exception e) {
            return -1;
        } finally {
            try {
                if (fis != null) {
                    fis.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static String readString(FileInputStream fis, int length) throws IOException {
        return new String(readBytes(fis, length));
    }

    private static byte[] readBytes(FileInputStream fis, int length) throws IOException {
        byte[] bytes = new byte[length];
        int totalRead = 0;
        while (totalRead < length) {
            totalRead += fis.read(bytes, totalRead, length - totalRead);
        }
        return bytes;
    }

    private static short readShort(FileInputStream fis) throws IOException {
        byte[] b = new byte[2];
        fis.read(b);
        return (short) ((b[0] & 0xff) | ((b[1] & 0xff) << 8));
    }

    private static int readIntLE(FileInputStream fis) throws IOException {
        byte[] b = new byte[4];
        fis.read(b);
        return ((b[0] & 0xff)) | ((b[1] & 0xff) << 8) | ((b[2] & 0xff) << 16) | ((b[3] & 0xff) << 24);
    }
}