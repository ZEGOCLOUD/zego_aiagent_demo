//
//  ZegoUIKitSignalingPluginService+RoomProperties.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by zego on 2022/12/20.
//

import Foundation
import ZIM
import ZegoPluginAdapter

extension ZegoUIKitSignalingPluginService {
    
    public func updateRoomProperty(_ attributes: [String : String], roomID: String, isForce: Bool, isDeleteAfterOwnerLeft: Bool, isUpdateOwner: Bool, callback: RoomPropertyOperationCallback?) {
        let config = ZIMRoomAttributesSetConfig()
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
        config.isForce = isForce
        config.isUpdateOwner = isUpdateOwner
        zim?.setRoomAttributes(attributes, roomID: roomID, config: config, callback: { roomID, errorKeys, error in
            callback?(error.code.rawValue, error.message, errorKeys)
        })
    }
    
    public func deleteRoomProperties(by keys: [String], roomID: String, isForce: Bool, callback: RoomPropertyOperationCallback?) {
        let config = ZIMRoomAttributesDeleteConfig()
        config.isForce = isForce
        zim?.deleteRoomAttributes(by: keys, roomID: roomID, config: config, callback: { roomID, errorKeys, error in
            callback?(error.code.rawValue, error.message, errorKeys)
        })
    }
    
    public func beginRoomPropertiesBatchOperation(with roomID: String, isDeleteAfterOwnerLeft: Bool, isForce: Bool, isUpdateOwner: Bool) {
        let config = ZIMRoomAttributesBatchOperationConfig()
        config.isForce = isForce
        config.isDeleteAfterOwnerLeft = isDeleteAfterOwnerLeft
        config.isUpdateOwner = isUpdateOwner
        zim?.beginRoomAttributesBatchOperation(with: roomID, config: config)
    }
    
    public func endRoomPropertiesBatchOperation(with roomID: String, callback: EndRoomBatchOperationCallback?) {
        zim?.endRoomAttributesBatchOperation(with: roomID, callback: { roomID, error in
            callback?(error.code.rawValue, error.message)
        })
    }
    
    public func queryRoomProperties(by roomID: String, callback: QueryRoomPropertyCallback?) {
        zim?.queryRoomAllAttributes(by: roomID, callback: { roomID, roomAttributes, error in
            callback?(error.code.rawValue, error.message, roomAttributes)
        })
    }
}
