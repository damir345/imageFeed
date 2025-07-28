//
//  ProfilePresenter.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {

    weak var view: ProfileViewProtocol?

    private var profileImageServiceObserver: NSObjectProtocol?

    func viewDidLoad() {
        let profile = ProfileService.shared.profile
        view?.updateProfile(
            name: profile?.name,
            login: profile?.loginName,
            bio: profile?.bio
        )

        if let urlString = ProfileImageService.shared.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(url: url)
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if let urlString = ProfileImageService.shared.avatarURL,
               let url = URL(string: urlString) {
                self.view?.updateAvatar(url: url)
            }
        }
    }

    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
}
