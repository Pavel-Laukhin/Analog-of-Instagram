//
//  FeedCell.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

enum TransitionState {
    case delegate, callback
}

final class FeedCell: UICollectionViewCell {
    
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
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.center = contentView.center
        return indicator
    }()
    
    var indexOfCell: Int? {
        didSet {
            
            // Обнуление визуальных данных ячейки:
            postImageView.image = nil
            avatarImageView.image = nil
            authorNameLabel.text = ""
            dateLabel.text = ""
            numberOfLikesLabel.text = ""
            isLikeButton.isHidden = true
            descriptionLabel.text = ""
            
            
            // Установка активити индикатора и его фона:
            [activityIndicatorShadowView, activityIndicator].forEach {contentView.addSubview($0)}
            activityIndicatorShadowView.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            
            // Достаем пост из провайдера:
            guard let indexOfCell = indexOfCell else { return }
            DataProviders.shared.postsDataProvider.feed(queue: queue) { (postsArray: [Post]?) -> Void in
                if let post = postsArray?[indexOfCell] {
                    
                    // Проверяем, не поменялся ли наш индекс. Если индекс не изменился, то обновляем UI. Это нужно, чтобы запоздавшие задачи из очереди не заменили нам текущий контент.
                    if indexOfCell == self.indexOfCell {
                        self.post = post
                        DispatchQueue.main.async {
                            self.updateUI()
                        }
                    }
                }
            }
        }
    }
    
    var delegate: TransitionProtocol?
    
    // Реализация перехода с помощью колбэка (чисто для себя потестить, как это работает):
    var callback: ((User.Identifier) -> Void)?
    var transitionState: TransitionState = .delegate
    
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss aaa"
        return formatter
    }
    
    var post: Post?
    
    // MARK: - Visual properties
    private var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    private var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private var numberOfLikesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var isLikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        if let isLike = post?.currentUserLikesThisPost {
            if isLike {
                button.tintColor = .systemBlue
            } else {
                button.tintColor = .lightGray
            }
        }
        button.addTarget(self, action: #selector(isLikeButtonPressed), for: .touchUpInside)
        return button
    }()
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    private var bigLikeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bigLike")
        imageView.alpha = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Gesture recognizers
    lazy private var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(sender:)))
        tgr.numberOfTapsRequired = 2
        return tgr
    }()
    
    lazy private var tapGestureRecognizer: UITapGestureRecognizer = {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:)))
        tgr.numberOfTapsRequired = 1
        return tgr
    }()
    
}

private extension FeedCell {
    // MARK: - Life cycle
    
    private func updateUI() {
        
        // Выключаетм и убираем активити индикатор с его затемняющей вью.
        activityIndicatorShadowView.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        guard let post = self.post else { return }
        avatarImageView.image = post.authorAvatar
        authorNameLabel.text = post.authorUsername
        dateLabel.text = self.formatter.string(from: post.createdTime)
        postImageView.image = post.image
        numberOfLikesLabel.text = "Likes: \(post.likedByCount)"
        descriptionLabel.text = post.description
        isLikeButton.isHidden = false
        addSubviews()
        addGestureRecognizer()
        setupLayout()
    }
    
    // Для начала добавим все наши созданные объекты на вью ячейки:
    private func addSubviews() {
        [avatarImageView,
         authorNameLabel,
         dateLabel,
         postImageView,
         numberOfLikesLabel,
         isLikeButton,
         descriptionLabel,
         bigLikeImageView
            ].forEach { contentView.addSubview($0) }
    }
    
    // Добавляем распознаватель жестов
    private func addGestureRecognizer() {
        contentView.addGestureRecognizer(doubleTapGestureRecognizer)
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
//        // Второй способ добавления распознавателя жестов:
//        postImageView.addGestureRecognizer(doubleTapGestureRecognizer)
//        // Эти методы надо создавать отдельно, так как один и тот же распознаватель будет работать лишь с тем вью, на который он был добавлен последним (почему-то именно так работает):
//        avatarImageView.addGestureRecognizer(avatarTapGestureRecognizer)
//        authorNameLabel.addGestureRecognizer(authorTapGestureRecognizer)
//        numberOfLikesLabel.addGestureRecognizer(likedByTapGestureRecognizer)
//        // Втрой способ требует включения этого свойства:
//        postImageView.isUserInteractionEnabled = true
//        avatarImageView.isUserInteractionEnabled = true
//        authorNameLabel.isUserInteractionEnabled = true
//        numberOfLikesLabel.isUserInteractionEnabled = true
    }
    
