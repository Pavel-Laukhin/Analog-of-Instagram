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
    
    /// Затемняющая вьюха, работающая вместе с индикатором активности
    private lazy var activityIndicatorShadowView: UIView = {
        let view = UIView()
        view.frame = CGRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: contentView.bounds.height
        )
        view.backgroundColor = .black
        view.alpha = 0.7
        view.frame = contentView.bounds
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.center = contentView.center
        return indicator
    }()
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            turnActivityOff()
            postImageView.image = post.image
            addSubviews()
            setupLayout()
        }
    }
    
    private var postImageView: UIImageView = {
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


// ДОбавляем включениеи выключение индикатора активности:
extension ProfileFeedCell {
    
    func turnActivityOn() {
        [activityIndicatorShadowView,
         activityIndicator
            ].forEach { contentView.addSubview($0) }
        activityIndicatorShadowView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func turnActivityOff() {
        activityIndicator.stopAnimating()
        activityIndicatorShadowView.isHidden = true
        activityIndicator.isHidden = true
    }
    
}
