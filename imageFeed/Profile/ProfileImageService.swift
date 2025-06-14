//
//  ProfileImageService.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 11/06/25.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}

    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?

    func fetchProfileImageURL(_ username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if lastUsername == username { return }

        task?.cancel()
        lastUsername = username

        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: Failure - token not found")
            return
        }

        var request = URLRequest(url: makeURL(username: username))
        request.httpMethod = String(describing: HTTPMethod.get)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                self.lastUsername = nil

                switch result {
                case .success(let userResult):
                    let avatarURL = userResult.profileImage.small
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: Failure - \(error.localizedDescription), username: \(username)")
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    private func makeURL(username: String) -> URL {
        return URL(string: "https://api.unsplash.com/users/\(username)")!
    }
}
