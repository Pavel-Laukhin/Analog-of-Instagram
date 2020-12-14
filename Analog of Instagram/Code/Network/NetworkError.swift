//
//  NetworkError.swift
//  Analog of Instagram
//
//  Created by Павел on 14.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case badRequest(String)
    case noData(String)
    case noToken(String)
    case incorrectJSONString(String)
    case dataTaskError(String)
}
