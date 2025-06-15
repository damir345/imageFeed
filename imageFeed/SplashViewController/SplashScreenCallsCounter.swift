//
//  SplashScreenCallsCounter.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 10/06/25.
//

import Foundation

final class SplashScreenCallsCounter: Decodable {
    
    static let shared = SplashScreenCallsCounter()
    private init() {}
    
    var callsCounter: Int = 0
    
}
