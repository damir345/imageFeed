//
//  OAuth2Service.swift
//  imageFeed
//
//  Created by Damir Salakhetdinov on 26/05/25.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    // Соответствие названиям полей в JSON от Unsplash
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType   = "token_type"
        case scope
        case createdAt   = "created_at"
    }
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
         let baseURL = URL(string: "https://unsplash.com")!
         let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
             + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
         )!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Проверяем наличие ошибки
                if let error = error {
                    print("Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
            
                // Проверяем, что ответ – HTTP и статус 200...299
                if let httpResponse = response as? HTTPURLResponse,
                   (200...299).contains(httpResponse.statusCode) {
                    // Убедимся, что данные не nil
                    if let data = data {
                        // Обрабатываем данные, например, конвертируем в строку
                        //var responseString = String(data: data, encoding: .utf8)
                        //print("Ответ сервера: \(responseString ?? "Пусто")")
                        
                        //self.token = responseString
                        do {
                            let decoder = JSONDecoder()
                            let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                            print("Auth Token (service): " + response.accessToken)
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
                } else {
                    print("Некорректный ответ сервера")
                    if let error = error {
                        completion(.failure(error))
                    }
                }
        }
        task.resume()
    }
}

