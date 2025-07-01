//
//  UserResult.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 15/06/25.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

