//
//  ZegoSignalingPluginService+EventHandler.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by zego on 2022/12/15.
//

import Foundation
import ZIM
import ZegoPluginAdapter

extension ZegoUIKitSignalingPluginService: ZIMEventHandler {
    
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        for handler in pluginEventHandlers.allObjects {
            handler.onConnectionStateChanged(ZegoSignalingPluginConnectionState.init(rawValue: state.rawValue) ?? .disconnected)
        }
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, connectionStateChanged: state, event: event, extendedData: extendedData)
        }
    }
    
    // MARK: - Main
    func zim(_ zim: ZIM, errorInfo: ZIMError) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, errorInfo: errorInfo)
        }
    }
    
    func zim(_ zim: ZIM, tokenWillExpire second: UInt32) {
        for handler in pluginEventHandlers.allObjects {
            handler.onTokenWillExpire(in: second)
        }
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, tokenWillExpire: second)
        }
    }
    
    // MARK: - Conversation
    func zim(_ zim: ZIM, conversationChanged conversationChangeInfoList: [ZIMConversationChangeInfo]) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, conversationChanged: conversationChangeInfoList)
        }
    }
    
    func zim(_ zim: ZIM, conversationTotalUnreadMessageCountUpdated totalUnreadMessageCount: UInt32) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, conversationTotalUnreadMessageCountUpdated: totalUnreadMessageCount)
        }
    }
    
    func zim(_ zim: ZIM, conversationMessageReceiptChanged infos: [ZIMMessageReceiptInfo]) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, conversationMessageReceiptChanged: infos)
        }
    }
    
    // MARK: - Room
    func zim(_ zim: ZIM, roomMemberJoined memberList: [ZIMUserInfo], roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomMemberJoined: memberList, roomID: roomID)
        }
        
        let userIDs = memberList.compactMap({ $0.userID })
        for handler in pluginEventHandlers.allObjects {
            handler.onRoomMemberJoined(userIDs, roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomMemberLeft memberList: [ZIMUserInfo], roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomMemberLeft: memberList, roomID: roomID)
        }
        
        let userIDs = memberList.compactMap({ $0.userID })
        for handler in pluginEventHandlers.allObjects {
            handler.onRoomMemberLeft(userIDs, roomID: roomID)
        }
    }
    
    
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomAttributesUpdated: updateInfo, roomID: roomID)
        }
        
        let setProperties = updateInfo.action == .set ? updateInfo.roomAttributes : [:]
        let deleteProperties = updateInfo.action == .delete ? updateInfo.roomAttributes : [:]
        for handler in pluginEventHandlers.allObjects {
            handler.onRoomPropertiesUpdated([setProperties], deleteProperties: [deleteProperties], roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomAttributesBatchUpdated updateInfo: [ZIMRoomAttributesUpdateInfo], roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomAttributesBatchUpdated: updateInfo, roomID: roomID)
        }
        
        var setProperties: [[String: String]] = []
        var deleteProperties: [[String: String]] = []
        for info in updateInfo {
            if info.action == .set {
                setProperties.append(info.roomAttributes)
            } else if info.action == .delete {
                deleteProperties.append(info.roomAttributes)
            }
        }
        for handler in pluginEventHandlers.allObjects {
            handler.onRoomPropertiesUpdated(setProperties,
                                            deleteProperties: deleteProperties,
                                            roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomMemberAttributesUpdated infos: [ZIMRoomMemberAttributesUpdateInfo], operatedInfo: ZIMRoomOperatedInfo, roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomMemberAttributesUpdated: infos, operatedInfo: operatedInfo, roomID: roomID)
        }
        
        var attributesMap: [String: [String: String]] = [:]
        for info in infos {
            attributesMap[info.attributesInfo.userID] = info.attributesInfo.attributes
        }
        let editor = operatedInfo.userID
        for handler in pluginEventHandlers.allObjects {
            handler.onUsersInRoomAttributesUpdated(attributesMap, editor: editor, roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomStateChanged state: ZIMRoomState, event: ZIMRoomEvent, extendedData: [AnyHashable : Any], roomID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, roomStateChanged: state, event: event, extendedData: extendedData, roomID: roomID)
        }
      
        for handler in pluginEventHandlers.allObjects {
          handler.onIMRoomStateChanged(Int(state.rawValue), event: Int(event.rawValue), roomID: roomID)
        }
    }
    
    // MARK: - Invitation
    func zim(_ zim: ZIM, callInvitationReceived info: ZIMCallInvitationReceivedInfo, callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInvitationReceived: info, callID: callID)
        }
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInvitationReceived(callID, inviterID: info.inviter, data: info.extendedData)
        }
    }
    
    func zim(_ zim: ZIM, callInvitationCancelled info: ZIMCallInvitationCancelledInfo, callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInvitationCancelled: info, callID: callID)
        }
        
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInvitationCancelled(callID, inviterID: info.inviter, data: info.extendedData)
        }
    }
    
    func zim(_ zim: ZIM, callInvitationAccepted info: ZIMCallInvitationAcceptedInfo, callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInvitationAccepted: info, callID: callID)
        }
        
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInvitationAccepted(callID, inviteeID: info.invitee, data: info.extendedData)
        }
    }
    
    func zim(_ zim: ZIM, callInvitationRejected info: ZIMCallInvitationRejectedInfo, callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInvitationRejected: info, callID: callID)
        }
        
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInvitationRejected(callID, inviteeID: info.invitee, data: info.extendedData)
        }
    }
    
    func zim(_ zim: ZIM, callInvitationTimeout callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInvitationTimeout: callID)
        }
        
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInvitationTimeout(callID)
        }
    }
    
    func zim(_ zim: ZIM, callInviteesAnsweredTimeout invitees: [String], callID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, callInviteesAnsweredTimeout: invitees, callID: callID)
        }
        
        for handler in pluginEventHandlers.allObjects {
            handler.onCallInviteesAnsweredTimeout(callID, invitees: invitees)
        }
    }
    
    // MARK: - Message
    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, receivePeerMessage: messageList, fromUserID: fromUserID)
        }
    }
    
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, receiveRoomMessage: messageList, fromRoomID: fromRoomID)
        }
        
        var textMessages = [ZegoSignalingInRoomTextMessage]()
        var commandMessages = [ZegoSignalingInRoomCommandMessage]()
        for msg in messageList {
            if msg.type == .text {
                guard let msg = msg as? ZIMTextMessage else { continue }
                let newMsg = ZegoSignalingInRoomTextMessage(messageID: msg.messageID,
                                                                        timestamp: msg.timestamp,
                                                                        orderKey: msg.orderKey,
                                                                        senderUserID: msg.senderUserID,
                                                                        text: msg.message)
                textMessages.append(newMsg)
            } else if msg.type == .command {
                guard let msg = msg as? ZIMCommandMessage,
                      let command = String(data: msg.message, encoding: .utf8)
                else { continue }
                let newMsg = ZegoSignalingInRoomCommandMessage(messageID: msg.messageID,
                                                                        timestamp: msg.timestamp,
                                                                        orderKey: msg.orderKey,
                                                                        senderUserID: msg.senderUserID,
                                                               command: command)
                commandMessages.append(newMsg)
            }
        }
        for handler in pluginEventHandlers.allObjects {
            if textMessages.count > 0 {
                handler.onInRoomTextMessageReceived(textMessages, roomID: fromRoomID)
            }
            if commandMessages.count > 0 {
                handler.onInRoomCommandMessageReceived(commandMessages, roomID: fromRoomID)
            }
        }
        
    }
    
    func zim(_ zim: ZIM, receiveGroupMessage messageList: [ZIMMessage], fromGroupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, receiveGroupMessage: messageList, fromGroupID: fromGroupID)
        }
    }
        
    func zim(_ zim: ZIM, messageRevokeReceived messageList: [ZIMRevokeMessage]) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, messageRevokeReceived: messageList)
        }
    }
    
    func zim(_ zim: ZIM, messageReceiptChanged infos: [ZIMMessageReceiptInfo]) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, messageReceiptChanged: infos)
        }
    }
    
    func zim(_ zim: ZIM, messageSentStatusChanged messageSentStatusChangeInfoList: [ZIMMessageSentStatusChangeInfo]) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, messageSentStatusChanged: messageSentStatusChangeInfoList)
        }
    }
    
    // MARK: - Group
    func zim(_ zim: ZIM, groupStateChanged state: ZIMGroupState, event: ZIMGroupEvent, operatedInfo: ZIMGroupOperatedInfo, groupInfo: ZIMGroupFullInfo) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupStateChanged: state, event: event, operatedInfo: operatedInfo, groupInfo: groupInfo)
        }
    }
    
    func zim(_ zim: ZIM, groupNameUpdated groupName: String, operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupNameUpdated: groupName, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
    
    func zim(_ zim: ZIM, groupAvatarUrlUpdated groupAvatarUrl: String, operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupAvatarUrlUpdated: groupAvatarUrl, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
    
    func zim(_ zim: ZIM, groupNoticeUpdated groupNotice: String, operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupNoticeUpdated: groupNotice, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
    
    func zim(_ zim: ZIM, groupAttributesUpdated updateInfo: [ZIMGroupAttributesUpdateInfo], operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupAttributesUpdated: updateInfo, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
    
    func zim(_ zim: ZIM, groupMemberStateChanged state: ZIMGroupMemberState, event: ZIMGroupMemberEvent, userList: [ZIMGroupMemberInfo], operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupMemberStateChanged: state, event: event, userList: userList, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
    
    func zim(_ zim: ZIM, groupMemberInfoUpdated userInfo: [ZIMGroupMemberInfo], operatedInfo: ZIMGroupOperatedInfo, groupID: String) {
        for handler in zimEventHandlers.allObjects {
            handler.zim?(zim, groupMemberInfoUpdated: userInfo, operatedInfo: operatedInfo, groupID: groupID)
        }
    }
  
    func zim(_ zim: ZIM, messageReactionsChanged reactions: [ZIMMessageReaction]) {
      for handler in zimEventHandlers.allObjects {
        handler.zim?(zim,messageReactionsChanged: reactions)
      }
    }
    
}
