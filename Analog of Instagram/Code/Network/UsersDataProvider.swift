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
            self.performRequest(for: .currentUser) { user in
                completion(user)
            }
        }
    }
    
    func user(with id: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
       queue.async {
            self.performRequest(for: .user(userID: id)) { user in
                completion(user)
            }
        }
    }
    
    func usersFollowingUser(with id: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        queue.async {
            self.performRequest(for: .followingUsers(userID: id)) { users in
                completion(users)
            }
        }
    }
    
    func usersFollowedByUser(with id: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        queue.async {
            self.performRequest(for: .followedUsers(userID: id)) { users in
                completion(users)
            }
        }
    }
    
    func follow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            self.performRequest(for: .follow(userID: userID)) { user in
                completion(user)
            }
        }
    }
    
    func unfollow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            self.performRequest(for: .unfollow(userID: userID)) { user in
                completion(user)
            }
        }
    }
    
    //MARK: - Generic
    private func performRequest<T: Decodable>(for purpose: DataProviders.Purpose, completion: @escaping (T?) -> Void) {
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
        case .currentUser, .user(_), .followingUsers(_), .followedUsers(_):
            request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
        case .follow(let userID), .unfollow(let userID):
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
            let jsonDict = ["userID": userID]
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict
                                                      , options: []) {
            request.httpBody = jsonData
            }
        }
        return request
    }
    
}