    // Теперь настроим фреймы:
    private func setupLayout() {
        
        avatarImageView.frame = CGRect(
            x: 15,
            y: 8,
            width: 35,
            height: 35
        )
        
        authorNameLabel.sizeToFit()
        authorNameLabel.frame = CGRect(
            x: avatarImageView.frame.maxX + 8,
            y: 8,
            width: contentView.bounds.width - (avatarImageView.frame.maxX + 8),
            height: authorNameLabel.frame.height
        )
        authorNameLabel.sizeToFit()
        
        dateLabel.sizeToFit()
        dateLabel.frame = CGRect(
            x: avatarImageView.frame.maxX + 8,
            y: avatarImageView.frame.maxY - dateLabel.frame.height,
            width: contentView.bounds.width - (avatarImageView.frame.maxX + 8),
            height: dateLabel.frame.height
        )
        dateLabel.sizeToFit()
        
        postImageView.frame = CGRect(
            x: 0,
            y: avatarImageView.frame.maxY + 8,
            width: contentView.bounds.width,
            height: contentView.bounds.width
        )
        
        isLikeButton.frame = CGRect(
            x: contentView.bounds.width - 15 - 44,
            y: postImageView.frame.maxY,
            width: 44,
            height: 44
        )
        
        NSLayoutConstraint.activate([
            numberOfLikesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            numberOfLikesLabel.centerYAnchor.constraint(equalTo: isLikeButton.centerYAnchor, constant: 0)
        ])
        
        descriptionLabel.sizeToFit()
        descriptionLabel.frame = CGRect(
            x: 15,
            y: isLikeButton.frame.maxY,
            width: contentView.bounds.width - 15 - 15,
            height: descriptionLabel.frame.height
        )
        descriptionLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            bigLikeImageView.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor, constant: 0),
            bigLikeImageView.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor, constant: 0)
        ])
    }
    
    // MARK: - Actions
    @objc func isLikeButtonPressed() {
        switch  post?.currentUserLikesThisPost {
        case true:
            post?.currentUserLikesThisPost = false
            self.isLikeButton.tintColor = .lightGray
            DataProviders.shared.postsDataProvider.unlikePost(with: post!.id, queue: queue) { post in
                if post == nil {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self.delegate as! UIViewController)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.numberOfLikesLabel.text = "Likes: \(post!.likedByCount)"
                    }
                }
            }
        case false:
            post?.currentUserLikesThisPost = true
            self.isLikeButton.tintColor = .systemBlue
            DataProviders.shared.postsDataProvider.likePost(with: post!.id, queue: queue) { post in
                if post == nil {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self.delegate as! UIViewController)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.numberOfLikesLabel.text = "Likes: \(post!.likedByCount)"
                    }
                }
            }
        default:
            ()
        }
    }
    
    @objc func doubleTapHandler(sender: UITapGestureRecognizer) {
        if postImageView.frame.contains(sender.location(in: contentView)) {
            isLikeButtonPressed()
            bigLikeAppearance()
        }
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer) {
        guard let post = post else { return }
        if avatarImageView.frame.contains(sender.location(in: contentView)) ||  authorNameLabel.frame.contains(sender.location(in: contentView)) {
            // Переход к страничке юзера:
            if transitionState == .delegate {
                delegate?.showProfile(userId: post.author)
            } else {
                callback?(post.author)
            }
        }
        if numberOfLikesLabel.frame.contains(sender.location(in: contentView)) {
            // Переход к списку лайкнувших юзеров:
            delegate?.showListOfUsersLikedThisPost(postId: post.id)
        }
    }
    
    func bigLikeAppearance() {
        let appearanceAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
        let firstKeyTime = NSNumber(value: 0.1 / 0.6)
        let secondKeyTime = NSNumber(value: 0.3 / 0.6)
        appearanceAnimation.keyTimes = [0, firstKeyTime, secondKeyTime, 1]
        appearanceAnimation.values = [0, 1, 1, 0]
        appearanceAnimation.duration = 0.6
        bigLikeImageView.layer.add(appearanceAnimation, forKey: "shakeAnimation")
    }
    
}

//Добавляем глобальную очередь
extension FeedCell {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}
