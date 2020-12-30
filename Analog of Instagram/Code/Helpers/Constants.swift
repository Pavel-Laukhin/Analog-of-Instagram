//
//  Constants.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

/// Constants
enum K {
    
    enum Size {
        static let textFieldWidth: CGFloat = 300
        static let ofThumbnailPhotos: CGSize = CGSize(width: 50, height: 50)
    }
    
    enum Server {
        static let scheme = "http"
        static let host = "localhost"
        static let port = 8080
        static let signInPath = "/signin"
        static let signOutPath = "/signout"
    }
    
}
