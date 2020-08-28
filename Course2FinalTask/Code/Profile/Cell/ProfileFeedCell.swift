//
//  ProfileFeedCell.swift
//  Course2FinalTask
//
//  Created by Павел on 05.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class ProfileFeedCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            postImageView.image = post.image
            addSubviews()
            setupLayout()
        }
    }
    
    var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private func addSubviews() {
        contentView.addSubview(postImageView)
    }
    
    private func setupLayout() {
        postImageView.frame = contentView.bounds
    }
    
    
}
