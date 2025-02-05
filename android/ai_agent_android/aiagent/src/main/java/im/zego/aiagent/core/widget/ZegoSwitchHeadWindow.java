package im.zego.aiagent.core.widget;

import static androidx.core.app.ActivityCompat.startActivityForResult;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.media.Image;
import android.provider.MediaStore;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.PopupWindow;
import android.widget.TextView;

import im.zego.aiagent.R;

public class ZegoSwitchHeadWindow {

    private View mParentView;
    private TextView mSelectView;
    private PopupWindow mMainPopupWindow;

    public ZegoSwitchHeadWindow(View parentView) {
        mParentView = parentView;
    }

    public void show() {
        View window = LayoutInflater.from(mParentView.getContext()).inflate(R.layout.window_create_ai_pictures, null, false);
        mMainPopupWindow = new PopupWindow(window,
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, true);
        mMainPopupWindow.setTouchable(true);
//        mMainPopupWindow.setBackgroundDrawable(new ColorDrawable(0x66000000));
//        mMainPopupWindow.showAsDropDown(mParentView, 0, 0);
        mMainPopupWindow.showAtLocation(mParentView, Gravity.BOTTOM, 0, 0);

        mSelectView = window.findViewById(R.id.create_ai_pics_select);
        mSelectView.setOnClickListener(view -> openGallery());
        window.findViewById(R.id.create_ai_pics_cancel).setOnClickListener(view -> hide());

    }
    private void openGallery() {
//        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
//        intent.setType("image/*"); // 只显示图片类型

        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.setType("image/*");  // 只选择图片类型
        intent.addCategory(Intent.CATEGORY_OPENABLE);

        ((Activity)mParentView.getContext()).startActivityForResult(intent, Constant.REQUEST_CODE_PICK_HEAD_IMAGE);
    }


    public void hide(){
        mMainPopupWindow.dismiss();
        mMainPopupWindow = null;

        mParentView.invalidate();
    }
}
