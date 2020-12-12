//
//  PhotosDataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol PhotosDataProviderProtocol {
    
    /// Возвращает массив фотографий для новых постов.
    func photos() -> [UIImage]
    
    /// Возвращает массив уменьшенных фотографий для предосмотра для новых постов.
    func thumbnailPhotos() -> [UIImage]
    
}

struct PhotosDataProvider: PhotosDataProviderProtocol {
    
    //TODO: Добавить фотки
    func photos() -> [UIImage] {
        return []
    }
    
    //TODO: Добавить фотки
    func thumbnailPhotos() -> [UIImage] {
        return []
    }
    
}
