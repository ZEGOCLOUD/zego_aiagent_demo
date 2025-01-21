//
//  ZegoAIComConversationListVC.swift
//  ZIMKitDemo
//
//  Created by applechang on 2024/10/18.
//

import Foundation
import ZIMKit
import ZIM
//import ZegoUIKitPrebuiltCall
//import ZegoUIKit

open class ZegoAIComConversationListVC: ZIMKitConversationListVC {
    
    lazy var creatAIAgentBtn: UIButton = {
        let okButton = UIButton(type: .system).withoutAutoresizingMaskConstraints
//        let origin_y = view.bounds.origin.y + view.bounds.size.height - 49 - 52
//        okButton.frame = CGRect(x:view.bounds.width/2 - 180/2, y:origin_y, width: 180, height: 52);
        
        okButton.layer.cornerRadius = 26 // 设置按钮圆角
        okButton.backgroundColor = UIColor(hex: 0x0055FF) // 设置按钮背景颜色
        okButton.isEnabled = true // 禁用按钮
        // 设置按钮在不同状态下的标题
        okButton.setTitle("创建智能体", for: .normal)
        // 设置按钮在不同状态下的标题颜色
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "Pingfang-SC-Medium", size: 16)
        
        // 为按钮添加点击事件
        okButton.addTarget(self, action: #selector(createAIAgentButtonClicked), for: .touchUpInside)
        return okButton
    }()
    
    open override func setUpLayout() {
        super.setUpLayout()
        //创建智能体按钮
//        view.embed(creatAIAgentBtn)
        
        view.addSubview(creatAIAgentBtn)
         NSLayoutConstraint.activate([
            creatAIAgentBtn.centerXAnchor.pin(equalTo: view.centerXAnchor, constant: 0),
            creatAIAgentBtn.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -49),
            creatAIAgentBtn.heightAnchor.pin(equalToConstant: 52.0),
            creatAIAgentBtn.widthAnchor.pin(equalToConstant: 180)
         ])

    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        ZIMKit.registerZIMKitDelegate(self)
//        ZIMKit.registerCallKitDelegate(self)
        self.delegate = self
        self.messageDelegate = self
        configUI()
        setupNav()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewDidAppear(animated)
        let defPinnedItem = AppDataManager.sharedInstance().getDefaultPinnedAgentConversionId()
        
        if defPinnedItem != nil {
            ZIMKit.updateConversationPinnedState(for: defPinnedItem!, type: .peer, isPinned: true) { error in
            }
        }
        
        // 延迟 2 秒后执行一次保证
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let defPinnedItem = AppDataManager.sharedInstance().getDefaultPinnedAgentConversionId()
            if defPinnedItem != nil {
                ZIMKit.updateConversationPinnedState(for: defPinnedItem!, type: .peer, isPinned: true) { error in
                }
            }
        }
    }

    func configUI() {
        // 自定义标题视图
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        titleLabel.backgroundColor = .clear
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = "对话"
        self.navigationItem.titleView = titleLabel
        
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(UIImage(), for: .default)
        }

        let image = UIImage(named: "tabbar_message")?.withRenderingMode(.alwaysOriginal)
        let item = UITabBarItem(title: "demo_message", image: image, selectedImage: image)
        item.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.zim_textGray5
        ], for: .normal)
        item.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.zim_textBlack2
        ], for: .normal)
        item.setBadgeTextAttributes([
            .font: UIFont.systemFont(ofSize: 9, weight: .medium),
            .foregroundColor: UIColor.white
        ], for: .normal)
        item.badgeColor = .zim_backgroundRed
        self.tabBarItem = item
    }

    func setupNav() {
        let leftImage = UIImage(named: "nav-back")?.withRenderingMode(.alwaysOriginal)
        let leftItem = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(leftItemClick(_:)))
        self.navigationItem.leftBarButtonItem = leftItem
    }
}

extension ZegoAIComConversationListVC {
    //creatAIAgent
    @objc func createAIAgentButtonClicked(_ item:UIButton?){
//        let createAIAgentVC:ZegoAIComCreateAIAgentVC = ZegoAIComCreateAIAgentVC();
//        self.navigationController?.pushViewController(createAIAgentVC, animated: true)        
        let createAIAgentVC = ZegoAIComCreateAIAgentVC()
        createAIAgentVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        createAIAgentVC.needAddNavBackIcon = true
        // 使用 presentViewController 方法显示该视图控制器
        self.present(createAIAgentVC, animated: true, completion: nil)
        
    }

    // logout
    @objc func leftItemClick(_ item: UIBarButtonItem?) {
        ZIMKit.disconnectUser()
        self.navigationController?.popViewController(animated: true)
    }

    @objc func rightItemClick(_ item: UIBarButtonItem?) {
        showStartChattingAlert()
    }
    
    func showStartChattingAlert() {
    }
    
