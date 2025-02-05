package im.zego.aiagent.core.widget;

import android.graphics.Color;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import androidx.constraintlayout.widget.ConstraintLayout;
import im.zego.aiagent.R;
import im.zego.aiagent.core.data.RTCRoomMessage;
import im.zego.aiagent.core.data.RTCRoomMessage.Data;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;
import timber.log.Timber;

public class ZegoVoiceCallMessageAdapter extends BaseAdapter {

    /**
     * 消息列表的所有数据
     */
    private List<RTCRoomMessage> rtcMessageList = new ArrayList<>();

    /**
     * LLM消息缓存
     */
    private Map<String, List<RTCRoomMessage>> llmMessageTemp = new HashMap<>();
    /**
     * LLM消息时间记录
     */
    private Map<String, Long> messageTimes = new HashMap<>();

    public void updateASRChatRMessage(RTCRoomMessage newMessage) {
        Optional<RTCRoomMessage> findMessage = rtcMessageList.stream()
            .filter(rtcRoomMessage -> rtcRoomMessage.data.message_id.equals(newMessage.data.message_id)).findAny();
        if (findMessage.isPresent()) {
            RTCRoomMessage existedMessage = findMessage.get();
            if (existedMessage.seq_id < newMessage.seq_id) {
                Timber.d("本地seq_id 比较小，更新消息 = [" + newMessage + "]");
                existedMessage.seq_id = newMessage.seq_id;
                existedMessage.timestamp = newMessage.timestamp;
                existedMessage.round = newMessage.round;
                existedMessage.data = newMessage.data;
                notifyDataSetChanged();
            } else {
                Timber.d("本地seq_id 比较大，不用更新 = [" + newMessage + "]");
            }
        } else {
            Timber.d("新消息，直接插入 = [" + newMessage + "]");
            rtcMessageList.add(newMessage);
            notifyDataSetChanged();
        }
    }


    public void addOrUpdateLLMChatMessage(RTCRoomMessage newMessage) {
        List<RTCRoomMessage> rtcRoomMessages = llmMessageTemp.get(newMessage.data.message_id);
        if (rtcRoomMessages == null) {
            Timber.d("缓存列表为空，创建列表并且添加 message:" + newMessage.data + ",添加之前有：" + llmMessageTemp.size()
                + "个缓存列表");
            rtcRoomMessages = new ArrayList<>();
            rtcRoomMessages.add(newMessage);
            llmMessageTemp.put(newMessage.data.message_id, rtcRoomMessages);
        } else {
            Timber.d("缓存列表有数据，直接添加 message: " + newMessage.data + ",目前有：" + llmMessageTemp.size()
                + "个缓存列表");
            rtcRoomMessages.add(newMessage);
        }

        if (rtcRoomMessages.size() > 1) {
            rtcRoomMessages.sort(new Comparator<RTCRoomMessage>() {
                @Override
                public int compare(RTCRoomMessage o1, RTCRoomMessage o2) {
                    return o1.seq_id - o2.seq_id;
                }
            });
        }

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < rtcRoomMessages.size(); i++) {
            builder.append(rtcRoomMessages.get(i).data.text);
        }

        String string = builder.toString();
        if (!TextUtils.isEmpty(string)) {
            Optional<RTCRoomMessage> any = rtcMessageList.stream()
                .filter(roomMessage -> roomMessage.data.message_id.equals(newMessage.data.message_id)).findAny();
            if (any.isPresent()) {
                any.get().data.text = string;
                Timber.d("更新文本 ： [" + string + "]");
            } else {
                RTCRoomMessage generateMessage = new RTCRoomMessage();
                generateMessage.timestamp = newMessage.timestamp;
                generateMessage.seq_id = newMessage.seq_id;
                generateMessage.round = newMessage.round;
                generateMessage.cmd = newMessage.cmd;
                generateMessage.data = new Data();
                generateMessage.data.speak_status = newMessage.data.speak_status;
                generateMessage.data.text = string;
                generateMessage.data.message_id = newMessage.data.message_id;
                generateMessage.data.end_flag = newMessage.data.end_flag;
                rtcMessageList.add(generateMessage);
                Timber.d("插入文本 ： [" + string + "]");
            }
        }

        // 来了新消息，按照 <messageID,当前时间> 存入 map
        messageTimes.put(newMessage.data.message_id, System.currentTimeMillis());

        Iterator<Entry<String, Long>> iterator = messageTimes.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, Long> entry = iterator.next();
            String messageID = entry.getKey();
            long lastTime = entry.getValue();
            long current = System.currentTimeMillis();
            // 遍历整个map检查每一个messageID,如果超过 4 秒还没有更新，删除对应的缓存消息列表
            if (current - lastTime >= 4000) {
                llmMessageTemp.remove(messageID);
                Timber.d(
                    " 清除 message_id :" + messageID + " 缓存列表，目前还有" + llmMessageTemp.size() + "个缓存列表");
                iterator.remove();
            }
        }

        notifyDataSetChanged();

    }

    @Override
    public int getCount() {
        return rtcMessageList.size();
    }

    @Override
    public RTCRoomMessage getItem(int position) {
        return rtcMessageList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return rtcMessageList.get(position).hashCode();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        RTCRoomMessage message = rtcMessageList.get(position);
        if (convertView == null) {
            convertView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.widget_voice_call_message_item, parent, false);
            ViewHolder holder = new ViewHolder();
            holder.content = convertView.findViewById(R.id.content);
            holder.cost = convertView.findViewById(R.id.cost);
            convertView.setTag(holder);
        }
        ViewHolder holder = (ViewHolder) convertView.getTag();
        holder.position = position;
        TextView messageTextView = holder.content;
        ConstraintLayout.LayoutParams lp = (ConstraintLayout.LayoutParams) messageTextView.getLayoutParams();
        if (message.cmd == 3) {
            messageTextView.setBackgroundResource(R.drawable.rounded_im_me);
            messageTextView.setTextColor(Color.parseColor("#ffffff"));
            holder.cost.setVisibility(View.GONE);
            lp.endToEnd = ConstraintLayout.LayoutParams.PARENT_ID;
            lp.startToStart = ConstraintLayout.LayoutParams.UNSET;
        } else {
            messageTextView.setBackgroundResource(R.drawable.rounded_im_other);
            messageTextView.setTextColor(Color.parseColor("#000000"));
            //            if (message.costMs != -1) {
            //                holder.cost.setVisibility(View.GONE);  // 暂时隐藏掉
            //                holder.cost.setText(message.costMs + "ms");
            //            } else {
            //                holder.cost.setVisibility(View.GONE);
            //            }
            lp.endToEnd = ConstraintLayout.LayoutParams.UNSET;
            lp.startToStart = ConstraintLayout.LayoutParams.PARENT_ID;
        }
        holder.content.setLayoutParams(lp);
        holder.content.setText(message.data.text);
        return convertView;
    }

    public static class ViewHolder {

        public TextView content;
        public TextView cost;
        public int position;
    }
}
