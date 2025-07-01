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
        print("OAuth2Service.makeOAuthTokenRequest: code = \(code)")
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
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("OAuth2Service.fetchOAuthToken: code = \(code)")
        
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                // b) fetchOAuthToken() был вызван сначала с одним code,
                //    но спустя некоторое время, когда первый запрос
                //    ещё не успел завершиться,
                //    был вызван с другим значением кода;
                print("case b")
                task?.cancel()
            } else {
                // а) fetchOAuthToken() был вызван два раза подряд
                //    с одинаковым code (второй вызов не дожидается
                //    завершения первого);
                print("case a")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                // c) fetchOAuthToken() всегда возвращает через замыкание
                //    результат своей работы: неважно выполнили мы запрос
                //    токена или нет, это поможет лучше понимать, как именно
                //    отработала функция в точке вызова.
                //
                print("case c")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            print("[OAuth2Service.fetchOAuthToken]: Failure – invalid request, code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    completion(.success(response.accessToken))
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: Failure – \(error.localizedDescription), code: \(code)")
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastCode = nil
            }
        }

        self.task = task
        task.resume()
    }
}

