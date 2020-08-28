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
    
    private let scrollView = UIScrollView()
    
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
        DataProviders.shared.usersDataProvider.currentUser(queue: queue) { currentUser in
            if currentUser != nil {
                DispatchQueue.main.async {
                    label.text = currentUser!.fullName
                }
            } else {
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self)
                }
            }
        }
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
    
    // Делаем инициализатор, который может принимать юзера:
    init(user: User? = nil) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        updateController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Если юзер есть, то ничего не передаем. Если нет, то ставим текущего юзера:
        if user == nil {
            DataProviders.shared.usersDataProvider.currentUser(queue: queue) { currentUser in
                if currentUser != nil {
                    self.user = currentUser
                } else {
                    Alert.showBasic(vc: self)
                }
            }
        }
        
        view.backgroundColor = .white
        addSubviews()
        updateController()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        [avatarImageView,
         userFullNameLabel,
         followersButton,
         followingButton,
         collectionView
            ].forEach { scrollView.addSubview($0) }
    }
    
    private func updateController() {
        guard let user = user else { return }
        navigationItem.title = user.username
        avatarImageView.image = user.avatar
        userFullNameLabel.text = user.fullName
        followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
        followingButton.setAttributedTitle(NSAttributedString(string: "Following: \(user.followsCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupLayout()
    }
    
    private func setupLayout() {
        
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
}

//Добавляем глобальную очередь
extension ProfileViewController {
        
    var queue: DispatchQueue { DispatchQueue.global() }
    
}
