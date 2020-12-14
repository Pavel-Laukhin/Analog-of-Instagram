//
//  Post.swift
//  Analog of Instagram
//
//  Created by Павел on 10.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

struct Post {
    
    typealias Identifier = String
    
    let id: Identifier
    let description: String
    
    //TODO: заменить на String
    let image: UIImage
    
    //TODO: заменить на String
    let createdTime: Date
    
    let currentUserLikesThisPost: Bool
    let likedByCount: Int
    let author: String
    let authorUsername: String
    let authorAvatar: UIImage
    
}
