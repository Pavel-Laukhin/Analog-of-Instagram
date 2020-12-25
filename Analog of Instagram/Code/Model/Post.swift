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
    let image: String
    let rawTime: String
    let createdTime: String
    let currentUserLikesThisPost: Bool
    let likedByCount: Int
    let author: String
    let authorUsername: String
    let authorAvatar: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case image
        case rawTime = "createdTime"
        case currentUserLikesThisPost
        case likedByCount
        case author
        case authorUsername
        case authorAvatar
    }
    
}

extension Post: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.description = try container.decode(String.self, forKey: .description)
        self.image = try container.decode(String.self, forKey: .image)
        self.rawTime = try container.decode(String.self, forKey: .rawTime)
        self.currentUserLikesThisPost = try container.decode(Bool.self, forKey: .currentUserLikesThisPost)
        self.likedByCount = try container.decode(Int.self, forKey: .likedByCount)
        self.author = try container.decode(String.self, forKey: .author)
        self.authorUsername = try container.decode(String.self, forKey: .authorUsername)
        self.authorAvatar = try container.decode(String.self, forKey: .authorAvatar)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date = formatter.date(from: self.rawTime)
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MMM d, yyyy 'at' HH:mm:ss aaa"
        self.createdTime = formatter2.string(from: date ?? Date())

    }
}
