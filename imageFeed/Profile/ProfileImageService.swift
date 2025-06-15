//
//  ProfileImageService.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 11/06/25.
//

import Foundation

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
        
        let getUsernameURL = "\(Constants.getUsernameURL)\(username)"
        guard let url = URL(string: getUsernameURL) else {
            print("[ProfileImageService.fetchProfileImageURL]: Error while making URL user username = \(username)")
            return
        }
        
        var request = URLRequest(url: url)
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
}
