//
//  ZIMKitCore.swift
//  Pods-ZegoPlugin
//
//  Created by Kael Ding on 2022/12/8.
//

import Foundation

class ZIMKitLogUtil: NSObject {
    static let shared = ZIMKitLogUtil()
    
    private override init() {}
    
    func int
    func logDebug(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        print("[Debug] \(filter) - \(file):\(line) \(funcName) - \(message)")
    }
    
    func logTraceInfo(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        print("[Info] \(filter) - \(file):\(line) \(funcName) - \(message)")
    }
    
    func logTraceWarning(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        print("[Warning] \(filter) - \(file):\(line) \(funcName) - \(message)")
    }
    
    func logTraceError(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        print("[Error] \(filter) - \(file):\(line) \(funcName) - \(message)")
    }
    
    func logTraceCacheInfo(filter: String, file: String, funcName: String, line: Int, tag: Int, format: String, arguments: CVarArg...) {
        let message = String(format: format, arguments: arguments)
        print("[Cache Info] \(filter) - \(file):\(line) \(funcName) - \(message)")
    }
}


func ZAALogD(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logDebug(filter: filterName, file: #file, funcName: #function, line: #line, tag: 0, format: format, arguments: arguments)
}

func ZAALogI(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceInfo(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

func ZAALogW(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceWarning(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

func ZAALogE(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceError(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

func ZAALogLocal(filterName: String, format: String, arguments: CVarArg...) {
    ZIMKitLogUtil.shared.logTraceCacheInfo(filter: filterName, file: #file, funcName: #function, line: #line, tag: 1215, format: format, arguments: arguments)
}

