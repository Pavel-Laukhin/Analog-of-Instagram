//
//  TableViewCell.swift
//  Course2FinalTask
//
//  Created by Павел on 06.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit
import Kingfisher

final class TableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            imageView!.kf.indicatorType = .activity
            imageView!.kf.setImage(with: URL(string: user.avatar))
            textLabel!.text = user.fullName
            setUpLayout()
        }
    }
    
    // Настроим расположение картинки и текста:
    private func setUpLayout() {
        imageView?.frame = CGRect(
            x: 15,
            y: 0,
            width: contentView.frame.height,
            height: contentView.frame.height
        )
        
        guard let imageView = imageView else { return }
        textLabel?.frame = CGRect(
            x: imageView.frame.maxX + 16,
            y: 0,
            width: contentView.frame.width - imageView.frame.maxX + 16,
            height: contentView.frame.height
        )
    }
    
}
