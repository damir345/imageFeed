//
//  Photo.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 27/06/25.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
