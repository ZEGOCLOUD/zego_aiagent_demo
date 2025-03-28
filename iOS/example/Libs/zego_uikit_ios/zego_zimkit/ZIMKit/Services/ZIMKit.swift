//
//  ZIMKit.swift
//
//  Created by Kael Ding on 2022/12/5.
//

import Foundation
import ZegoPluginAdapter


@objc public enum ZIMKitMessageOperationName: Int {
    case copy
    case reply
    case forward
    case revoke
    case reaction
    case delete
    case speaker
    case multipleChoice
}

@objc public enum ZIMKitMenuBarButtonName: Int {
    case audio // 发送语音
    case emoji // 发送表情
    case picture // 发送图片
    case takePhoto // 拍照
    case voiceCall // 发起音频通话
    case videoCall // 发起视频通话
    case file // 发送文件
    case expand // 更多按钮
}

@objc public enum ZIMKitLogLevel: Int {
    case Debug   // 调试级别日志
    case Info    // 提示级别
    case Warning // 警告级别
    case Error   // 错误级别
}

public class ZIMKit: NSObject {
    var imKitConfig: ZIMKitConfig = ZIMKitCore.shared.config ?? ZIMKitConfig()
  
    @objc public static func initWith(appID: UInt32, appSign: String) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign, config: nil)
    }
    
    @objc public static func initWith(appID: UInt32, appSign: String,config:ZIMKitConfig?) {
        ZIMKitCore.shared.initWith(appID: appID, appSign: appSign,config: config)
    }
    
    @objc public static func unInit() {
        ZIMKitCore.shared.unInit()
    }
    
    @objc public static func registerZIMKitDelegate(_ delegate: ZIMKitDelegate) {
        ZIMKitCore.shared.registerZIMKitDelegate(delegate)
    }
    
    
    @objc public static func registerZIMKitLogDelegate(_ delegate: ZIMKitLogDelegate) {
        ZIMKitLogUtil.shared.registerZIMKitLogDelegate(delegate)
    }
    
  
    @objc public static func registerCallKitDelegate(_ delegate: AnyObject) {
      ZegoPluginAdapter.callPlugin?.registerCallKitDelegate(delegate: delegate)
    }
        
    @objc public static func insertSystemMessage(_ content: String ,conversationID: String ,groupConversation: Bool = false) {
        ZIMKit.insertSystemMessageToLocalDB(content,to: conversationID,groupConversationType:groupConversation) { message, error in
            print("insertSystemMessage errorCode:\(error.code)")
        }
    }
    
    @objc public static func deleteAllConversion() {
        ZIMKitCore.shared.deleteAllConversion();
    }
    
    
    static internal var currentIndex = 0
    static internal var timer: Timer?
    static internal var conversationList: [ZIMKitMessage]?
    static internal var targetConversation: ZIMKitConversation?
    
    static internal var oneByOneCallBack:sendMessageOneByOneCallback?
}


@objc public protocol ZIMKitLogDelegate: AnyObject {
    @objc optional
    func writeLog(_ level:ZIMKitLogLevel, msg:String)
}

@objc public class ZIMKitConfig: NSObject {
    @objc public var callPluginConfig: ZegoCallPluginConfig?
    @objc public var bottomConfig = ZIMKitBottomConfig()
    @objc public var conversationConfig = ZIMKitConversationConfig()
    @objc public var messageConfig = ZIMKitMessageConfig()

    internal var appID: UInt32?
    internal var appSign :String = ""
  
    @objc public var navigationBarColor: UIColor = UIColor.white
    @objc public var inputPlaceholder:NSAttributedString =  NSAttributedString(string: L10n("enter_new_message"), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x8E9093), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
    @objc public var advancedConfig:[String:AnyObject]?
}

@objc public class ZIMKitAdvancedKey :NSObject {
    @objc public static let showLoadingWhenSend:String = "show_loading_when_send";
    @objc public static let navigationBarShadowColor:String = "ShadowColor";
}

