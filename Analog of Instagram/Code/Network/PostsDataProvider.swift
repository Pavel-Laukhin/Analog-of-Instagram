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
        queue.async {
            guard let request = getFeedRequest() else {
                completion(nil)
                return
            }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(#function, "http status: \(httpResponse.statusCode)")
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
                if let feed = try? decoder.decode([Post].self, from: data) {
                    print(feed)
                    completion(feed)
                } else {
                    print(#function, "Decode error")
                }
            }.resume()
        }
    }
    
    func usersLikedPost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping ([User]?) -> Void) {
        
    }
    
    func likePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    

    func unlikePost(with: Post.Identifier, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    
    func newPost(with: UIImage, description: String, queue: DispatchQueue, completion: @escaping (Post?) -> Void) {
        
    }
    
    private func getFeedRequest() -> URLRequest? {
        let urlComponents: URLComponents = {
            var urlComponents = URLComponents()
            urlComponents.scheme = K.Server.scheme
            urlComponents.host = K.Server.host
            urlComponents.port = K.Server.port
            urlComponents.path = K.Server.feedPath
            return urlComponents
        }()
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.addValue(DataProviders.shared.token, forHTTPHeaderField: "token")
        return request
    }
    
}
