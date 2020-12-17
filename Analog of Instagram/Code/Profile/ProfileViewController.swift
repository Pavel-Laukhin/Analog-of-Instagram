//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    var user: User
    var currentUser: User?
    var allPosts: [Post]?
    var postsOfUser: [Post]? {
        get {
            var tempArrayOfPosts = [Post]()
            guard let allPosts = allPosts else { return [] }
            allPosts.forEach {
                if $0.author == user.id {
                    tempArrayOfPosts.append($0)
                }
            }
            return tempArrayOfPosts
        }
    }
    
    /// Подписан ли текущий пользователь на этого пользователя
    private var isFollowed: Bool?
    
    /// Запущен ли процесс подписки/отписки в данный момент
    private var isInTheProcessOfChangingSubscription = false
    
    private let scrollView = UIScrollView()
    private let topInset: CGFloat = 8
    private let collectionViewInset: CGFloat = 8
    
    /// Свойство, говорящее о том, что в feed были внесены изменения и поэтому необходимо обновить allPosts
    var isInNeedOfUpdating = false
    
    /// Свойство, говорящее о том, что в подписки были внесены изменения и поэтому необходимо обновить
    var isInNeedOfUpdatingNumberOfFollows = false
    
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
        
        // 5. Отключаем встроенный скролл вью у коллекции:
        collectionView.isScrollEnabled = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // 6.Возвращаем результат:
        return collectionView
    }()
    private lazy var toFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Если постов нет, то это текущий юзер и отображать кнопку не нужно.
        guard allPosts != nil else {
            button.isHidden = true
            return button
        }
        guard currentUser?.id != user.id else {
            button.isHidden = true
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
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.isHidden = true
        return indicator
    }()
    
    // Делаем инициализатор, который может принимать юзера:
    init(user: User, allPosts: [Post]? = nil, currentUser: User? = nil) {
        self.user = user
        self.allPosts = allPosts
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Текущий отступ у скролл вью. Нужен для корректной перемотки скролл вью в самое начало при обновлении контента.
    private var offset: CGPoint {
        get {
            return CGPoint(x: -scrollView.adjustedContentInset.left,
                           y: -scrollView.adjustedContentInset.top
            )
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        updateUI()
        addSubviews()
        setUpLayout()
        allPostsHandler()
        logOutButtonSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInNeedOfUpdating {
            turnActivityOn()
            
            // Перематываем скролл вью наверх:
            scrollView.setContentOffset(offset, animated: false)
            
            // Обновляем посты:
            updateAllPosts()
        }
        
        if isInNeedOfUpdatingNumberOfFollows {
            updateNumberOfFollows()
        }
    }
    
    private func updateNumberOfFollows() {
        DataProviders.shared.usersDataProvider.currentUser(queue: queue) { [weak self] user in
            guard let self = self,
                  let user = user  else { return }
            
            self.currentUser = user
            self.isInNeedOfUpdatingNumberOfFollows = false
            
            // Меняем число подписок:
            DispatchQueue.main.async {
                self.followingButton.setAttributedTitle(NSAttributedString(string: "Following: \(user.followsCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
                self.followersButton.sizeToFit()
            }
        }
    }
    
    private func updateUI() {
        navigationItem.title = user.username
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        userFullNameLabel.text = user.fullName
        followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
        followingButton.setAttributedTitle(NSAttributedString(string: "Following: \(user.followsCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
    }
    
    private func allPostsHandler() {
        // Если юзер передавался из FeedViewController, то он передавался со всеми постами. Тогда просто вырубаем экран загрузки. Если юзер передавался из AppDelegate (речь о currentUser), то он не содержит постов, поэтому на экране должен появиться индикатор активности при открытом ProfileViewControllere. После загрузки всех постов, коллекция перезагружается и выключается индикатор активности.
        if allPosts != nil {
            setUpScrollView()
            turnActivityOff()
        } else {
            turnActivityOn()
            
            // Загружаем посты:
            updateAllPosts()
        }
    }
    
    private func updateAllPosts() {
        DataProviders.shared.postsDataProvider.feed(queue: queue) { [weak self] posts in
            guard let self = self else { return }
            if let posts = posts {
                self.allPosts = posts
                self.isInNeedOfUpdating = false
            }
            
            // Перезагружаем коллекцию и выключаем индикатор активности:
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setUpScrollView()
                self.turnActivityOff()
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
         activityIndicator].forEach { scrollView.addSubview($0) }
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: collectionViewInset),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
    
    private func logOutButtonSetup() {
        // Если постов нет, то это текущий юзер и отображать кнопку не нужно.
        guard allPosts == nil else { return }
        guard currentUser?.id == user.id else { return }
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        navigationItem.rightBarButtonItem = logOutButton
    }
    
    // MARK: - Actions
    
    /// Находит индекс вкладки у таб бара, которая сейчас отображается. Определяет корневую вью у данной вкладки. Запускает на весь экран у корневой вью метод startAnimating типа ActivityIndicatorViewController. Затем запускает метод, отображающий списко юзеров.
    @objc func followingButtonTapped() {
        guard let index = navigationController?.tabBarController?.selectedIndex,
              let rootNavController = navigationController?.tabBarController?.viewControllers?[index] as? UINavigationController  else { return }
        let rootVC = rootNavController.viewControllers[0]
        ActivityIndicatorViewController.startAnimating(in: rootVC)
        showUsersFollowedByUser(andDismissIn: rootVC)
    }
    
    private func showUsersFollowedByUser(andDismissIn rootVC: UIViewController) {
        DataProviders.shared.usersDataProvider.usersFollowedByUser(with: user.id, queue: queue) { users in
            if let users = users {
                DispatchQueue.main.async {
                    rootVC.dismiss(animated: false, completion: nil)
                    self.navigationController?.pushViewController(TableViewController(users: users, title: "Following", allPosts: self.allPosts, currentUser: self.currentUser), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    rootVC.dismiss(animated: false, completion: nil)
                    Alert.show(withMessage: "Please, try again later.")
                }
            }
        }
    }
    
    /// Находит индекс вкладки у таб бара, которая сейчас отображается. Определяет корневую вью у данной вкладки. Запускает на весь экран у корневой вью метод startAnimating типа ActivityIndicatorViewController. Затем запускает метод, отображающий списко юзеров.
    @objc func followersButtonTapped() {
        guard let index = navigationController?.tabBarController?.selectedIndex,
              let rootNavController = navigationController?.tabBarController?.viewControllers?[index] as? UINavigationController  else { return }
        let rootVC = rootNavController.viewControllers[0]
        ActivityIndicatorViewController.startAnimating(in: rootVC)
        showUsersFollowingUser(andDismissIn: rootVC)
    }
    
    private func showUsersFollowingUser(andDismissIn rootVC: UIViewController) {
        DataProviders.shared.usersDataProvider.usersFollowingUser(with: user.id, queue: queue) { users in
            if let users = users {
                DispatchQueue.main.async {
                    rootVC.dismiss(animated: false, completion: nil)
                    self.navigationController?.pushViewController(TableViewController(users: users, title: "Followers", allPosts: self.allPosts, currentUser: self.currentUser), animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    rootVC.dismiss(animated: false, completion: nil)
                    Alert.show(withMessage: "Please, try again later.")
                }
            }
        }
    }
    
    /// Метод, который меняет текущий статус подписки и название кнопки, а также запускает процесс подписки/отписки в DataProvider (если только процесс подписки/отписки не выполняется в данный момент)
    @objc func toFollowButtonTapped() {
        if isFollowed ?? user.currentUserFollowsThisUser {
            isFollowed = false
            toFollowButton.setTitle("Follow", for: .normal)
            if !isInTheProcessOfChangingSubscription {
                isInTheProcessOfChangingSubscription = true
                toUnfollow()
            }
        } else {
            isFollowed = true
            toFollowButton.setTitle("Unfollow", for: .normal)
            if !isInTheProcessOfChangingSubscription {
                isInTheProcessOfChangingSubscription = true
                toFollow()
            }
        }
    }
    
    private func toFollow() {
        DataProviders.shared.usersDataProvider.follow(user.id, queue: queue) { user in
            guard let user = user else {
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): nil in DataProvider")
                return
            }
            
            // Прежде чем менять число подписчиков, метод должен проверить, не передумал ли юзер, пока процесс выполнялся (не нажал ли юзер снова кнопку Follow/Unfollow). Если передумал, то тогда нужно запустить обратный процесс:
            if self.isFollowed ?? true {
                DispatchQueue.main.async {
                    self.followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
                    self.followersButton.sizeToFit()
                }
                
                // Сообщаем, что процесс подписки/отписки закончен и меняем соответствующий статус у переменной:
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): Followed in DataProvider")
                self.isInTheProcessOfChangingSubscription = false
                
                // Включаем необходимость обновить количество подписок в контроллере ProfileViewController:
                self.queue.async {
                    DispatchQueue.main.async {
                        if let profileNavController = self.navigationController?.tabBarController?.viewControllers?[2] as? UINavigationController,
                           let profileVC = profileNavController.viewControllers[0] as? ProfileViewController {
                            profileVC.isInNeedOfUpdatingNumberOfFollows = true
                        }
                    }
                }
                
            } else {
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): Followed in DataProvider BUT NEED TO CHANGE")
                self.toUnfollow()
            }
        }
    }
    
    private func toUnfollow() {
        DataProviders.shared.usersDataProvider.unfollow(user.id, queue: queue) { user in
            guard let user = user else {
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): nil in DataProvider")
                return
            }
            
            // Прежде чем менять число подписчиков, метод должен проверить, не передумал ли юзер, пока процесс выполнялся (не нажал ли юзер снова кнопку Follow/Unfollow). Если передумал, то тогда нужно запустить обратный процесс:
            if !(self.isFollowed ?? false) {
                DispatchQueue.main.async {
                    self.followersButton.setAttributedTitle(NSAttributedString(string: "Followers: \(user.followedByCount)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .semibold)]), for: .normal)
                    self.followersButton.sizeToFit()
                }
                
                // Сообщаем, что процесс подписки/отписки закончен и меняем соответствующий статус у переменной:
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): Unfollowed in DataProvider")
                self.isInTheProcessOfChangingSubscription = false
                
                // Включаем необходимость обновить количество подписок в контроллере ProfileViewController:
                self.queue.async {
                    DispatchQueue.main.async {
                        if let profileNavController = self.navigationController?.tabBarController?.viewControllers?[2] as? UINavigationController,
                           let profileVC = profileNavController.viewControllers[0] as? ProfileViewController {
                            profileVC.isInNeedOfUpdatingNumberOfFollows = true
                        }
                    }
                }
                
            } else {
                print(type(of: self), #function, "user: \(String(describing: self.user.username)): Unfollowed in DataProvider BUT NEED TO CHANGE")
                self.toFollow()
            }
        }
    }
    
    @objc private func logOut() {
        ActivityIndicatorViewController.startAnimating(in: self)
        DataProviders.shared.signOut(queue: queue) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let lognViewController = LoginViewController()
                UIApplication.shared.windows.first { $0.isKeyWindow == true }?.rootViewController = lognViewController
            }
        }
    }
    
}

//Добавляем очереди
extension ProfileViewController {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}


// ДОбавляем включениеи выключение индикатора активности:
extension ProfileViewController {
    
    private func turnActivityOn() {
        // Установка активити индикатора и его фона:
        activityIndicatorShadowView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func turnActivityOff() {
        // Установка активити индикатора и его фона:
        activityIndicator.stopAnimating()
        activityIndicatorShadowView.isHidden = true
        activityIndicator.isHidden = true
    }
    
}
