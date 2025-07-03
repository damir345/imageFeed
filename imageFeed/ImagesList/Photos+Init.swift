//
//  Photos+Init.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 2/07/25.
//

import Foundation

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = ImagesListService.isoDateFormatter.date(from: result.createdAt ?? "")
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
