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
    
    weak var delegate: TransitionProtocol?
    
    // Реализация перехода с помощью колбэка (чисто для себя потестить, как это работает):
    var callback: ((User.Identifier) -> Void)?
    var transitionState: TransitionState = .delegate
    
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss aaa"
        return formatter
    }
    
    var post: Post? {
        didSet {
            
            // Установка кнопки isLike:
            addIsLikeButton()
            
            // Обновляем интерфейс:
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
    private weak var isLikeButton: UIButton?
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
    
//    deinit {
//        
//        print("deinit")
//        
//        // Обнуление визуальных данных ячейки:
//        postImageView.image = nil
//        avatarImageView.image = nil
//        authorNameLabel.text = nil
//        dateLabel.text = nil
//        numberOfLikesLabel.text = nil
//        descriptionLabel.text = nil
////
////        // Обнуление данных ячейки:
////        post = nil
//    }
    
    // MARK: - Life cycle
    private func addIsLikeButton() {
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
        isLikeButton = button
        contentView.addSubview(isLikeButton!)
    }
    
    private func updateUI() {
        
        guard let post = self.post else { return }
        avatarImageView.image = post.authorAvatar
        authorNameLabel.text = post.authorUsername
        dateLabel.text = self.formatter.string(from: post.createdTime)
        postImageView.image = post.image
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
         bigLikeImageView
            ].forEach { contentView.addSubview($0) }
    }
    
    // Добавляем распознаватель жестов
    private func addGestureRecognizer() {
        contentView.addGestureRecognizer(doubleTapGestureRecognizer)
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Теперь настроим фреймы:
    private func setupLayout() {
                
        guard let isLikeButton = isLikeButton  else { return }
        
        deactivateAutoresizingMask(in: [
            avatarImageView,
            authorNameLabel,
            dateLabel,
            postImageView,
            isLikeButton,
            numberOfLikesLabel,
            descriptionLabel,
            bigLikeImageView
        ])
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            avatarImageView.widthAnchor.constraint(equalToConstant: 35),
            avatarImageView.heightAnchor.constraint(equalToConstant: 35),
            
            
            authorNameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            authorNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            authorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            dateLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 15),

            postImageView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
            
            isLikeButton.topAnchor.constraint(equalTo: postImageView.bottomAnchor),
            isLikeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            isLikeButton.widthAnchor.constraint(equalToConstant: 44),
            isLikeButton.heightAnchor.constraint(equalToConstant: 44),

            numberOfLikesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            numberOfLikesLabel.centerYAnchor.constraint(equalTo: isLikeButton.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: isLikeButton.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            bigLikeImageView.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            bigLikeImageView.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc func isLikeButtonPressed() {
        switch  isCurrentUserLikesThisPost {
        case true:
            guard let isLikeButton = isLikeButton else { return }
            isCurrentUserLikesThisPost = false
            isLikeButton.tintColor = .lightGray
            if !isInTheProcessOfChangingLikeState {
                isInTheProcessOfChangingLikeState = true
                toMarkAsUnliked()
            }
        case false:
            guard let isLikeButton = isLikeButton else { return }
            isCurrentUserLikesThisPost = true
            isLikeButton.tintColor = .systemBlue
            if !isInTheProcessOfChangingLikeState {
                isInTheProcessOfChangingLikeState = true
                toMarkAsLiked()
            }
        default:
            print("isLikeButtonPressed: ERROR: isCurrentUserLikesThisPost = nil")
        }
    }
    
    private func toMarkAsUnliked() {
        DataProviders.shared.postsDataProvider.unlikePost(with: post!.id, queue: queue) { [weak self] post in
            guard let self = self else { return }
            guard let post = post else {
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self.delegate as! UIViewController)
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
                print("Unliked in DataProvider")
                self.isInTheProcessOfChangingLikeState = false
            } else {
                print("Unliked in DataProvider BUT NEED TO CHANGE")
                self.toMarkAsLiked()
            }
        }
    }
    
    private func toMarkAsLiked() {
        DataProviders.shared.postsDataProvider.likePost(with: post!.id, queue: queue) { [weak self] post in
            guard let self = self else { return }
            guard let post = post else {
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self.delegate as! UIViewController)
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
                print("Liked in DataProvider")
                self.isInTheProcessOfChangingLikeState = false
            } else {
                print("Liked in DataProvider BUT NEED TO CHANGE")
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

//Добавляем глобальную очередь
extension FeedCell {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}

extension FeedCell {
    
    private func deactivateAutoresizingMask(in views: [UIView]) {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
}
