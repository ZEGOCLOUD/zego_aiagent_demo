package im.zego.aiagent.core;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import im.zego.aiagent.core.callback.AIAgentCallBack;
import im.zego.aiagent.core.controller.ZegoAIAgentConfigController;
import im.zego.aiagent.core.sdkapi.ZegoIMProxy;
import im.zego.aiagent.core.ui.ZegoConversationActivity;
import im.zego.aiagent.core.ui.ZegoVoiceCallActivity;
import im.zego.aiagent.core.utils.ToastUtils;
import im.zego.aiagent.databinding.FragmentAiagentBinding;
import java.util.ArrayList;
import timber.log.Timber;

/**
 * AI 陪伴页面入口
 */
public class ZegoAIAgentFragment extends Fragment {

    private FragmentAiagentBinding binding;
    private boolean isPreparing;
    private boolean prepareSucceed;
    private static final String TAG = "ZegoAiEntranceFragment";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
        @Nullable Bundle savedInstanceState) {
        ToastUtils.context(getContext());
        binding = FragmentAiagentBinding.inflate(inflater, container, false);
        // prepare(); 为了节省时间也可以提前请求
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        binding.chatButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!prepareSucceed) {
                    // 请求中或者请求失败了
                    binding.contentLoading.setVisibility(View.VISIBLE);
                    if (!isPreparing) { // 如果是请求失败了，重新请求
                        prepare();
                    } else {
                        // 如果是请求中，等待请求结果
                    }
                } else {
                    // 假如提前请求成功了,点击直接跳转
                    goToNextPage();
                }
            }
        });
    }


    private void goToNextPage() {
        if (!ZegoAIAgentConfigController.getInstance().isAgentConfigListEmpty()) {

            ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
            if (imProxy == null) {
                // express
                ZegoVoiceCallActivity.startActivity(getContext());
            } else {
                // uikit
                //                ViewGroup parent = (ViewGroup) getView().getParent();
                //                if (parent.getId() == View.NO_ID) {
                //                    parent.setId(View.generateViewId());
                //                }
                //                ZegoConversationListFragment conversationListFragment = new ZegoConversationListFragment();
                //                FragmentTransaction transaction = getParentFragmentManager().beginTransaction();
                //                transaction.replace(parent.getId(), conversationListFragment, "ZegoConversationListFragment");
                //                transaction.addToBackStack(null);
                //                transaction.commitAllowingStateLoss();
                ZegoConversationActivity.startActivity(getContext());
            }
        } else {
            ToastUtils.show("请等待,并请检查网络");
        }
    }

    public void prepare() {
        if (isPreparing) {
            return;
        }
        isPreparing = true;
        ZegoIMProxy imProxy = ZegoAIAgentHelper.getImProxy();
        if (imProxy == null) {
            ZegoAIAgentHelper.requestAppConfigAndGetConversation(getContext(),
                (errorCode2, errMsg, characterConfigs) -> {
                    if (errorCode2 == 0) {
                        prepareFinished(characterConfigs);
                    } else {
                        prepareFailed(
                            new Exception("requestConfig failed: errorCode=" + errorCode2 + ", errorMsg=" + errMsg));
                    }
                });
        } else {
            //  如果用了 imkit, 需要先登录Zim
            ZegoAIAgentHelper.loginZIM(new AIAgentCallBack() {
                @Override
                public void onResult(int errorCode, String message) {
                    if (errorCode == 0) {
                        // 登录zim 成功之后，再去请求后台
                        ZegoAIAgentHelper.requestAppConfigAndGetConversation(getContext(),
                            (errorCode2, errMsg, characterConfigs) -> {
                                if (errorCode2 == 0) {
                                    prepareFinished(characterConfigs);
                                } else {
                                    prepareFailed(new Exception(
                                        "requestConfig failed: errorCode=" + errorCode2 + ", errorMsg=" + errMsg));
                                }
                            });
                    } else {
                        prepareFailed(new Exception("Login failed: errorCode=" + errorCode + ", errorMsg=" + message));
                    }
                }
            });
        }
    }

    private void prepareFailed(Throwable ex) {
        Timber.d("prepareFailed() called with: ex = [" + ex + "]");
        ToastUtils.show(ex.toString());

        isPreparing = false;
        prepareSucceed = false;

        if (binding != null) {
            binding.contentLoading.setVisibility(View.GONE);
        }
    }

    private void prepareFinished(ArrayList<ZegoAIAgentConfigController.CharacterConfig> requestConfigResult) {
        Timber.d("prepareFinished() called with: requestConfigResult = [" + requestConfigResult + "]");

        isPreparing = false;
        prepareSucceed = true;

        if (binding != null) {
            if (binding.contentLoading.getVisibility() == View.VISIBLE) { // 表示已经点击了跳转按钮
                binding.contentLoading.setVisibility(View.GONE);
                goToNextPage();
            }
        }
    }
}
