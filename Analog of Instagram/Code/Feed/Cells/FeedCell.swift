//
//  FeedCell.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

enum TransitionState {
    case delegate, callback
}

final class FeedCell: UICollectionViewCell {
    
    weak var delegate: TransitionProtocol?
    private var queue: DispatchQueue { DispatchQueue.global() }
    
    // Реализация перехода с помощью колбэка (чисто для себя потестить, как это работает):
    var callback: ((User.Identifier) -> Void)?
    var transitionState: TransitionState = .delegate
    
    var post: Post? {
        didSet {
            updateUI()
        }
    }
    
    private var isCurrentUserLikesThisPost: Bool?
    
    /// Запущен ли процесс лайка/дизлайка в данный момент
    private var isInTheProcessOfChangingLikeState = false
    
    // MARK: - Visual properties
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var numberOfLikesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var isLikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        if let post = post {
            if post.currentUserLikesThisPost {
                button.tintColor = .systemBlue
                isCurrentUserLikesThisPost = true
            } else {
                button.tintColor = .lightGray
                isCurrentUserLikesThisPost = false
            }
        }
        button.addTarget(self, action: #selector(isLikeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bigLikeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bigLike")
        imageView.alpha = 0
        return imageView
    }()
    
    // MARK: - Gesture recognizers
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(sender:)))
        tgr.numberOfTapsRequired = 2
        return tgr
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:)))
        tgr.numberOfTapsRequired = 1
        return tgr
    }()
    
    /// Данный констрейнт поможет сделать descriptionLabel растягивающимся вниз
    private lazy var maxWidthConstraint = NSLayoutConstraint(item: descriptionLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: .zero)
    
    /// Максимальная ширина, которая поможет сделать descriptionLabel растягивающимся вниз
    lazy var maxWidth: CGFloat? = nil {
        didSet {
            guard let maxWidth = maxWidth else { return }
            contentView.translatesAutoresizingMaskIntoConstraints = false
            maxWidthConstraint.constant = maxWidth - 30
            maxWidthConstraint.isActive = true
        }
    }
    
    // MARK: - Life cycle
    private func updateUI() {
        guard let post = self.post else { return }
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: URL(string: post.authorAvatar))
        authorNameLabel.text = post.authorUsername
        dateLabel.text = post.createdTime
        postImageView.kf.indicatorType = .activity
        postImageView.kf.setImage(with: URL(string: post.image))
        numberOfLikesLabel.text = "Likes: \(post.likedByCount)"
        descriptionLabel.text = post.description
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
         descriptionLabel,
         bigLikeImageView,
         isLikeButton].forEach { contentView.addSubview($0) }
    }
    
    // Добавляем распознаватель жестов
    private func addGestureRecognizer() {
        contentView.addGestureRecognizer(doubleTapGestureRecognizer)
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Теперь настроим фреймы:
    private func setupLayout() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(15)
            make.width.height.equalTo(35)
        }
        
        authorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            make.trailing.equalTo(contentView).offset(-15)
        }
        
        postImageView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(postImageView.snp.width)
        }
        
        isLikeButton.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom)
            make.trailing.equalTo(contentView).offset(-15)
            make.width.height.equalTo(44)
        }
        
        numberOfLikesLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(15)
            make.centerY.equalTo(isLikeButton)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(isLikeButton.snp.bottom)
            make.leading.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView)
        }
        
        bigLikeImageView.snp.makeConstraints { make in
            make.center.equalTo(postImageView)
        }
    }
    
    // Без этого метода в консоль посыпятся ошибки констрейнтов моей self-size ячейки:
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.contentView.frame = self.bounds
        self.contentView.layoutIfNeeded()
        return self.contentView.frame.size
      }
    
    // MARK: - Actions
    @objc func isLikeButtonPressed() {
        switch  isCurrentUserLikesThisPost {
        case true:
            isCurrentUserLikesThisPost = false
            isLikeButton.tintColor = .lightGray
            if !isInTheProcessOfChangingLikeState {
                isInTheProcessOfChangingLikeState = true
                toMarkAsUnliked()
            }
        case false:
            isCurrentUserLikesThisPost = true
            isLikeButton.tintColor = .systemBlue
            if !isInTheProcessOfChangingLikeState {
                isInTheProcessOfChangingLikeState = true
                toMarkAsLiked()
            }
        default:
            print(type(of: self), #function, "ERROR: isCurrentUserLikesThisPost = nil")
        }
    }
    
    private func toMarkAsUnliked() {
        DataProviders.shared.postsDataProvider.unlikePost(with: post!.id, queue: queue) { [weak self] post in
            guard let self = self else { return }
            guard let post = post else {
                DispatchQueue.main.async {
                    Alert.show(withMessage: "Please, try again later.")
                }
                return
            }
            
            // Прежде чем менять статус лайка, метод должен проверить, не передумал ли юзер, пока процесс выполнялся (не нажал ли юзер снова кнопку Like/Unlike). Если передумал, то тогда нужно запустить обратный процесс:
            if !(self.isCurrentUserLikesThisPost ?? false) {
                DispatchQueue.main.async {
                    self.numberOfLikesLabel.text = "Likes: \(post.likedByCount)"
                    self.numberOfLikesLabel.sizeToFit()
                }
                
                // Сообщаем, что процесс лайка/дизлайка закончен и меняем соответствующий статус у переменной:
                print(type(of: self), #function, "Unliked in DataProvider")
                self.isInTheProcessOfChangingLikeState = false
            } else {
                print(type(of: self), #function, "Unliked in DataProvider BUT NEED TO CHANGE")
                self.toMarkAsLiked()
            }
        }
    }
    
    private func toMarkAsLiked() {
        DataProviders.shared.postsDataProvider.likePost(with: post!.id, queue: queue) { [weak self] post in
            guard let self = self else { return }
            guard let post = post else {
                DispatchQueue.main.async {
                    Alert.show(withMessage: "Please, try again later.")
                }
                return
            }
            
            // Прежде чем менять статус лайка, метод должен проверить, не передумал ли юзер, пока процесс выполнялся (не нажал ли юзер снова кнопку Like/Unlike). Если передумал, то тогда нужно запустить обратный процесс:
            if self.isCurrentUserLikesThisPost ?? true {
                DispatchQueue.main.async {
                    self.numberOfLikesLabel.text = "Likes: \(post.likedByCount)"
                    self.numberOfLikesLabel.sizeToFit()
                }
                
                // Сообщаем, что процесс лайка/дизлайка закончен и меняем соответствующий статус у переменной:
                print(type(of: self), #function, "Liked in DataProvider")
                self.isInTheProcessOfChangingLikeState = false
            } else {
                print(type(of: self), #function, "Liked in DataProvider BUT NEED TO CHANGE")
                self.toMarkAsUnliked()
            }
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
