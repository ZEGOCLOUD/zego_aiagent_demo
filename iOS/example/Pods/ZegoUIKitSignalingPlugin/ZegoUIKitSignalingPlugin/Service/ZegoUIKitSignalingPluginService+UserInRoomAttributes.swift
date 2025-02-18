//
//  ZegoUIKitSignalingPluginService+UserInRoomAttributes.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by zego on 2022/12/20.
//

import Foundation
import ZIM
import ZegoPluginAdapter

extension ZegoUIKitSignalingPluginService {
    
    public func joinRoom(with roomID: String, roomName: String?, callBack: RoomCallback?) {
        let roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName ?? ""
        let config = ZIMRoomAdvancedConfig()
        zim?.enterRoom(with: roomInfo, config: config, callback: { info, error in
            let reportData = ["room_id": roomID as AnyObject,
                              "room_name": roomName as AnyObject,
                              "error": error.code.rawValue as AnyObject,
                              "msg": error.message]
            ReportUtil.sharedInstance().reportEvent(zimJoinRoomReportString, paramsDict: reportData)
            callBack?(error.code.rawValue, error.message)
        })
    }
    
    public func leaveRoom(by roomID: String, callBack: RoomCallback?) {
        zim?.leaveRoom(by: roomID, callback: { roomID, error in
            
            let reportData = ["room_id": roomID as AnyObject,
                              "error": error.code.rawValue as AnyObject,
                              "msg": error.message]
            ReportUtil.sharedInstance().reportEvent(zimLeaveRoomReportString, paramsDict: reportData)
            
            callBack?(error.code.rawValue, error.message)
        })
    }
    
    public func setUsersInRoomAttributes(with attributes: [String : String], userIDs: [String], roomID: String, callback: SetUsersInRoomAttributesCallback?) {
        let config = ZIMRoomMemberAttributesSetConfig()
        zim?.setRoomMembersAttributes(attributes, userIDs: userIDs, roomID: roomID, config: config, callback: { roomID, infos, errorUserList, error in
            let code = error.code.rawValue
            let message = error.message
            
            var attributeMap: [String: [String : String]] = [:]
            var errorKeysMap: [String: [String]] = [:]
            for info in infos {
                let userID: String = info.attributesInfo.userID
                attributeMap[userID] = info.attributesInfo.attributes
                let errorKeys: [String] = info.errorKeys
                errorKeysMap[userID] = errorKeys
            }
            callback?(code,message,errorUserList,attributeMap,errorKeysMap)
        })
    }
    
    public func queryUsersInRoomAttributes(by roomID: String, count: UInt32, nextFlag: String, callback: QueryUsersInRoomAttributesCallback?) {
        let config = ZIMRoomMemberAttributesQueryConfig()
        config.nextFlag = nextFlag
        config.count = count
        zim?.queryRoomMemberAttributesList(by: roomID, config: config, callback: { roomID, infos, nextFlag, error in
            let code = error.code.rawValue
            let message = error.message
            
            var attributeMap: [String: [String : String]] = [:]
            for info in infos {
                let userID: String = info.userID
                attributeMap[userID] = info.attributes
            }
            callback?(code, message, nextFlag, attributeMap)
        })
    }
    
}
