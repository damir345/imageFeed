//
//  ProfileService.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 10/06/25.
//

import Foundation

// MARK: - ProfileResult: структура для декодирования JSON-ответа от Unsplash
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

// MARK: - Profile: структура для UI
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

// MARK: - ProfileService: загрузка профиля
final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: Failure - invalid request")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let result):
                    let name = [result.firstName, result.lastName].compactMap { $0 }.joined(separator: " ")
                    let profile = Profile(
                        username: result.username,
                        name: name,
                        loginName: "@\(result.username)",
                        bio: result.bio
                    )
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Failure - \(error.localizedDescription), token: \(token)")
                    completion(.failure(error))
                }

                self.task = nil
            }
        }

        task?.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.makeProfileRequest]: Failure - invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = String(describing: HTTPMethod.get)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Ошибки
enum ProfileServiceError: Error {
    case invalidRequest
    case decodingError
}
