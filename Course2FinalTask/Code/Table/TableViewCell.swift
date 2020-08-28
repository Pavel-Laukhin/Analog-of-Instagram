//
//  TableViewCell.swift
//  Course2FinalTask
//
//  Created by Павел on 06.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class TableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            imageView!.image = user.avatar
            textLabel!.text = user.fullName
            setupLayout()
        }
    }
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
    // Настроим расположение картинки и текста:
    private func setupLayout() {
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
