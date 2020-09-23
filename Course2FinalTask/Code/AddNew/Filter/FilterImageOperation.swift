//
//  FilterImageOperation.swift
//  Course2FinalTask
//
//  Created by Павел on 23.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FilterImageOperation: Operation {
    
    private var _inputImage: UIImage?
    private(set) var outputImage: UIImage?
    private var _chosenFilter: String?
    
    init(inputImage: UIImage?, filter: String) {
        self._chosenFilter = filter
        self._inputImage = inputImage
    }
    
    override func main() {
                
        // Создаем контекст
        let context = CIContext()
        
        // Создаем CIImage
        guard let coreImage = CIImage(image: _inputImage!) else { return }
        
        // Создаем фильтр
        guard let filter = CIFilter(name: _chosenFilter!) else { return }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        // Добавляем фильтр к изображению
        guard let filteredImage = filter.outputImage else { return }
        
        // Применяем фильтр
        guard let cgImage = context.createCGImage(filteredImage,
                                                  from: filteredImage.extent) else { return }
        
        // Создаем UIImage
        outputImage = UIImage(cgImage: cgImage)
    }
    
}
