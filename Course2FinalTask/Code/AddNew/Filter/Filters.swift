//
//  Filters.swift
//  Course2FinalTask
//
//  Created by Павел on 22.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

struct Filters {
    
    /// Array of tuples with two values: title - is used for displaying on screen, filter - is used for correct processing by CIFilter
    static let filtersArray = [
        (title: "Normal", filter: "Normal"),
        (title: "Blur", filter: "CIGaussianBlur"),
        (title: "Instant", filter: "CIPhotoEffectInstant"),
        (title: "ColorInvert", filter: "CIColorInvert"),
        (title: "SepiaTone", filter: "CISepiaTone"),
        (title: "Noir", filter: "CIPhotoEffectNoir"),
        (title: "Process", filter: "CIPhotoEffectProcess"),
        (title: "Fade", filter: "CIPhotoEffectFade"),
        (title: "Tonal", filter: "CIPhotoEffectTonal"),
        (title: "Transfer", filter: "CIPhotoEffectTransfer")
    ]
    
}
