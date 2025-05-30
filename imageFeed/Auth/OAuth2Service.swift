//
//  OAuth2Service.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 26/05/25.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return nil
        }
         guard let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
             + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
         ) else {
             return nil
         }
        var request = URLRequest(url: url)
        request.httpMethod = String(describing: HTTPMethod.post)
        return request
     }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = makeOAuthTokenRequest(code: code) else {
            print("Ошибка при создании запроса на получение токена авторизации")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Проверяем наличие ошибки
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                // Проверяем, что ответ – HTTP и статус 200...299
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("[OAuth2Service] Server returned status code: \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    return
                }
                // Убедимся, что данные не nil
                guard let data = data else {
                    print("[OAuth2Service] Empty response data")
                    completion(.failure(NetworkError.httpStatusCode(404)))
                    return
                }
                // Обрабатываем данные, например, конвертируем в строку
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    // print("Auth Token (service): " + response.accessToken)
                    completion(.success(response.accessToken))
                    
                } catch {
                    print("Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            } else {
                print("Данные отсутствуют")
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

