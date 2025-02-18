//
//  ZegoSignalingProvider+Plugin.swift
//  ZegoUIKitSignalingPlugin
//
//  Created by zego on 2022/12/15.
//

import Foundation
import ZegoPluginAdapter

extension ZegoSignalingProvider: ZegoPluginProvider {
    public func getPlugin() -> ZegoPluginProtocol? {
        ZegoUIKitSignalingPlugin.shared
    }
}
