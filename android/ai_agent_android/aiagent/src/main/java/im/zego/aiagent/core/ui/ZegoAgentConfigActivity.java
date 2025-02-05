package im.zego.aiagent.core.ui;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.text.style.AbsoluteSizeSpan;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Picasso.LoadedFrom;
import com.squareup.picasso.Target;
import com.squareup.picasso.Transformation;
import im.zego.aiagent.R;
import im.zego.aiagent.core.ZegoAIAgentHelper;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.callback.CommonCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.LLMConfig;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController.TTSConfig;
import im.zego.aiagent.core.data.ImageUrlData;
import im.zego.aiagent.core.net.ZegoAIAgentRequest;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.utils.PhotoGallery;
import im.zego.aiagent.core.utils.ToastUtils;
import im.zego.aiagent.core.widget.Constant;
import im.zego.aiagent.core.widget.ZegoSwitchHeadWindow;
import im.zego.aiagent.core.widget.ZegoSwitchSexWindow;
import im.zego.aiagent.core.widget.ZegoSwitchTTSWindow;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Objects;

/**
 * 创建 或 编辑 智能体
 */
public class ZegoAgentConfigActivity extends AppCompatActivity implements
    ZegoAIAgentConfigController.ConfigDataObserver {

    ImageView mHeadView;
    ImageView mHeadAdd;
    ZegoSwitchHeadWindow mHeadWindow;

    TextView mTitleView;
    TextView mDeclareView;
    TextView mNameView;
    TextView mSexView;
    ImageView mSexNextView;
    EditText mDescView;
    TextView mVoiceView;

    TextView mVoiceTitleView;
    ImageView mVoiceNextView;

    TextView mCopyRightView;

    TextView mOKView;

    View mRootView;

    String mHeadUri = "";

    String TAG = "AgentConfigActivity";

    ZegoSwitchSexWindow mSexWindow;
    ZegoSwitchTTSWindow mVoiceWindow;

    Boolean mBoy = true;

    //当前创建或者编辑的
    ZegoAIAgentConfigController.CharacterConfig mCharacter;

    //create模式是上一次选中的， edit模式是保存之前的信息
    ZegoAIAgentConfigController.CharacterConfig mLastCharacter;
    int mLastCurIndex = 0;

    int mMode = 0; // 1 创建模式， 2编辑模式

    boolean avatarChanged;
    private View mLoadingView;

    //编辑模式下各view的设定, 非创建模式
    private void initEditStateView() {
        if (mMode == 0) {
            mTitleView.setText(R.string.set_ai_smart);
            mNameView.setText(mCharacter.name);
            mSexView.setText(mCharacter.sex);
            mDescView.setText(mCharacter.intro);
            mHeadUri = mCharacter.avatar;

            Picasso.get().setLoggingEnabled(true);
            if (mCharacter.avatar.startsWith("http")) {
                Picasso.get().load(mCharacter.avatar).transform(new CircleTransform())
                    .placeholder(R.mipmap.icon_touxiang).fit().centerCrop().into((mHeadView));
            } else {
                Picasso.get().load(Uri.parse(mCharacter.avatar)).transform(new CircleTransform())
                    .placeholder(R.mipmap.icon_touxiang).fit().centerCrop().into((mHeadView));
                //权限
                //                getContentResolver().takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
                //                try {
                //                    InputStream inputStream = getContentResolver().openInputStream(uri);
                //                    Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                //                    inputStream.close();
                //                    Bitmap roundedBitmap = getCircularBitmapFromCenter(bitmap); // 转换为圆形 Bitmap
                //                    mHeadView.setImageBitmap(roundedBitmap);
                //                } catch (IOException e) {
                //                    throw new RuntimeException(e);
                //                }
            }

            mVoiceView.setVisibility(View.GONE);
            mVoiceTitleView.setVisibility(View.GONE);
            mVoiceNextView.setVisibility(View.GONE);
            //            mOKView.setText(R.string.edit_ai_only);

            SpannableString spannable = new SpannableString("完成\n(仅自己可对话)");
            spannable.setSpan(new AbsoluteSizeSpan(16, true), 0, 2, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); // 第一行字体大小
            spannable.setSpan(new AbsoluteSizeSpan(11, true), 3, spannable.length(),
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); // 第二行字体大小
            mOKView.setText(spannable);

            if (mCharacter.isDefault) {
                mCopyRightView.setVisibility(View.GONE);
                mHeadAdd.setVisibility(View.GONE);
                mSexNextView.setVisibility(View.GONE);
                mNameView.setEnabled(false);
                mSexView.setEnabled(false);
                mDescView.setEnabled(false);
                mDescView.setTextColor(Color.parseColor("#A4A4A4"));
                mOKView.setVisibility(View.GONE);
                mDeclareView.setVisibility(View.GONE);
            }

        } else if (mMode == 1) {

            SpannableString spannable = new SpannableString("创建智能体\n(仅自己可对话)");
            spannable.setSpan(new AbsoluteSizeSpan(16, true), 0, 5, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); // 第一行字体大小
            spannable.setSpan(new AbsoluteSizeSpan(11, true), 6, spannable.length(),
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE); // 第二行字体大小
            mOKView.setText(spannable);

        }
    }

    public void initCharacter() {

        if (mMode == 1) {//创建
            mCharacter = new ZegoAIAgentConfigController.CharacterConfig();
            mCharacter.name = "";
            mCharacter.sex = "男生";
            mCharacter.intro = "";
            mCharacter.avatar = "";
            TTSConfig ttsConfig = ZegoAIAgentConfigController.getConfig().tts_list[0];
            LLMConfig llmConfig;
            if (ZegoAIAgentConfigController.getConfig().llm_list.length > 4) {
                llmConfig = ZegoAIAgentConfigController.getConfig().llm_list[3];
            } else {
                llmConfig = ZegoAIAgentConfigController.getConfig().llm_list[0];
            }

            mCharacter.cur_config.tts_id = ttsConfig.id;
            mCharacter.cur_config.llm_id = llmConfig.id;
            if (ttsConfig.voice_list.length > 0) {
                mCharacter.cur_config.voice_id = ttsConfig.voice_list[0].id;
                if (ttsConfig.voice_list[0].language.length > 0) {
                    mCharacter.cur_config.language_id = ttsConfig.voice_list[0].language[0].id;
                }
            }
            mLastCharacter = ZegoAIAgentConfigController.getConfig().getCurrentCharacter();
            mLastCurIndex = ZegoAIAgentConfigController.getConfig().mCurrentCharacterIndex;

            //当前编辑的为cur
            ZegoAIAgentConfigController.getConfig().character_list.add(mCharacter);
            ZegoAIAgentConfigController.getConfig().mCurrentCharacterIndex =
                ZegoAIAgentConfigController.getConfig().character_list.size() - 1;

        } else {
            //编辑
            mCharacter = ZegoAIAgentConfigController.getConfig().getCurrentCharacter();
            if (mCharacter != null) {
                mCharacter.select();
                //编辑状态要保存之前的内容
                mLastCharacter = mCharacter.clone();
                mLastCurIndex = ZegoAIAgentConfigController.getConfig().mCurrentCharacterIndex;
            }
        }

        if (mCharacter != null) {
            mCharacter.cur_config.addDataChangedObserver(new WeakReference<>(this));
        }
    }

    private void cancelEditCharacter() {
        if (mMode == 1 && !mCharacter.create) {
            int size = ZegoAIAgentConfigController.getConfig().character_list.size();
            if (size > 0) {
                ZegoAIAgentConfigController.getConfig().character_list.remove(size - 1);
            }
            //            if(mLastCharacter != null){
            //                mLastCharacter.select();
            //            }
            ZegoAIAgentConfigController.getConfig().mCurrentCharacterIndex = mLastCurIndex;
        } else if (mMode == 0) {
            mCharacter.copy(mLastCharacter);
        }
    }

    private void checkStoragePermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1);
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        checkStoragePermission();
        setContentView(R.layout.window_create_ai);

        mMode = getIntent().getIntExtra("mode", 0);
        initCharacter();

        mTitleView = this.findViewById(R.id.create_ai_title);
        mCopyRightView = this.findViewById(R.id.create_ai_copyright);
        mDeclareView = this.findViewById(R.id.create_ai_declare);
        mRootView = this.findViewById(R.id.create_ai_root);

        mHeadView = this.findViewById(R.id.create_ai_pic);
        mHeadAdd = this.findViewById(R.id.create_ai_pic_add);
        mHeadWindow = new ZegoSwitchHeadWindow(mRootView);
        mHeadView.setOnClickListener(view -> {
            if (!mCharacter.isDefault) {
                hideSoftKeyboard(view);
                mHeadWindow.show();
            }
        });

        ImageView back = findViewById(R.id.create_ai_back);
        setResult(Constant.RESULT_CODE_CREATE_AI_QUIT);
        back.setOnClickListener(view -> {
            //取消
            quit();
        });

        mNameView = findViewById(R.id.create_ai_name_txt);
        //        mNameView.setFilters(new InputFilter[]{new EmojiFilter()});
        mSexView = findViewById(R.id.create_ai_sex_txt);
        mSexView.setSelected(false);
        //        mSexView.setEnabled(false);

        mSexNextView = findViewById(R.id.create_ai_sex_next);

        mDescView = findViewById(R.id.create_ai_desc_txt);
        mVoiceView = findViewById(R.id.create_ai_voice);
        mVoiceView.setSelected(false);
        mVoiceTitleView = findViewById(R.id.create_ai_set_voice);
        mVoiceNextView = findViewById(R.id.create_ai_voice_next);

        mVoiceWindow = new ZegoSwitchTTSWindow(mRootView);
        mVoiceWindow.setDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {
                String name = ZegoAIAgentConfigController.getConfig().getCurrentCharacter().cur_config.getCurrentVoiceConfig().name;
                mVoiceView.setText(name);
            }
        });
        mVoiceNextView.setOnClickListener(view -> {
            hideSoftKeyboard(view);
            mVoiceWindow.show(ZegoSwitchTTSWindow.MODE_CREATE);
        });
        mVoiceView.setOnClickListener(view -> {
            hideSoftKeyboard(view);
            mVoiceWindow.show(ZegoSwitchTTSWindow.MODE_CREATE);
        });

        mOKView = findViewById(R.id.create_ai_only);

        mLoadingView = findViewById(R.id.content_loading);
        //        mCreateView.setClickable(false);

        mSexWindow = new ZegoSwitchSexWindow(mRootView, new ZegoSwitchSexWindow.SexListener() {
            @Override
            public void onSexChanged(String sex) {
                mSexView.setText(sex);
                checkOkSaveEnable();
            }
        });
        mSexNextView.setOnClickListener(view -> {
            hideSoftKeyboard(view);
            mSexWindow.show(mBoy);
        });
        mSexView.setOnClickListener(view -> {
            hideSoftKeyboard(view);
            mSexWindow.show(mBoy);
        });
        //        mSexView.setText(mBoy ? "男生" : "女生");

        mSexView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void afterTextChanged(Editable editable) {
                mBoy = mSexView.getText().toString().equals("男生");
                mCharacter.sex = mSexView.getText().toString();
            }
        });

        mNameView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                checkOkSaveEnable();
            }

            @Override
            public void afterTextChanged(Editable editable) {
                mCharacter.name = mNameView.getText().toString().trim();
            }
        });

        if (!mCharacter.isDefault) {
            mDescView.setMovementMethod(new ScrollingMovementMethod());
        } else {
            mDescView.setVerticalScrollBarEnabled(false);
            mDescView.setScrollBarStyle(View.SCROLLBARS_INSIDE_INSET);
            mDescView.setScrollContainer(false);
            mDescView.setMovementMethod(null);
        }
        mDescView.setCursorVisible(true);
        mDescView.setFocusable(true);
        mDescView.setFocusableInTouchMode(true);

        mDescView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
                checkOkSaveEnable();
            }

            @Override
            public void afterTextChanged(Editable editable) {
                mCharacter.intro = mDescView.getText().toString();
            }
        });

        mOKView.setEnabled(false);
        mOKView.setOnClickListener(view -> createAi());
        initEditStateView();
    }

    private void quit() {
        cancelEditCharacter();
        setResult(Constant.RESULT_CODE_CREATE_AI_QUIT);
        finish();
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        quit();
    }

    //关闭软件盘
    private void hideSoftKeyboard(View v) {
        InputMethodManager imm = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        }
        if (imm != null) {
            imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
        }
    }

    private boolean checkOkSaveEnable() {
        if (mNameView.getText().toString().trim().isEmpty() || mHeadUri.isEmpty()) {
            mOKView.setEnabled(false);
            mOKView.setClickable(false);
            return false;
        } else {
            mOKView.setEnabled(true);
            mOKView.setClickable(true);
            return true;
        }
    }

    private boolean isValidInput() {

        if (mNameView.getText().toString().trim().length() <= 0) {
            ToastUtils.show("名称（必填）");
            return false;
        } else if (mHeadUri.isEmpty()) {
            ToastUtils.show("头像（必选）");
            return false;
        }

        return true;
    }

    private void createAi() {
        if (isValidInput()) {

            if (mMode == 1) {
                //创建模式
                if (avatarChanged) {
                    mLoadingView.setVisibility(View.VISIBLE);
                    Uri uri = Uri.parse(mHeadUri);
                    String path = PhotoGallery.saveUriToFile(this, uri,
                        Objects.requireNonNull(getExternalFilesDir(null)).getPath() + File.separator + "icons");
                    //分配头像url, 上传
                    ZegoAIAgentRequest.requestUploadAgentAvatar(path, new CommonCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            ImageUrlData ImageData = (ImageUrlData) data;
                            mCharacter.avatar = ImageData.FullUrl;
                            createAIAgentConversation(new AIAgentCallBack() {
                                @Override
                                public void onResult(int errorCode, String message) {
                                    mLoadingView.setVisibility(View.GONE);
                                }
                            });

                            // picasso 缓存
                            Picasso.get().load(ImageData.FullUrl).into(new Target() {
                                @Override
                                public void onBitmapLoaded(Bitmap bitmap, LoadedFrom from) {

                                }

                                @Override
                                public void onBitmapFailed(Exception e, Drawable errorDrawable) {

                                }

                                @Override
                                public void onPrepareLoad(Drawable placeHolderDrawable) {

                                }
                            });
                        }

                        @Override
                        public void onFailed(int errorCode, String errorMsg) {
                        }
                    });
                } else {
                    createAIAgentConversation(new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            mLoadingView.setVisibility(View.GONE);
                        }
                    });
                }
            } else {
                mLoadingView.setVisibility(View.VISIBLE);
                if (avatarChanged) {
                    Uri uri = Uri.parse(mHeadUri);
                    String path = PhotoGallery.saveUriToFile(this, uri,
                        Objects.requireNonNull(getExternalFilesDir(null)).getPath() + File.separator + "icons");
                    //分配头像url, 上传
                    ZegoAIAgentRequest.requestUploadAgentAvatar(path, new CommonCallBack() {
                        @Override
                        public void onSuccess(Object data) {
                            ImageUrlData ImageData = (ImageUrlData) data;
                            mCharacter.avatar = ImageData.FullUrl;
                            updateAIAgentConversation(new AIAgentCallBack() {
                                @Override
                                public void onResult(int errorCode, String message) {
                                    mLoadingView.setVisibility(View.GONE);
                                }
                            });

                            Picasso.get().load(ImageData.FullUrl).into(new Target() {
                                @Override
                                public void onBitmapLoaded(Bitmap bitmap, LoadedFrom from) {
                                }

                                @Override
                                public void onBitmapFailed(Exception e, Drawable errorDrawable) {
                                }

                                @Override
                                public void onPrepareLoad(Drawable placeHolderDrawable) {

                                }
                            });
                        }

                        @Override
                        public void onFailed(int errorCode, String errorMsg) {
                        }
                    });
                } else {
                    //编辑模式
                    updateAIAgentConversation(new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            mLoadingView.setVisibility(View.GONE);
                        }
                    });
                }
            }
        } else {
            Log.e(TAG, "========createAi error, not ValidInput===== ");
        }
    }

    private void updateAIAgentConversation(AIAgentCallBack callBack) {
        ZegoAIAgentRequest.requestUpdateConversation(new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
                if (imProxy != null) {
                    imProxy.queryUserInfo(mCharacter.agentId, new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            if (callBack != null) {
                                callBack.onResult(errorCode, message);
                            }
                            setResult(Constant.RESULT_CODE_EDIT_AI_OK);
                            finish();
                        }
                    });
                }

            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {

            }
        });
    }

    private void createAIAgentConversation(AIAgentCallBack callBack) {
        ZegoAIAgentRequest.requestCreateConversation(mCharacter, new CommonCallBack() {
            @Override
            public void onSuccess(Object data) {
                mCharacter.isDefault = false;
                mCharacter.create = true;

                ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
                if (imProxy != null) {
                    imProxy.queryUserInfo(mCharacter.agentId, new AIAgentCallBack() {
                        @Override
                        public void onResult(int errorCode, String message) {
                            if (callBack != null) {
                                callBack.onResult(errorCode, message);
                            }
                            setResult(Constant.RESULT_CODE_CREATE_AI_OK);
                            finish();
                        }
                    });
                }
            }

            @Override
            public void onFailed(int errorCode, String errorMsg) {
                if (callBack != null) {
                    callBack.onResult(errorCode, errorMsg);
                }
            }
        });
    }

    @Override
    public void onAppExtraConfigChanged(ZegoAIAgentConfigController.ExtraConfigType type, String newData,
        String oldData) {
        if (type == ZegoAIAgentConfigController.ExtraConfigType.VOICE) {
            if (ZegoAIAgentConfigController.getConfig().getCurrentCharacter() != null) {
                mVoiceView.setText(ZegoAIAgentConfigController.getConfig()
                    .getCurrentCharacter().cur_config.getCurrentVoiceConfig().name);
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == Constant.REQUEST_CODE_PICK_HEAD_IMAGE && resultCode == RESULT_OK && data != null) {
            Uri selectedImageUri = data.getData(); // 获取选择图片的 Uri
            if (selectedImageUri != null) {
                // 处理图片数据，例如显示在 ImageView 中
                //要权限
                getApplicationContext().getContentResolver()
                    .takePersistableUriPermission(selectedImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

                if (!PhotoGallery.isSupportedImage(this, selectedImageUri)) {
                    Log.e(TAG, "not support pic: " + PhotoGallery.getFileExtension(this, selectedImageUri));
                    Toast toast = Toast.makeText(this,
                        "不支持该类型图片格式:" + PhotoGallery.getFileExtension(this, selectedImageUri),
                        Toast.LENGTH_SHORT);
                    toast.show();
                    return;
                }

                // 检查大小是否小于 10MB (10 * 1024 * 1024 字节)
                if (!PhotoGallery.isImageSizeLessThan10MB(this, selectedImageUri)) {
                    Log.e(TAG, "pic size is too large , must < 10M");
                    ToastUtils.show("头像图片过大, 必须 < 10M");
                    return;
                }

                if (!selectedImageUri.toString().equals(mHeadUri)) {

                    //保存到本地， 相册的uri路径是保密的

                    Picasso.get().load(selectedImageUri).transform(new CircleTransform())
                        .placeholder(R.mipmap.icon_touxiang).fit().centerCrop().into((mHeadView));
                    mHeadUri = selectedImageUri.toString();

                    avatarChanged = true;
                }
                checkOkSaveEnable();

                mHeadWindow.hide();
            }
        }
    }

    public static void createAIAgent(Activity activity) {
        Intent intent = new Intent(activity, ZegoAgentConfigActivity.class);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.putExtra("mode", 1); // create
        activity.startActivityForResult(intent, Constant.REQUEST_CODE_CREATE_AI);
    }

    public static void editAIAgent(Activity activity) {
        Intent intent = new Intent(activity, ZegoAgentConfigActivity.class);
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.putExtra("mode", 0); // create
        activity.startActivityForResult(intent, Constant.REQUEST_CODE_EDIT_AI);
    }

    /**
     * 从图像中间裁剪出圆形的 Bitmap
     *
     * @param bitmap 原始的 Bitmap
     * @return 裁剪后的圆形 Bitmap
     */
    private Bitmap getCircularBitmapFromCenter(Bitmap bitmap) {
        int size = Math.min(bitmap.getWidth(), bitmap.getHeight());
        int x = (bitmap.getWidth() - size) / 2;
        int y = (bitmap.getHeight() - size) / 2;

        // 从图像中间截取正方形区域
        Bitmap squaredBitmap = Bitmap.createBitmap(bitmap, x, y, size, size);

        // 创建一个新的圆形 Bitmap
        Bitmap output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final Paint paint = new Paint();
        paint.setAntiAlias(true);

        // 在 Canvas 上绘制一个圆形
        float radius = size / 2f;
        canvas.drawCircle(radius, radius, radius, paint);

        // 使用 PorterDuff 模式将 Bitmap 绘制为圆形
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(squaredBitmap, 0, 0, paint);

        // 回收不需要的 Bitmap
        squaredBitmap.recycle();

        return output;
    }

    public class EmojiFilter implements InputFilter {

        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
            for (int i = start; i < end; i++) {
                int type = Character.getType(source.charAt(i));
                if (type == Character.SURROGATE || type == Character.OTHER_SYMBOL) {
                    // 如果是表情符号，返回空字符，表示禁止输入
                    return "";
                }
            }
            return null; // 返回 null 表示允许输入
        }
    }


    static class PicassoRoundTransform implements Transformation {

        @Override
        public Bitmap transform(Bitmap source) {
            int widthLight = source.getWidth();
            int heightLight = source.getHeight();
            Bitmap output = Bitmap.createBitmap(source.getWidth(), source.getHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(output);
            Paint paintColor = new Paint();
            paintColor.setFlags(Paint.ANTI_ALIAS_FLAG);
            RectF rectF = new RectF(new Rect(0, 0, widthLight, heightLight));
            canvas.drawRoundRect(rectF, widthLight / 5, heightLight / 5, paintColor);
            Paint paintImage = new Paint();
            paintImage.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_ATOP));
            canvas.drawBitmap(source, 0, 0, paintImage);
            source.recycle();
            return output;
        }

        @Override
        public String key() {
            return "roundcorner";
        }
    }

    static class CircleTransform implements Transformation {

        @Override
        public Bitmap transform(Bitmap source) {
            int size = Math.min(source.getWidth(), source.getHeight());

            int x = (source.getWidth() - size) / 2;
            int y = (source.getHeight() - size) / 2;

            Bitmap squaredBitmap = Bitmap.createBitmap(source, x, y, size, size);
            if (squaredBitmap != source) {
                source.recycle();
            }

            Bitmap bitmap = Bitmap.createBitmap(size, size, source.getConfig());

            Canvas canvas = new Canvas(bitmap);
            Paint paint = new Paint();
            BitmapShader shader = new BitmapShader(squaredBitmap, BitmapShader.TileMode.CLAMP,
                BitmapShader.TileMode.CLAMP);
            paint.setShader(shader);
            paint.setAntiAlias(true);

            float r = size / 2f;
            canvas.drawCircle(r, r, r, paint);

            squaredBitmap.recycle();
            return bitmap;
        }

        @Override
        public String key() {
            return "circle";
        }
    }
}
