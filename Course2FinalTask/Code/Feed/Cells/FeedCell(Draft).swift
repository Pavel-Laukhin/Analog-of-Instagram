//
//  FeedCell(Draft).swift
//  Course2FinalTask
//
//  Created by Павел on 06.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

final class FeedCellDraft: UICollectionViewCell {
    
    var delegate: TransitionProtocol?
    
    // До того, как я увидел, что есть методы like и unlike, я использовал вот эти танцы с бубном
//    private var likedByCount = 0 {
//        willSet {
//            numberOfLikesLabel.text = "Likes: \(newValue)"
//        }
//    }
//
//    /// Свойство, которое помогает корректно отобразить количество лайков при нажатии на кнопку Like. Без этого свойства почему-то будет некорректно отображаться предыдущее значение количества лайков при повторном нажатии кнопки. Словно увеличение или уменьшение количества лайков (likedByCount) в методе isLikeButtonPressed не изменяет текущее значение количества лайков. Похоже, что любое увеличение цифры в этом методе меняет копию от первоначального значения, но не само значение. Пример: было 3 лайка, среди которых был лайк текущего юзера. Ставим "дизлайк" и становится 2 (пока что все верно), а потом ставим обратно "лайк" и показывается не 3, как было изначально, а 4, как будто прибавление единицы к likedByCount прибавилось не к текущему количеству (2 лайка), а к первоначальному (3 лайка). В итоге, мне пришлось схитрить и внедрить нижеследующее свойство. :] Оно выставляется true в инициализации самой кнопки, если юзер изначально уже был в числе тех, кто лайкнул текущий пост.
//    private var isCurrentUserLikedThisPostBefore = false
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' HH:mm:ss aaa"
        return formatter
    }
    
    var post: Post? {
        didSet {
            guard let post = post else { return }
            avatarImageView.image = post.authorAvatar
            authorNameLabel.text = post.authorUsername
            dateLabel.text = formatter.string(from: post.createdTime)
            postImageView.image = post.image
                // До того, как я увидел, что есть методы like и unlike, я использовал вот эти танцы с бубном
//            likedByCount = post.likedByCount
            numberOfLikesLabel.text = "Likes: \(post.likedByCount)"
            descriptionLabel.text = post.description
            addSubviews()
            addGestureRecognizer()
            setupLayout()
        }
    }
    
    
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
                    // До того, как я увидел, что есть методы like и unlike, я использовал вот эти танцы с бубном
//                isCurrentUserLikedThisPostBefore = true
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
    
    lazy private var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapHandler(sender:)))
        tgr.numberOfTapsRequired = 2
        return tgr
    }()
    
}

private extension FeedCellDraft {
    // MARK: - Life cycle
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
        
            // До того, как я увидел, что есть методы like и unlike, я использовал вот эти танцы с бубном
        //        switch post?.currentUserLikesThisPost {
        //        case true:
        //            post!.currentUserLikesThisPost = false
        //            isLikeButton.tintColor = .lightGray
        //            if isCurrentUserLikedThisPostBefore {
        //                likedByCount -= 1
        //            } else {
        //                numberOfLikesLabel.text = "Likes: \(likedByCount)"
        //            }
        //        case false:
        //            post!.currentUserLikesThisPost = true
        //            isLikeButton.tintColor = .systemBlue
        //            if isCurrentUserLikedThisPostBefore {
        //                numberOfLikesLabel.text = "Likes: \(likedByCount)"
        //            } else {
        //                likedByCount += 1
        //            }
        //        default:
        //            ()
        //        }
        
        // Правильный вариант
        switch  post?.currentUserLikesThisPost {
        case true:
            post?.currentUserLikesThisPost = false
            DataProviders.shared.postsDataProvider.unlikePost(with: post!.id, queue: queue) { post in
                if post == nil {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self.delegate as! UIViewController)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLikeButton.tintColor = .lightGray
                        self.numberOfLikesLabel.text = "Likes: \(post!.likedByCount)"
                    }
                }
            }
        case false:
            post?.currentUserLikesThisPost = true
            DataProviders.shared.postsDataProvider.likePost(with: post!.id, queue: queue) { post in
                if post == nil {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self.delegate as! UIViewController)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLikeButton.tintColor = .systemBlue
                        self.numberOfLikesLabel.text = "Likes: \(post!.likedByCount)"
                    }
                }
            }
        default:
            ()
        }
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer) {
        if postImageView.frame.contains(sender.location(in: contentView)) {
            isLikeButtonPressed()
            bigLikeAppearance()
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
extension FeedCellDraft {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}
