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
    func signOut(queue: DispatchQueue, completion: @escaping () -> Void)
    
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
    
    func signOut(queue: DispatchQueue, completion: @escaping () -> Void) {
        queue.async {
            guard let request = self.getSignOutRequest() else { return }
            URLSession.shared.dataTask(with: request) { _, response, _ in
                guard let httpResponse = response as? HTTPURLResponse else { return }
                print(#function, "http status code: \(httpResponse.statusCode)")
                completion()
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
        case feed
        case usersLiked(postID: Post.Identifier)
        case like(postID: Post.Identifier)
        case unlike(postID: Post.Identifier)
        case createPost(withImage: UIImage, description: String)
        
        var url: URL? {
            return createURL(for: self)
        }
        
        private func createURL(for purpose: Purpose) -> URL? {
            let path: String
            switch purpose {
            case .currentUser:
                path = "/users/me"
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
            case .feed:
                path = "/posts/feed"
            case .usersLiked(let postID):
                path = "/posts/\(postID)/likes"
            case .like(_):
                path = "/posts/like"
            case .unlike(_):
                path = "/posts/unlike"
            case .createPost(_, _):
                path = "/posts/create"
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
    
    //MARK: - Generic
    func performRequest<T: Decodable>(for purpose: DataProviders.Purpose, completion: @escaping (T?) -> Void) {
        guard let request = getRequest(for: purpose) else {
            print(#function, "No request received!")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print(#function, "http status:\(httpResponse.statusCode)")
            }
            guard error == nil else {
                print(#function, error!.localizedDescription)
                completion(nil)
                return
            }
            guard let data = data else {
                print(#function, "No data received!")
                completion(nil)
                return
            }
            let decoder = JSONDecoder()
            if let value = try? decoder.decode(T.self, from: data) {
                completion(value)
            } else {
                print(#function, "No value received from decoder!")
                completion(nil)
            }
        }.resume()
    }
    
    private func getRequest(for purpose: DataProviders.Purpose) -> URLRequest? {
        guard let url = purpose.url else { return nil }
        var request = URLRequest(url: url)
        switch purpose {
        case .currentUser, .user(_), .followingUsers(_), .followedUsers(_), .feed, .usersLiked(_):
            request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
        case .follow(_), .unfollow(_), .like(_), .unlike(_), .createPost(_, _):
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
            
            // Создаю пустой словарь и заполняю его в зависимости от цели. Этот словарь будет потом преобразован в JSON и передан в тело запроса.
            var jsonDict: [String: String]?
            switch purpose {
            case .follow(let userID), .unfollow(let userID):
                jsonDict = ["userID": userID]
            case .like(let postID), .unlike(let postID):
                jsonDict = ["postID": postID]
            case .createPost(let image, let description):
                guard let imageData = image.pngData() else { break }
                let imageBase64String = imageData.base64EncodedString(options: .lineLength64Characters)
                jsonDict = [:]
                if jsonDict != nil {
                    jsonDict!["image"] = imageBase64String
                    jsonDict!["description"] = description
                }
            default:
                jsonDict = nil
            }
            guard let dict = jsonDict,
               let jsonData = try? JSONSerialization.data(withJSONObject: dict
                                                          , options: []) else { break }
            request.httpBody = jsonData
        }
        return request
    }
    
}

/// Защита от случайного клонирования
extension DataProviders: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
}