@objc public class ZIMKitBottomConfig : NSObject{
    public var smallButtons: [ZIMKitMenuBarButtonName] = [.audio, .emoji, .picture, .expand]
    @objc public let maxCount: Int = 4
    public var expandButtons: [ZIMKitMenuBarButtonName] = [.takePhoto, .file]
    @objc public var emojis: [String] = ["😀", "😃", "😄", "😁", "😆", "😅", "😂",
                                   "😇", "😉", "😊", "😋", "😌", "😍", "😘",
                                   "😗", "😙", "😚", "😜", "😝", "😛", "😎",
                                   "😏", "😶", "😐", "😑", "😒", "😳", "😞",
                                   "😟", "😤", "😠", "😡", "😔", "😕", "😬",
                                   "😣", "😖", "😫", "😩", "😪", "😮", "😱",
                                   "😨", "😰", "😥", "😓", "😯", "😦", "😧",
                                   "😢", "😭", "😵", "😲", "😷", "😴", "💤",
                                   "😈", "👿", "👹", "👺", "💩", "👻", "💀",
                                   "👽", "🎃", "😺", "😸", "😹", "😻", "😼",
                                   "😽", "🙀", "😿", "😾", "👐", "🙌", "👏",
                                   "🙏", "👍", "👎", "👊", "✊", "👌", "👈",
                                   "👉", "👆", "👇", "✋", "👋", "💪", "💅",
                                   "👄", "👅", "👂", "👃", "👀", "👶", "👧",
                                   "👦", "👩", "👨", "👱", "👵", "👴", "👲",
                                   "👳‍", "👼", "👸", "👰", "🙇", "💁", "🙅‍",
                                   "🙆", "🙋", "🙎", "🙍", "💇", "💆", "💃",
                                   "👫", "👭", "👬", "💛", "💚", "💙", "💜",
                                   "💔", "💕", "💞", "💓", "💗", "💖", "💘",
                                   "💝", "💟"]
    
    //MARK: The following properties are provided solely by OC
    @objc public var smallButtons_OC: NSArray {
        get {
            return smallButtons.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            smallButtons = newValue.compactMap { ZIMKitMenuBarButtonName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
    
    @objc public var expandButtons_OC: NSArray {
        get {
            return expandButtons.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            expandButtons = newValue.compactMap { ZIMKitMenuBarButtonName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
    
    @objc public var emojis_OC: NSArray {
        get {
            return emojis.map { $0 } as NSArray
        }
        set {
            emojis = newValue.compactMap { ($0 as AnyObject).stringValue }
        }
    }
}

@objc public class ZIMKitConversationConfig: NSObject {
  
}

@objc public class ZIMKitMessageConfig: NSObject {
    @objc public var textMessageConfig = ZIMKitTextMessageConfig()
    @objc public var audioMessageConfig = ZIMKitAudioMessageConfig()
    @objc public var videoMessageConfig = ZIMKitVideoMessageConfig()
    @objc public var imageMessageConfig = ZIMKitImageMessageConfig()
    @objc public var fileMessageConfig = ZIMKitFileMessageConfig()
    @objc public var combineMessageConfig = ZIMKitCombineMessageConfig()

  // 默认为空数组，则使用 ZIMKit 内部，否则使用客户提供的
  public var messageReactions: [String] = []
}

@objc public class ZIMKitTextMessageConfig : NSObject {
     public var operations: [ZIMKitMessageOperationName] = [.copy, .reply, .forward, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}

@objc public class ZIMKitAudioMessageConfig : NSObject {
    public var operations: [ZIMKitMessageOperationName] = [.speaker, .reply, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}

@objc public class ZIMKitVideoMessageConfig : NSObject {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}

@objc public class ZIMKitImageMessageConfig : NSObject {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}

@objc public class ZIMKitFileMessageConfig : NSObject {
    var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}

@objc public class ZIMKitCombineMessageConfig : NSObject {
    public var operations: [ZIMKitMessageOperationName] = [.reply, .forward, .multipleChoice, .delete, .revoke, .reaction]
    
    @objc public var operations_OC: NSArray {
        get {
            return operations.map { NSNumber(value: $0.rawValue) } as NSArray
        }
        set {
            operations = newValue.compactMap { ZIMKitMessageOperationName(rawValue: ($0 as AnyObject).intValue) }
        }
    }
}
