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

    func logout() {
        // Удаляем сохранённый токен
        OAuth2TokenStorage.shared.clearToken()

        // Очищаем куки и данные WebView
        cleanCookies()

        // Сбрасываем сервисы
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()

        // Переход на начальный экран
        switchToSplashViewController()
    }

    private func cleanCookies() {
        // Удаляем HTTP-куки
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        // Удаляем данные WebView
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { return }

        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }
}
