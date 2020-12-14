//
//  User.swift
//  Analog of Instagram
//
//  Created by Павел on 10.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

struct User: Codable {
    
    typealias Identifier = String
    
    let id: Identifier
    let username: String
    let fullName: String
    let avatar: String
    let currentUserFollowsThisUser: Bool
    let currentUserIsFollowedByThisUser: Bool
    let followsCount: Int
    let followedByCount: Int
    
}
