//
//  UsersDataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import Foundation

protocol UsersDataProviderProtocol {
    
    /// Возвращает информацию о текущем пользователе.
    func currentUser(queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
    /// Возвращает информацию о пользователе с запрошенным ID.
    func user(with: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
    /// Возвращает подписчиков пользователя с запрошенным ID.
    func usersFollowingUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Возвращает подписки пользователя с запрошенным ID.
    func usersFollowedByUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Подписывает текущего пользователя на пользователя с запрошенным ID.
    func follow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
    /// Отписывает текущего пользователя от пользователя с запрошенным ID.
    func unfollow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
}

struct UsersDataProvider: UsersDataProviderProtocol {
    
    func currentUser(queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            guard let request = getCurrentUserRequest() else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(#function, "http status code: \(httpResponse.statusCode)")
                }
                guard error == nil else {
                    completion(nil)
                    return
                }
                guard let data = data else {
                    completion(nil)
                    return
                }
                let decoder = JSONDecoder()
                guard let user = try? decoder.decode(User.self, from: data) else { completion(nil)
                    return
                }
                completion(user)
            }.resume()
        }
    }
    
    func user(with: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        
    }
    
    func usersFollowingUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        
    }
    
    func usersFollowedByUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        
    }
    
    func follow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        
    }
    
    func unfollow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        
    }
    
    private func getCurrentUserRequest() -> URLRequest? {
        let urlComponents: URLComponents = {
            var urlComponents = URLComponents()
            urlComponents.scheme = K.Server.scheme
            urlComponents.host = K.Server.host
            urlComponents.port = K.Server.port
            urlComponents.path = K.Server.currentUserPath
            return urlComponents
        }()
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
        return request
    }
    
}
