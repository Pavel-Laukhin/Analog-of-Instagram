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
    
    /// Дополнительный статус, определяющий, следит ли наш текущий юзер за данным юзером или нет
    var isFollowed: Bool?
    var allPosts: [Post]? {
        didSet {
            print("user: \(user?.username): ProfileViewController: allPosts didSet")
        }
    }
    
    //TODO: перенести из геттера в дидСэт у allPosts:
    var postsOfUser: [Post]? {
        get {
            var tempArrayOfPosts = [Post]()
            allPosts?.forEach {
                if $0.author == user?.id {
                    tempArrayOfPosts.append($0)
                }
            }
            return tempArrayOfPosts
        }
    }
    private let scrollView = UIScrollView()
    let topInset: CGFloat = 8
    let collectionViewInset: CGFloat = 8
    
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
    private lazy var toFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Если постов нет, то это текущий юзер и отображать кнопку не нужно... не прокатило... С фида при переходе кнопка-то появляется (((
        if allPosts == nil {
            button.isHidden = true
        }
        guard let user = user else {
            return button
        }
        if user.currentUserFollowsThisUser {
            button.setTitle("Unfollow", for: .normal)
        } else {
            button.setTitle("Follow", for: .normal)
        }
        button.addTarget(self, action: #selector(toFollowButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Затемняющая вьюха, работающая вместе с индикатором активности
    private lazy var activityIndicatorShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.isHidden = true
        return view
        }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .white)
        indicator.isHidden = true
        return indicator
    }()
    
    // Делаем инициализатор, который может принимать юзера:
    init(user: User, allPosts: [Post]? = nil) {
        self.user = user
        self.allPosts = allPosts
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("user: \(user?.username): viewDidLoad")
        view.backgroundColor = .white
        updateUI()
        addSubviews()
        setUpLayout()
        allPostsHandler()
    }
    
    private func updateUI() {
        print("user: \(user?.username): updateUI")
        guard let user = user else { return }
        navigationItem.title = user.username
        avatarImageView.image = user.avatar
        userFullNameLabel.text = user.fullName
        followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
        followingButton.setAttributedTitle(NSAttributedString(string: "Following: \(user.followsCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
    }
    
    private func allPostsHandler() {
        // Если юзер передавался из FeedViewController, то он передавался со всеми постами. Тогда просто вырубаем экран загрузки. Если юзер передавался из AppDelegate (речь о currentUser), то он не содержит постов, поэтому на экране должен появиться индикатор активности при открытом ProfileViewControllere. После загрузки всех постов, коллекция перезагружается и выключается индикатор активности.
        if allPosts != nil {
            print("user: \(self.user?.username): -------------allPosts =! nil")
            setUpScrollView()
            turnActivityOff()
        } else {
            print("user: \(self.user?.username): -------------allPosts == nil")
            turnActivityOn()
            
            // Загружаем посты:
            DataProviders.shared.postsDataProvider.feed(queue: queue) { posts in
                self.allPosts = posts
                
                // Перезагружаем коллекцию и выключаем индикатор активности:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.setUpScrollView()
                    self.turnActivityOff()
                }
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        [avatarImageView,
         userFullNameLabel,
         followersButton,
         followingButton,
         collectionView,
         toFollowButton,
         activityIndicatorShadowView,
         activityIndicator
            ].forEach { scrollView.addSubview($0) }
    }
    
    private func setUpLayout() {
        
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
        
        NSLayoutConstraint.activate([
            toFollowButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            toFollowButton.trailingAnchor.constraint(equalTo: followingButton.trailingAnchor)
        ])
        
        collectionView.frame = CGRect(
            x: 0,
            y: avatarImageView.frame.maxY + collectionViewInset,
            width: view.bounds.width,
            height: view.bounds.height - topInset - avatarImageView.frame.height - collectionViewInset
        )

        let navBarMaxY = navigationController?.navigationBar.frame.maxY ?? 0
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        activityIndicatorShadowView.frame = CGRect(
            x: 0,
            y: avatarImageView.frame.maxY + collectionViewInset,
            width: view.bounds.width,
            height: view.bounds.height - navBarMaxY - topInset - avatarImageView.frame.maxY - collectionViewInset - tabBarHeight
        )
        
        activityIndicator.center = activityIndicatorShadowView.center
    }
    
    private func setUpScrollView() {
        let navBarMaxY = navigationController?.navigationBar.frame.maxY ?? 0
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        let height = view.bounds.height - navBarMaxY - tabBarHeight + 1 // Добавление единицы включает "резиночку" там, где ее нет, когда размер скрол вью не выходит за пределы видимости
        let contentHeight = topInset + avatarImageView.frame.height + collectionViewInset + collectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight < height {
            scrollView.contentSize = CGSize(width: view.bounds.width, height: height)
        } else {
            scrollView.contentSize = CGSize(width: view.bounds.width, height: contentHeight)
        }
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
    
    @objc func toFollowButtonTapped() {
        guard let user = user else {
            print("user: \(self.user?.username): toFollowButtonTapped: user not found")
            return
        }
        if isFollowed ?? user.currentUserFollowsThisUser {
            toFollowButton.setTitle("Follow", for: .normal)
            DataProviders.shared.usersDataProvider.unfollow(user.id, queue: serialQueue) { user in
                if user != nil {
                    print("user: \(self.user?.username): Unfollowed in DataProvider")
                } else {
                    print("user: \(self.user?.username): nil in DataProvider")
                }
            }
            isFollowed = false
        } else {
            toFollowButton.setTitle("Unfollow", for: .normal)
            DataProviders.shared.usersDataProvider.follow(user.id, queue: serialQueue) { user in
                if user != nil {
                    print("user: \(self.user?.username): Followed in DataProvider")
                } else {
                    print("user: \(self.user?.username): nil in DataProvider")
                }
            }
            isFollowed = true
        }
    }
    
}

//Добавляем очереди
extension ProfileViewController {
        
    var queue: DispatchQueue { DispatchQueue.global() }
    var serialQueue: DispatchQueue { DispatchQueue(label: "serialQueue") }
    
}


// ДОбавляем включениеи выключение индикатора активности:
extension ProfileViewController {
    
    func turnActivityOn() {
        print("user: \(user?.username): turnActivityOn")
        // Установка активити индикатора и его фона:
        activityIndicatorShadowView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func turnActivityOff() {
        print("user: \(user?.username): turnActivityOff")
        // Установка активити индикатора и его фона:
        activityIndicator.stopAnimating()
        activityIndicatorShadowView.isHidden = true
        activityIndicator.isHidden = true
    }
    
}
