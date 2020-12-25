//
//  PostsDataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

protocol PostsDataProviderProtocol {
    
    /// Возвращает публикации пользователей, на которых подписан текущий пользователь.
    func feed(queue: DispatchQueue, completion: @escaping ([Post]?) -> Void)
    
    /// Возвращает пользователей, поставивших лайк на публикацию с запрошенным ID. В completion передается массив [Post], но если публикация с запрошенным ID не найдена, то передается nil.
    func usersLikedPost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void)
    
    /// Ставит лайк от текущего пользователя на публикации с запрошенным ID. В completion передается Post в случае, если лайк поставлен успешно или был поставлен ранее; передается nil, если публикация с запрошенным ID не найдена.
    func likePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
    
    /// Удаляет лайк от текущего пользователя на публикации с запрошенным ID. В completion передается Post в случае, если лайк удалён успешно или был удалён ранее; передается nil, если публикация с запрошенным ID не найдена.
    func unlikePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
        
    /// Создает новую публикацию. В completion передается Post в случае, если он создан успешно; передается nil, если создать не удалось.
    func newPost(with: UIImage, description: String, queue: DispatchQueue, completion: @escaping (Post?) -> Void)
    
}

struct PostsDataProvider: PostsDataProviderProtocol {
    
    func feed(queue: DispatchQueue, completion: @escaping ([Post]?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .feed) { feed in
                completion(feed)
            }
        }
    }
    
    func usersLikedPost(with id: Post.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .usersLiked(postID: id)) { users in
                completion(users)
            }
        }
    }
    
    func likePost(with id: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .like(postID: id)) { post in
                completion(post)
            }
        }
    }
    

    func unlikePost(with id: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .unlike(postID: id)) { post in
                completion(post)
            }
        }
    }
    
    func newPost(with image: UIImage, description: String, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        queue.async {
            DataProviders.shared.performRequest(for: .createPost(withImage: image, description: description)) { post in
                completion(post)
            }
        }
    }
     
}
