//
//  FilterViewCell.swift
//  Course2FinalTask
//
//  Created by Павел on 22.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol AbleToReloadCollectionViewData {
    func reloadData()
}

final class FilterViewCell: UICollectionViewCell {
    
    var delegate: AbleToReloadCollectionViewData?
    
    var image: UIImage? {
        didSet {
            let queue = OperationQueue()
            let operation = FilterImageOperation(inputImage: image, filter: title ?? "CIBlur")
            operation.completionBlock = {
                DispatchQueue.main.async {
                    self.imageView.image = operation.outputImage
                    self.contentView.addSubview(self.imageView)
                    self.imageView.center.x = self.contentView.center.x
                    self.delegate?.reloadData()
                }
            }
            queue.addOperation(operation)
        }
    }
    var title: String? {
        didSet {
            guard let title = title else { return }
            label.text = title
            label.textAlignment = .center
            label.sizeToFit()
            contentView.addSubview(label)
            label.frame = CGRect(
                x: 0,
                y: imageView.frame.maxY + 8,
                width: 120,
                height: label.frame.height
            )
        }
    }
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 6, width: 50, height: 50)
        return imageView
    }()
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
}
