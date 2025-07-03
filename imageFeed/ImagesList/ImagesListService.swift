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

    private var accessToken: String? {
        OAuth2TokenStorage.shared.token
    }

    static let isoDateFormatter = ISO8601DateFormatter()

    private init() {}

    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = (lastLoadedPage ?? 0) + 1

        var components = URLComponents(url: Constants.photosURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components?.url else {
            print("[ImagesListService.fetchPhotosNextPage]: failedToConstructURL page=\(nextPage)")
            isLoading = false
            return
        }

        guard let token = accessToken else {
            print("[ImagesListService.fetchPhotosNextPage]: noToken page=\(nextPage)")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            defer { self.isLoading = false }

            if let error = error {
                print("[ImagesListService.fetchPhotosNextPage]: networkError \(error.localizedDescription) page=\(nextPage)")
                return
            }

            guard let data = data else {
                print("[ImagesListService.fetchPhotosNextPage]: noData page=\(nextPage)")
                return
            }

            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)

                // Используем инициализатор из расширения
                let newPhotos = photoResults.map(Photo.init)

                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                }
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? "nil"
                print("[ImagesListService.fetchPhotosNextPage]: decodingError \(error.localizedDescription) page=\(nextPage) response=\(responseString)")
            }
        }

        task.resume()
    }

    func reset() {
        photos = []
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = accessToken else {
            print("[ImagesListService.changeLike]: noToken photoId=\(photoId)")
            completion(.failure(NSError(domain: "NoToken", code: 401, userInfo: nil)))
            return
        }

        let url = Constants.likePhotoURL(for: photoId)

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            if let error = error {
                print("[ImagesListService.changeLike]: networkError \(error.localizedDescription) photoId=\(photoId) isLike=\(isLike)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("[ImagesListService.changeLike]: badStatusCode code=\(statusCode) photoId=\(photoId) isLike=\(isLike)")
                let error = NSError(domain: "BadStatusCode", code: statusCode, userInfo: nil)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                }

                completion(.success(()))
            }
        }

        task.resume()
    }
}




