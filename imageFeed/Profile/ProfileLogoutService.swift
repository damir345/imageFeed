//
//  ProfileLogoutService.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 29/06/25.
//

import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() { }

    func logout(completion: @escaping () -> Void) {
        OAuth2TokenStorage.shared.clearToken()

        cleanCookies {
            ProfileService.shared.reset()
            ProfileImageService.shared.reset()
            ImagesListService.shared.reset()

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func cleanCookies(completion: @escaping () -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            let group = DispatchGroup()

            for record in records {
                group.enter()
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion()
            }
        }
    }
}
