//
//  ZegoUIKitSignalingPluginService+RoomMessage.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by zego on 2022/12/28.
//

import Foundation
import ZIM
import ZegoPluginAdapter


extension ZegoUIKitSignalingPluginService {
    
    public func sendRoomMessage(_ text: String, roomID: String, callback: SendRoomMessageCallback?) {
        let msg = ZIMTextMessage(message: text)
        let config = ZIMMessageSendConfig()
        zim?.sendMessage(msg, toConversationID: roomID, conversationType: .room, config: config, notification: nil, callback: { msg, error in
            callback?(error.code.rawValue, error.message)
        })
    }
        
    public func sendRoomCommand(_ command: String, roomID: String, callback: SendRoomMessageCallback?) {
        guard let commandData = command.data(using: .utf8) else { return }
        let msg = ZIMCommandMessage(message: commandData)
        let config = ZIMMessageSendConfig()
        zim?.sendMessage(msg, toConversationID: roomID, conversationType: .room, config: config, notification: nil, callback: { msg, error in
            callback?(error.code.rawValue, error.message)
        })
    }
}
