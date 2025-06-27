//
//  ImagesListService.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 27/06/25.
//

import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading: Bool = false
    private let perPage = 10
    private let session = URLSession.shared
    private let accessToken = OAuth2TokenStorage.shared.token

    private init() {}

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = (lastLoadedPage ?? 0) + 1
        
        // Собираем URL безопасно
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components?.url else {
            print("Не удалось создать URL")
            isLoading = false
            return
        }
        
        guard let token = accessToken else {
            print("Access token отсутствует")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Нет данных от сервера")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let photoResults = try decoder.decode([PhotoResult].self, from: data)

                let newPhotos: [Photo] = photoResults.map { result in
                    let size = CGSize(width: result.width, height: result.height)
                    let createdAtDate = ISO8601DateFormatter().date(from: result.createdAt ?? "")
                    return Photo(
                        id: result.id,
                        size: size,
                        createdAt: createdAtDate,
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                }

            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