  @objc func customerButtonClick(_ sender: UIButton) {
      print("customerButtonClick")
  }
}

extension ZegoAIComConversationListVC: ZIMKitDelegate {
    public func onTotalUnreadMessageCountChange(_ totalCount: UInt32) {
        if totalCount == 0 {
            tabBarItem.badgeValue = nil
        } else if totalCount <= 99 {
            tabBarItem.badgeValue = String(totalCount)
        } else {
            tabBarItem.badgeValue = "99+"
        }
    }
    
    public func onConnectionStateChange(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        var title = "In-app Chat"
        if state == .connecting || state == .reconnecting {
            title = "In-app Chat demo_connecting"
        } else if state == .disconnected {
            title = "In-app Chat demo_disconnected"
        }
//        self.navigationItem.title = title
        
        if event == .kickedOut {
            onUserKickOut()
        }
    }
    
    func onUserKickOut() {
        if self.presentedViewController != nil {
            self.dismiss(animated: true)
        }
        let msg = "demo_user_kick_out"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "demo_confirm", style: .default) { _ in
            self.leftItemClick(nil)
        }
        alert.addAction(confirmAction)
        self.present(alert, animated: true)
    }
    
    public func onErrorToastCallback(_ errorCode: UInt, defaultMessage: String) -> String? {
        return defaultMessage
    }
  
    func callInvitationReceived(_ info: ZIMCallInvitationReceivedInfo, callID: String) {
      
    }
}

//extension ZegoAIComConversationListVC: ZegoUIKitPrebuiltCallInvitationServiceDelegate,
//                                  ZegoSendCallInvitationButtonDelegate {
//    public func requireConfig(_ data: ZegoCallInvitationData) -> ZegoUIKitPrebuiltCallConfig {
//        let config = ZegoUIKitPrebuiltCallConfig()
//        config.layout.mode = .pictureInPicture
//        let layoutConfig = ZegoLayoutPictureInPictureConfig()
//        layoutConfig.removeViewWhenAudioVideoUnavailable = false
//        config.layout.config = layoutConfig
//        if data.type == .voiceCall {
//            config.turnOnCameraWhenJoining = false
//            let bottomConfig = ZegoBottomMenuBarConfig()
//            bottomConfig.buttons = [.toggleMicrophoneButton, .hangUpButton, .switchAudioOutputButton]
//            config.bottomMenuBarConfig = bottomConfig
//        }
//        return config
//    }
//    
//    public func onPressed(_ errorCode: Int, errorMessage: String?, errorInvitees: [ZegoCallUser]?) {
//        if errorCode != 0 {
////            HUDHelper.showMessage("Send Invitation failed!! ErrorCode: \(errorCode)")
//        }
//        else if let errorInvitees = errorInvitees, errorInvitees.count > 0 {
////            HUDHelper.showMessage("The user you call is offline!")
//        }
//    }
//}

extension ZegoAIComConversationListVC: ZIMKitConversationListVCDelegate,ZIMKitMessagesListVCDelegate {
    
    public func getMessageListHeaderCustomerView(_ messageListVC: ZIMKitMessagesListVC) -> UIView? {
        let customerView = ZegoCustomNavBarHeaderView()
        return customerView;
    }
    
    public func conversationList(_ conversationListVC: ZIMKitConversationListVC, didSelectWith conversation: ZIMKitConversation, defaultAction: () -> ()) {
        AppDataManager.sharedInstance().switchCurrentCharacter(conversation.id)
        
        let messageListVC = ZIMKitMessagesListVC(conversationID: conversation.id,
                                                 type: conversation.type,
                                                 conversationName: conversation.name)
        messageListVC.delegate = self.messageDelegate
        self.navigationController?.pushViewController(messageListVC, animated: true)
        
        //基于ZegoExpressEngine而非ZegoUIKit发起语音聊天，外部开发者如果不想引入ZegoUIKit可参考下面这个代码
//        let callVC = ZegoAICompanionCallVCWithExpress()
//        self.navigationController?.pushViewController(callVC, animated: true)
    }
    
    
    public func shouldDeleteItem(_ conversationListVC: ZIMKitConversationListVC,
                          didSelectWith conversation: ZIMKitConversation,
                          withErrorCode code:UInt,
                          withErrorMsg msg:String){
        if code == 0{
            AppDataManager.sharedInstance().deleteConversionItem(conversation.id)
        }
    }
    
    public func shouldHideSwipePinnedItem(_ conversationListVC: ZIMKitConversationListVC, didSelectWith conversation: ZIMKitConversation) -> Bool {
        return false
    }
    
    public func shouldHideSwipeDeleteItem(_ conversationListVC: ZIMKitConversationListVC, didSelectWith conversation: ZIMKitConversation) -> Bool {
        let defAgentTemplate = AppDataManager.sharedInstance().isDefaultTemplateAgent(conversation.id)
        return defAgentTemplate
    }
}
