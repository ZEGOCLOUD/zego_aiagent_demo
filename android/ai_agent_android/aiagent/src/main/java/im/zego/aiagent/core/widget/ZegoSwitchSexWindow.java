package im.zego.aiagent.core.widget;

import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.PopupWindow;
import android.widget.TextView;

import java.sql.ClientInfoStatus;

import im.zego.aiagent.R;

public class ZegoSwitchSexWindow {

    private View mParentView;
//    private TextView mSexView;
    private PopupWindow mMainPopupWindow;
    public Boolean mIsBoy = true;
    private SexListener mSexListener = null;

    public ZegoSwitchSexWindow(View parentView, SexListener listener) {
        mParentView = parentView;
        mSexListener = listener;
    }

    public void show(boolean isBoy) {
        View window = LayoutInflater.from(mParentView.getContext()).inflate(R.layout.window_create_ai_sex, null, false);
//        View empty = window.findViewById(R.id.empty_panel_sex);
        mMainPopupWindow = new PopupWindow(window,
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
        mMainPopupWindow.setTouchable(true);
//        mMainPopupWindow.setBackgroundDrawable(new ColorDrawable(0x66000000));
//        mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
        mMainPopupWindow.showAtLocation(mParentView, Gravity.BOTTOM, 0, 0);

        window.findViewById(R.id.empty_panel_sex).setOnClickListener(view -> hide());
        window.findViewById(R.id.create_ai_sex_back).setOnClickListener(view -> hide());

        View boy = window.findViewById(R.id.create_ai_boy_chose);
        View girl = window.findViewById(R.id.create_ai_girl_chose);

        View boy_root = window.findViewById(R.id.create_ai_sex_boy);
        View girl_root = window.findViewById(R.id.create_ai_sex_girl);


        mIsBoy = isBoy;
        if(isBoy){
            boy.setVisibility(View.VISIBLE);
            girl.setVisibility(View.INVISIBLE);
        }else{
            boy.setVisibility(View.INVISIBLE);
            girl.setVisibility(View.VISIBLE);
        }

        boy_root.setOnClickListener(view -> {
            mIsBoy = true;
            boy.setVisibility(View.VISIBLE);
            girl.setVisibility(View.INVISIBLE);
            listen(mIsBoy);
            hide();
        });

        girl_root.setOnClickListener(view -> {
            mIsBoy = false;
            boy.setVisibility(View.INVISIBLE);
            girl.setVisibility(View.VISIBLE);
            listen(mIsBoy);
            hide();
        });

    }

    private void listen(boolean isBoy){
        if(mSexListener != null){
            mSexListener.onSexChanged(isBoy ? "男生" : "女生");
        }
    }

    public void hide(){
        if(mMainPopupWindow != null) {
            mMainPopupWindow.dismiss();
        }

        if(mParentView != null) {
            mParentView.invalidate();
        }
    }

    public interface SexListener{
        void onSexChanged(String sex);
    }
}
