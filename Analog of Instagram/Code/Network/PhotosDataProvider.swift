//
//  PhotosDataProvider.swift
//  Analog of Instagram
//
//  Created by Павел on 12.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

protocol PhotosDataProviderProtocol {
    
    /// Возвращает массив фотографий для новых постов.
    mutating func photos() -> [UIImage]
    
    /// Возвращает массив уменьшенных фотографий для предосмотра для новых постов.
    mutating func thumbnailPhotos() -> [UIImage]
    
}

struct PhotosDataProvider: PhotosDataProviderProtocol {
    
    private var photosArray: [UIImage] = []
    private var thumbnailPhotosArray: [UIImage] = []
    
    mutating func photos() -> [UIImage] {
        if photosArray.isEmpty {
            for i in 1...8 {
                if let image = UIImage(named: "new\(i)") {
                    photosArray.append(image)
                }
            }
        }
        return photosArray
    }
    
    mutating func thumbnailPhotos() -> [UIImage] {
        if thumbnailPhotosArray.isEmpty {
            for photo in photos() {
                let resizedPhoto = photo.resizeImage(targetSize: K.Size.ofThumbnailPhotos)
                thumbnailPhotosArray.append(resizedPhoto)
            }
        }
        return thumbnailPhotosArray
    }
    
}
