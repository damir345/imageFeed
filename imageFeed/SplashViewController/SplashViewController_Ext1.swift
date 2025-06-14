//
//  SplashViewController_Ext1.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 10/06/25.
//

import UIKit

extension SplashViewController /*: AuthViewControllerDelegate*/ {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }

    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { /* [weak self] */ result in
            UIBlockingProgressHUD.dismiss()
            
            //guard let self = self else { return }
            
            switch result {
                case .success:
                    self.switchToTabBarController()
                    guard let username = ProfileService.shared.profile?.username else {
                        print("Failed to get username from user profile singletone")
                        return
                    }
                    self.fetchProfileImageURL(username)
                    
                case .failure:
                    print("Profile load error")
                    break
                }
        }
    }
    
    func fetchProfileImageURL(_ username: String) {
        UIBlockingProgressHUD.show()
        ProfileImageService.shared.fetchProfileImageURL(username) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
               self.switchToTabBarController()

            case .failure:
                print("ProfileImageURL load error")
                break
            }
        }
    }
}
