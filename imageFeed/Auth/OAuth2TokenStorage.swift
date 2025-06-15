//
//  OAuth2TokenStorage.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 26/05/25.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "accessToken"
    
    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            print("[OAuth2TokenStorage]: Retrieved token from Keychain: \(token ?? "nil")")
            return token
        }
        set {
            if let token = newValue {
                let success = KeychainWrapper.standard.set(token, forKey: tokenKey)
                if success {
                    print("[OAuth2TokenStorage]: Saved token to Keychain")
                } else {
                    print("[OAuth2TokenStorage]: Failed to save token to Keychain")
                }
            } else {
                let removed = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("[OAuth2TokenStorage]: Token removed from Keychain: \(removed)")
            }
        }
    }
    
    func clearToken() {
        let removed = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        print("[OAuth2TokenStorage]: clearToken - Token removed: \(removed)")
    }
}
