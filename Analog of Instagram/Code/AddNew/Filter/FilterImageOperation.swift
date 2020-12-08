//
//  FilterImageOperation.swift
//  Course2FinalTask
//
//  Created by Павел on 23.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FilterImageOperation: Operation {
    
    private var inputImage: UIImage?
    private(set) var outputImage: UIImage?
    private var chosenFilter: String?
    
    init(inputImage: UIImage?, filter: String) {
        self.chosenFilter = filter
        self.inputImage = inputImage
    }
    
    override func main() {
                
        // Создаем контекст
        let context = CIContext()
        
        // Создаем CIImage
        guard let inputImage = inputImage,
              let coreImage = CIImage(image: inputImage) else { return }
        
        // Создаем фильтр
        guard let chosenFilter = chosenFilter,
              let filter = CIFilter(name: chosenFilter) else { return }
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
