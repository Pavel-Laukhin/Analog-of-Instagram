//
//  PostsDataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol PostsDataProviderProtocol {
    
    /// Возвращает публикации пользователей, на которых подписан текущий пользователь.
    func feed(queue: DispatchQueue, completion: @escaping ([Post]?) -> Void)
    
//    /// Возвращает пост с запрошенным ID.
//    func post(queue: DispatchQueue)
//
//    /// Возвращает публикации пользователя с запрошенным ID.
//    func posts(queue: DispatchQueue)
    
    /// Возвращает пользователей, поставивших лайк на публикацию с запрошенным ID.
    func usersLikedPost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Ставит лайк от текущего пользователя на публикации с запрошенным ID.
    func likePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
    
    //TODO: описание
    /// Удаляет лайк от текущего пользователя на публикации с запрошенным ID. Возвращает пост в случае, если лайк поставлен успешно или был поставлен ранее. Возвращает nil, если публикация с запрошенным ID не найдена.
    func unlikePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
        
    /// Создает новую публикацию.
    func newPost(with: UIImage, description: String, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
    
}

struct PostsDataProvider: PostsDataProviderProtocol {
    
    func feed(queue: DispatchQueue, completion: @escaping ([Post]?) -> Void) {
        
    }
    
    func usersLikedPost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        
    }
    
    func likePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    

    func unlikePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    
    func newPost(with: UIImage, description: String, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    
}
