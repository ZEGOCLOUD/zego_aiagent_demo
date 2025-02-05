package im.zego.aiagent.core.widget;

import java.util.ArrayList;
import java.util.List;

/**
 * 快速打断相关类
 */
public class ZegoVoiceActivityChecker {

    private List<Integer> queue;
    private int capacity;
    private float threshold; // >=0, <=1, 目前设置为10/15
    private boolean voiceActivity; // true 表示说话状态，false 反之
    private long checkSeq;

    public ZegoVoiceActivityChecker() {
        this.capacity = 5; // 默认窗口500ms尺寸
        this.queue = new ArrayList<>(capacity);
        this.voiceActivity = false;
        this.threshold = 11.0f / 15.0f;
        this.checkSeq = 0;
        for (int i = 0; i < capacity; i++) {
            enqueue(0);
        }
    }

    public void enqueue(int vadValue) {
        if (isFull()) {
            dequeue();
        }
        queue.add(vadValue);
    }

    public VadCheckerInfo voiceActivityDetection(int vadValue) {
        enqueue(vadValue);
        float weightAverage = 0.0f;
        for (int i = queue.size(); i > 0; i--) {
            int item = queue.get(i - 1);
            weightAverage += (i * item) / 15.0f;
        }
        if (weightAverage >= threshold) {
            if (!voiceActivity) {
                checkSeq++;
            }
            voiceActivity = true;
        } else {
            voiceActivity = false;
        }

        VadCheckerInfo checkerInfo = new VadCheckerInfo();
        checkerInfo.setWeightAverage(weightAverage);
        checkerInfo.setVoiceActivity(voiceActivity);
        checkerInfo.setCheckSeq(checkSeq);

        return checkerInfo;
    }

    public Integer dequeue() {
        if (!isEmpty()) {
            Integer object = queue.remove(0);
            return object;
        } else {
            System.out.println("Queue is empty. Cannot dequeue object.");
            return null;
        }
    }

    public boolean isEmpty() {
        return queue.isEmpty();
    }

    public boolean isFull() {
        return queue.size() >= capacity;
    }

    public static class VadCheckerInfo {

        private float weightAverage;
        private boolean voiceActivity;
        private long checkSeq;

        public float getWeightAverage() {
            return weightAverage;
        }

        public void setWeightAverage(float weightAverage) {
            this.weightAverage = weightAverage;
        }

        public boolean isVoiceActivity() {
            return voiceActivity;
        }

        public void setVoiceActivity(boolean voiceActivity) {
            this.voiceActivity = voiceActivity;
        }

        public long getCheckSeq() {
            return checkSeq;
        }

        public void setCheckSeq(long checkSeq) {
            this.checkSeq = checkSeq;
        }
    }
}

