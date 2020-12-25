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
    
    /// Возвращает информацию о пользователе с запрошенным ID. В completion передается User в случае успеха; передается nil, если пользователь с запрошенным ID не найден.
    func user(with: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
    /// Возвращает подписчиков пользователя с запрошенным ID. В completion передается массив [User] в случае успеха; передается nil, если пользователь с запрошенным ID не найден.
    func usersFollowingUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Возвращает подписки пользователя с запрошенным ID. В completion передается массив [User] в случае успеха; передается nil, если пользователь с запрошенным ID не найден.
    func usersFollowedByUser(with: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Подписывает текущего пользователя на пользователя с запрошенным ID. В completion передается User, если пользователь успешно подписан или уже является подписчиком; передается nil, если пользователь с запрошенным ID не найден, либо при попытке подписаться на самого себя.
    func follow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
    /// Отписывает текущего пользователя от пользователя с запрошенным ID. В completion передается User, если пользователь успешно отписан или уже не является подписчиком; передается nil, если пользователь с запрошенным ID не найден, либо при попытке отписаться от самого себя.
    func unfollow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void)
    
}

struct UsersDataProvider: UsersDataProviderProtocol {
    
    func currentUser(queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .currentUser) { user in
                completion(user)
            }
        }
    }
    
    func user(with id: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .user(userID: id)) { user in
                completion(user)
            }
        }
    }
    
    func usersFollowingUser(with id: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .followingUsers(userID: id)) { users in
                completion(users)
            }
        }
    }
    
    func usersFollowedByUser(with id: User.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .followedUsers(userID: id)) { users in
                completion(users)
            }
        }
    }
    
    func follow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .follow(userID: userID)) { user in
                completion(user)
            }
        }
    }
    
    func unfollow(_ userID: User.Identifier, queue: DispatchQueue, completion: @escaping (User?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .unfollow(userID: userID)) { user in
                completion(user)
            }
        }
    }
    
}
