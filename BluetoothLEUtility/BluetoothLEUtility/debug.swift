//
//  debug.swift
//  BluetoothLEUtility
//
//  Created by 藤治仁 on 2020/01/06.
//  Copyright © 2020 F-Works. All rights reserved.
//

import Foundation

///デバックモード設定
func debugLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("[\(function):\(line)] : \(obj)")
    } else {
        print("[\(function):\(line)]")
    }
    #endif
}

func errorLog(_ obj: Any?,
              function: String = #function,
              line: Int = #line) {
    #if DEBUG
    if let obj = obj {
        print("ERROR [\(function):\(line)] : \(obj)")
    } else {
        print("ERROR [\(function):\(line)]")
    }
    #endif
}

var isSimulator:Bool {
    get {
        #if targetEnvironment(simulator)
        // iOS simulator code
        return true
        #else
        return false
        #endif
    }
}
