//
//  ProfileViewProtocol.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 8/07/25.
//

import Foundation

protocol ProfileViewProtocol: AnyObject {
    func updateProfile(name: String?, login: String?, bio: String?)
    func updateAvatar(url: URL?)
    func showLogoutConfirmation()
}
