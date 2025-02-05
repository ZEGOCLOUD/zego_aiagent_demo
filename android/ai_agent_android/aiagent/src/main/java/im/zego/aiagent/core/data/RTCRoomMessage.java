package im.zego.aiagent.core.data;

/**
 * 语音聊天界面，接收到的后台服务器发过来的 房间内的聊天消息的结构体
 */
public class RTCRoomMessage {

    public long timestamp;
    public int seq_id;
    public int round;
    public int cmd;
    public Data data;

    public static class Data {

        public int speak_status;
        public String text;
        public String message_id;
        public boolean end_flag;


        @Override
        public String toString() {
            return "Data{" +
                "speak_status=" + speak_status +
                ", text='" + text + '\'' +
                ", message_id='" + message_id + '\'' +
                ", end_flag=" + end_flag +
                '}';
        }
    }

    @Override
    public String toString() {
        return "RTCMessageContent{" +
            "timestamp=" + timestamp +
            ", seq_id=" + seq_id +
            ", round=" + round +
            ", cmd=" + cmd +
            ", data=" + data +
            '}';
    }
}
