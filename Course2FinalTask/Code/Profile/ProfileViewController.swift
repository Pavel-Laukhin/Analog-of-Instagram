//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider


class ProfileViewController: UIViewController {
    
    var user: User?
    
    /// Статус, определяющий, следит ли наш текущий юзер за данным юзером или нет
    var isFollowed: Bool?
//    {
//        return user?.currentUserFollowsThisUser
//    }

    var postsCount: Int?  {
        get {
            guard let user = user else { return nil }
            var count: Int?
            DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: queue) { posts in
                if posts != nil {
                    count = posts!.count
                }
            }
            while count == nil {
                ()
            }
            return count
        }
    }
    
    private let scrollView = UIScrollView()
    
    // MARK: - Visual elements
    private var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var userFullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    private lazy var followersButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var followingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var collectionView: UICollectionView = {
        // 1. Делаем дефолтный макет, иначе наша коллекшн вью не сможет понять, как ей отрисовывать наши ячейки на экране:
        let layout = UICollectionViewFlowLayout()
        // 2. Делаем экземпляр класса коллекшн вью. Можно передать во фрейм "зиро", то есть нулевой прямоугольник. Ничего страшного, потому что потом этот фрейм растянется, как нам надо:
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // 3. Регистрируем ячейку:
        collectionView.register(ProfileFeedCell.self, forCellWithReuseIdentifier: String(describing: ProfileFeedCell.self))
        // 4. Указываем наш контроллер источником информации и делегатом:
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        // 5.Возвращаем результат:
        return collectionView
    }()
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Если ничего не известно про статус isFollowed, то значит это текущий юзер, и кнопку отображать не нужно
        guard isFollowed != nil else {
            button.isHidden = true
            return button
        }
        if isFollowed == false {
            button.setTitle("Follow", for: .normal)
        } else {
            button.setTitle("Unfollow", for: .normal)
        }
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Делаем инициализатор, который может принимать юзера:
    init(user: User, isFollowed: Bool? = nil) {
        self.user = user
        self.isFollowed = isFollowed
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        view.backgroundColor = .white
        updateUI()
        addSubviews()
        setUpLayout()
    }
    
    private func updateUI() {
        print("updateUI")
        guard let user = user else { return }
        navigationItem.title = user.username
        avatarImageView.image = user.avatar
        userFullNameLabel.text = user.fullName
        followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
        followingButton.setAttributedTitle(NSAttributedString(string: "Following: \(user.followsCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
    }
    
    private func addSubviews() {
        print("addSubviews")
        view.addSubview(scrollView)
        [avatarImageView,
         userFullNameLabel,
         followersButton,
         followingButton,
         collectionView,
         followButton
            ].forEach { scrollView.addSubview($0) }
    }
    
    private func setUpLayout() {
        print("setUpLayout")
        let topInset: CGFloat = 8
        let collectionViewInset: CGFloat = 8
        
        scrollView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
        
        avatarImageView.frame = CGRect(
            x: 8,
            y: topInset,
            width: 70,
            height: 70
        )
        avatarImageView.layer.cornerRadius = 35

        userFullNameLabel.sizeToFit()
        userFullNameLabel.frame = CGRect(
            x: avatarImageView.frame.maxX + 8,
            y: topInset,
            width: userFullNameLabel.frame.width,
            height: userFullNameLabel.frame.height
        )
        
        followersButton.sizeToFit()
        followersButton.frame = CGRect(
            x: avatarImageView.frame.maxX + 8,
            y: avatarImageView.frame.maxY - followersButton.frame.height,
            width: followersButton.frame.width,
            height: followersButton.frame.height
        )
        
        followingButton.sizeToFit()
        followingButton.frame = CGRect(
            x: view.bounds.width - followingButton.frame.width - 16,
            y: avatarImageView.frame.maxY - followingButton.frame.height,
            width: followingButton.frame.width,
            height: followingButton.frame.height
        )
        
        followButton.sizeToFit()
        followButton.frame = CGRect(
            x: view.bounds.width - followButton.frame.width - 16,
            y: topInset,
            width: followButton.frame.width,
            height: followButton.frame.height
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: avatarImageView.frame.maxY + collectionViewInset,
            width: view.bounds.width,
            height: view.bounds.height - topInset - avatarImageView.frame.height - collectionViewInset
        )
        
        let contentHeight = topInset + avatarImageView.frame.height + collectionViewInset + collectionView.collectionViewLayout.collectionViewContentSize.height
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: contentHeight)
    }
    
    // MARK: - Actions
    @objc func followingButtonTapped() {
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: user!.id, queue: queue) { users in
            if users != nil {
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(TableViewController(users: users!, title: "Following"), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self)
                }
            }
        }
    }
    
    @objc func followersButtonTapped() {
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: user!.id, queue: queue) { users in
            if users != nil {
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(TableViewController(users: users!, title: "Followers"), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self)
                }
            }
        }
    }
    
    @objc func followButtonTapped() {
        if isFollowed == false {
            followButton.setTitle("Follow", for: .normal)
            followingButton.sizeToFit()
        } else {
            followButton.setTitle("Unfollow", for: .normal)
            followingButton.sizeToFit()
        }
    }
    
}

//Добавляем глобальную очередь
extension ProfileViewController {
        
    var queue: DispatchQueue { DispatchQueue.global() }
    
}
