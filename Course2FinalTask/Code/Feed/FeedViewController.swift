//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class FeedViewController: UIViewController {
        
    private lazy var collectionView: UICollectionView = {
        // 1. Делаем дефолтный макет, иначе наша коллекшн вью не сможет понять, как ей отрисовывать наши ячейки на экране:
        let layout = UICollectionViewFlowLayout()
        // 2. Делаем экземпляр класса коллекшн вью. Можно передать во фрейм "зиро", то есть нулевой прямоугольник. Ничего страшного, потому что потом этот фрейм растянется, как нам надо:
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        // 3. Регистрируем ячейку:
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: String(describing: FeedCell.self))
        // 4. Указываем наш контроллер источником информации и делегатом:
        collectionView.dataSource = self
        collectionView.delegate = self
        // 5.Возвращаем результат:
        return collectionView
    }()
    
    var allPosts: [Post]? {
        didSet {
            print("All posts has been set")
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.turnActivityOff()
            }
        }
    }
    
    var currentUser: User!
    
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
        indicator.center = view.center
        indicator.isHidden = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FeddView has been load")
        collectionView.backgroundColor = .white
        addSubviews()
        setUpSubviews()
        turnActivityOn()
        
        // Загружаем посты:
        DataProviders.shared.postsDataProvider.feed(queue: queue) { posts in
            self.allPosts = posts
        }
        
        // Находим текущего юзера:
        DataProviders.shared.usersDataProvider.currentUser(queue: queue) { user in
            guard let user = user else { return }
            self.currentUser = user
        }
    }
    
    private func addSubviews() {
        [collectionView, activityIndicatorShadowView, activityIndicator].forEach { view.addSubview($0) }
    }
    
    // Настраиваем размер коллекшн вью:
    private func setUpSubviews() {
        collectionView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
        activityIndicatorShadowView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }
    
}

// Прописываем протокол, который позволит нам показывать страницу профиля и лист юзеров по переданному id профиля или поста:
protocol TransitionProtocol: AnyObject {
    
    func showProfile(userId: User.Identifier)
    func showListOfUsersLikedThisPost(postId: Post.Identifier)
    
}

// Реализуем соответствие протоколу:
extension FeedViewController: TransitionProtocol {
    
    func showListOfUsersLikedThisPost(postId: Post.Identifier) {
        turnActivityOn()
        
        // Ищем список пользователей, лайкнувших пост:
        DataProviders.shared.postsDataProvider.usersLikedPost(with: postId, queue: self.queue) { arrayOfUsers in
            if arrayOfUsers == nil {
                
                // Показываем алерт о неизвестной ошибке:
                DispatchQueue.main.async {
                    self.turnActivityOff()
                    Alert.showBasic(vc: self)
                }
            } else if arrayOfUsers?.count == 0 {
                
                // Показываем алерт о том, что лист пустой:
                DispatchQueue.main.async {
                    self.turnActivityOff()
                    Alert.showEmptyArray(vc: self)
                }
            } else {
                
                // Показываем таблицу с юзерами:
                DispatchQueue.main.async {
                    self.turnActivityOff()
                    self.navigationController?.pushViewController(TableViewController(users: arrayOfUsers!, title: "Likes"), animated: true)
                }
            }
        }
    }
    
    func showProfile(userId: User.Identifier) {
        
        if currentUser != nil && userId == currentUser.id {
            
            navigationController?.tabBarController?.selectedIndex = 1
            
        } else {
            turnActivityOn()
            
            // Ищем пользователя:
            DataProviders.shared.usersDataProvider.user(with: userId, queue: self.queue) { user in
                guard let user = user else {
                    
                    // Показываем алерт о неизвестной ошибке:
                    DispatchQueue.main.async {
                        self.turnActivityOff()
                        Alert.showBasic(vc: self)
                    }
                    return
                }
                
                // Показываем страницу юзера:
                DispatchQueue.main.async {
                    self.turnActivityOff()
                    self.navigationController?.pushViewController(ProfileViewController(user: user, allPosts: self.allPosts), animated: true)
                }
            }
        }
    }

}

// Добавляем глобальную очередь:
extension FeedViewController {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}

// ДОбавляем включениеи выключение индикатора активности:
extension FeedViewController {
    
    func turnActivityOn() {
        print("turnActivityOn")
        // Установка активити индикатора и его фона:
        activityIndicatorShadowView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func turnActivityOff() {
        print("turnActivityOff")
        // Установка активити индикатора и его фона:
        activityIndicator.stopAnimating()
        activityIndicatorShadowView.isHidden = true
        activityIndicator.isHidden = true
    }
    
}
