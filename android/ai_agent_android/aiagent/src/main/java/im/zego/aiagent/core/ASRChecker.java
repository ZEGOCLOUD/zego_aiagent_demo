package im.zego.aiagent.core;

import android.app.Application;
import android.content.Context;
import com.google.gson.Gson;
import im.zego.aiagent.core.data.RTCRoomMessage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.apache.commons.text.similarity.LevenshteinDistance;

public class ASRChecker {

    private static final ASRChecker sInstance = new ASRChecker();

    private List<String> keywords = List.of("1、今天是周几呢", "2、你会打网球吗", "3、你会打乒乓球吗",
        "4、你认识哪一些运动明星呢", "5、世界上最美的国家是哪个", "6、中国最值得去的旅游景点", "7、你会说英语吗",
        "8、今天天气不错啊，挺适合出去走走的。", "9、那部电影真的很精彩，剧情特别吸引人。",
        "10、哎呀，我把钥匙忘在家里了，这可怎么办呀。", "11、明天好像有个聚会，我得准备一下咯。最近工作太忙了，都没时间休息。",
        "12、这道菜的做法有点复杂，我得好好学学。", "13、我觉得那个地方挺好玩的，你去过没？", "14、晚上要不要一块去看夜景呀？",
        "15、我买了一件新衣服，穿上还挺好看的。", "16、我明天要去参加一个 international 的会议，还得准备一下呢。",
        "17、你看那有个外国人，他好像在找什么东西，我们去问一下他吧。",
        "18、我最近在学英语，感觉有些语法好难啊，像那个现在完成时", "19、我喜欢吃 Chinese food，尤其是宫保鸡丁，味道超棒的。",
        "20、我跟一个外国朋友聊天，他说他很喜欢 China 我觉得很自豪。");

    public static ASRChecker getInstance() {
        return sInstance;
    }

    private Gson gson = new Gson();
    private List<RTCRoomMessage> rtcMessageList = new ArrayList<>();
    private Application application;


    public void onSendStarted(String audioPath) {
        rtcMessageList.clear();
    }

    public void onSendFinished(Context context, String audioPath) {
        String dirName = application.getExternalFilesDir(null) + File.separator + "asr";
        File file = new File(dirName);
        if (!file.exists()) {
            file.mkdir();
        }
        File audioFile = new File(audioPath);
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
        String formattedTime = now.format(formatter);
        File asrFile = new File(dirName, audioFile.getName() + formattedTime + ".txt");

        List<String> asr = rtcMessageList.stream().map(rtcRoomMessage -> rtcRoomMessage.data.text)
            .collect(Collectors.toList());
        writeWithFiles(asr, asrFile.getAbsolutePath());

        String string1 = calcTotalMatch(keywords, asr);
        String string2 = calcCER(keywords, asr);

        appendToFile(asrFile, string1);
        appendToFile(asrFile, string2);
    }

    private String calcTotalMatch(List<String> reference, List<String> asr) {
        StringBuilder builder = new StringBuilder();
        builder.append("\n");

        int minLen = Math.min(reference.size(), asr.size());
        int matchCount = 0;
        for (int i = 0; i < minLen; i++) {
            String refsText = cleanText(reference.get(i)).trim();
            String asrText = cleanText(asr.get(i)).trim();
            if (refsText.equals(asrText)) {
                matchCount++;
            } else {
                builder.append("不一致： refsText:" + refsText + ",asrText:" + asrText);
                builder.append("\n");
            }
        }
        int insertions = asr.size() - reference.size(); // 多余的句子数
        double matchRate = (double) matchCount / reference.size() * 100;

        builder.append("asr句子数: " + asr.size());
        builder.append("\n");
        builder.append("完全匹配句子数: " + matchCount);
        builder.append("\n");
        builder.append("完全匹配匹配率: " + matchRate + "%");
        return builder.toString();
    }


    private String calcCER(List<String> reference, List<String> asr) {
        // 合并参考文本和ASR结果
        String referenceText = cleanText(String.join("", reference));
        String asrText = cleanText(String.join("", asr));

        // 计算编辑距离
        LevenshteinDistance levenshteinDistance = new LevenshteinDistance();
        int distance = levenshteinDistance.apply(referenceText, asrText);

        // 计算CER
        int N = referenceText.length();
        double cer = (double) distance / N * 100;

        StringBuilder builder = new StringBuilder();
        // 输出结果到Logcat
        builder.append("\n");
        builder.append("编辑距离: " + distance + ",总字符数量：" + N);
        builder.append("\n");
        builder.append("字符错误率: " + cer + "%");

        return builder.toString();
    }

    // 去除序号和“、”的工具方法
    public static String cleanText(String text) {
        if (text == null) {
            return "";
        }
        return text.replaceAll("^\\d+、", "").replace(" ", "").replaceAll("[、，。！？；：,.!?;:'\"“”‘’【】()（）\\[\\]…—-]", "")
            .trim();
    }

    private void appendToFile(File file, String content) {
        try {
            // 以追加模式打开文件，如果文件不存在会自动创建
            FileOutputStream fos = new FileOutputStream(file, true); // true表示追加模式
            fos.write((content + "\n").getBytes()); // 写入内容并换行
            fos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void writeWithFiles(List<String> list, String filePath) {
        try {
            java.nio.file.Files.write(Paths.get(filePath),
                list.stream().map(item -> item == null ? "null" : item).collect(Collectors.toList()),
                java.nio.charset.StandardCharsets.UTF_8);
            System.out.println("成功写入文件: " + filePath);
        } catch (IOException e) {
            System.err.println("写入文件失败: " + e.getMessage());
        }
    }

    public void onIMRecvCustomCommand(String command) {
        RTCRoomMessage newMessage = gson.fromJson(command, RTCRoomMessage.class);
        if (newMessage.cmd == 3) {

            Optional<RTCRoomMessage> findMessage = rtcMessageList.stream()
                .filter(rtcRoomMessage -> rtcRoomMessage.data.message_id.equals(newMessage.data.message_id)).findAny();
            if (findMessage.isPresent()) {
                RTCRoomMessage existedMessage = findMessage.get();
                if (existedMessage.seq_id < newMessage.seq_id) {
                    existedMessage.seq_id = newMessage.seq_id;
                    existedMessage.timestamp = newMessage.timestamp;
                    existedMessage.round = newMessage.round;
                    existedMessage.data = newMessage.data;
                } else {
                }
            } else {
                rtcMessageList.add(newMessage);
            }
        }
    }

    public void setContext(Application application) {
        this.application = application;
    }
}
