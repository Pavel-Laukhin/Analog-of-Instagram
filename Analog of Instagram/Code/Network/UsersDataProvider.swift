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
    
}
