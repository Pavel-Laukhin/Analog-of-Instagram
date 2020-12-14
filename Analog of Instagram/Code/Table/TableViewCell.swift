//
//  TableViewCell.swift
//  Course2FinalTask
//
//  Created by Павел on 06.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

final class TableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            //TODO: Kingfisher - с помощью него загружать аватар по ссылке:
            imageView!.image = UIImage(data: try! Data(contentsOf: URL(string: user.avatar)!))
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
