//
//  AppUtils.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 11/07/25.
//

import Foundation

enum AppUtils {
    static var isUITestRunning: Bool {
        ProcessInfo.processInfo.arguments.contains("testMode")
    }
}
