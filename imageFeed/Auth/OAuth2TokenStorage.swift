//
//  OAuth2TokenStorage.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 26/05/25.
//

import Foundation

final class OAuth2TokenStorage: Decodable {
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "accessToken")
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: "accessToken")
        }
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
    }
}

