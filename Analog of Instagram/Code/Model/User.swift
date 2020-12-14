//
//  User.swift
//  Analog of Instagram
//
//  Created by Павел on 10.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

struct User {
    
    typealias Identifier = String
    
    let id: String
    let username: String
    let fullName: String
    
    //TODO: заменить на String
    let avatar: UIImage
    
    let currentUserFollowsThisUser: Bool
    let currentUserIsFollowedByThisUser: Bool
    let followsCount: Int
    let followedByCount: Int
    
}
