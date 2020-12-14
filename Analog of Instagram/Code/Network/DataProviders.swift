//
//  DataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 09.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

protocol DataProvider {
    
    var usersDataProvider: UsersDataProvider { get }
    var postsDataProvider: PostsDataProvider { get }
    var photoProvider: PhotosDataProvider { get }
    
    /// Авторизует пользователя и выдает токен.
    func signIn(login: String, password: String, completion: @escaping (NetworkError?) -> Void)
    
    /// Деавторизует пользователя и инвалидирует токен.
    func signOut(queue: DispatchQueue, completion: @escaping (Result<HTTPURLResponse, NetworkError>) -> Void)
    
}

enum NetworkError: Error {
    case badRequest(String)
    case noData(String)
    case noToken(String)
    case incorrectJSONString(String)
    case dataTaskError(String)
}

final class DataProviders: DataProvider {
    
    static let shared = DataProviders()
    
    private(set) var token = ""
    
    var usersDataProvider = UsersDataProvider()
    var postsDataProvider = PostsDataProvider()
    var photoProvider = PhotosDataProvider()
    
    private init() {}
    
    func signIn(login: String, password: String, completion: @escaping (NetworkError?) -> Void) {
        guard let result = getSignInRequest(login: login, password: password) else {
            completion(.badRequest("\(#function): Bad URLComponents!"))
            return
        }
        switch result {
        case .failure(let error):
            print(error)
            return
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(#function, "http status code: \(httpResponse.statusCode)")
                }
                guard error == nil else {
                    completion(.dataTaskError("\(#function): Data task error: \(error!.localizedDescription)"))
                    return
                }
                guard let data = data else {
                    completion(.noData("\(#function): Can't fetch data in data task!"))
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                      let fetchedToken = json["token"] else {
                    completion(.noToken("\(#function): Failed to fetch a token in data task!"))
                    return
                }
                self.token = fetchedToken
                completion(nil)
            }.resume()
        }
    }
    
    private func getSignInRequest(login: String, password: String) -> Result<URLRequest, NetworkError>? {
        let urlComponents: URLComponents = {
            var urlComponents = URLComponents()
            urlComponents.scheme = K.Server.scheme
            urlComponents.host = K.Server.host
            urlComponents.port = K.Server.port
            urlComponents.path = K.Server.signInPath
            return urlComponents
        }()
        guard let url = urlComponents.url else { return nil }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let dictionary = ["login": login, "password": password]
        guard let json = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return .failure(.incorrectJSONString("Incorrect JSON string!")) }
        request.httpBody = json
        return .success(request)
    }
    
    func signOut(queue: DispatchQueue, completion: @escaping (Result<HTTPURLResponse, NetworkError>) -> Void) {
        queue.async {
            guard let request = self.getSignOutRequest() else {
                completion(.failure(.badRequest("\(#function): Bad URLComponents!")))
                return
            }
            URLSession.shared.dataTask(with: request) { _, response, _ in
                guard let httpResponse = response as? HTTPURLResponse else { return }
                print(#function, "http status code: \(httpResponse.statusCode)")
                completion(.success(httpResponse))
            }.resume()
        }
    }
    
    private func getSignOutRequest() -> URLRequest? {
        let urlComponents: URLComponents = {
            var urlComponents = URLComponents()
            urlComponents.scheme = K.Server.scheme
            urlComponents.host = K.Server.host
            urlComponents.port = K.Server.port
            urlComponents.path = K.Server.signOutPath
            return urlComponents
        }()
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(token, forHTTPHeaderField: "token")
        return request
    }
    
    enum Purpose {
        case currentUser
        case user(userID: User.Identifier)
        case followingUsers(userID: User.Identifier)
        case followedUsers(userID: User.Identifier)
        case follow(userID: User.Identifier)
        case unfollow(userID: User.Identifier)
        
        var url: URL? {
            return createURL(for: self)
        }
        
        private func createURL(for purpose: Purpose) -> URL? {
            let path: String
            switch purpose {
            case .currentUser:
                path = K.Server.currentUserPath
            case .user(let userID):
                path = "/users/\(userID)"
            case .followingUsers(let userID):
                path = "/users/\(userID)/followers"
            case .followedUsers(let userID):
                path = "/users/\(userID)/following"
            case .follow(_):
                path = "/users/follow"
            case .unfollow(_):
                path = "/users/unfollow"
            }
            let urlComponents: URLComponents = {
                var urlComponents = URLComponents()
                urlComponents.scheme = K.Server.scheme
                urlComponents.host = K.Server.host
                urlComponents.port = K.Server.port
                urlComponents.path = path
                return urlComponents
            }()
            guard let url = urlComponents.url else { return nil }
            return url
        }
    }
    
}

/// Защита от случайного клонирования
extension DataProviders: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
}
