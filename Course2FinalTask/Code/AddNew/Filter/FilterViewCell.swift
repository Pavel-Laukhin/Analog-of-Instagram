//
//  FilterViewCell.swift
//  Course2FinalTask
//
//  Created by Павел on 22.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FilterViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            contentView.addSubview(imageView)
            imageView.center.x = contentView.center.x
        }
    }
    var title: String? {
        didSet {
            guard let title = title else { return }
            textField.text = title
            textField.textAlignment = .center
            textField.sizeToFit()
            contentView.addSubview(textField)
            textField.frame = CGRect(
                x: 0,
                y: imageView.frame.maxY + 8,
                width: 120,
                height: textField.frame.height
            )
        }
    }
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return imageView
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .black
        return textField
    }()
    
}
