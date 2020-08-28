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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        addSubviews()
        setUpSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(collectionView)
    }
    
    // Настраиваем размер коллекшн вью:
    private func setUpSubviews() {
        collectionView.frame = CGRect(
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
        DataProviders.shared.postsDataProvider.usersLikedPost(with: postId, queue: self.queue) { arrayOfUsers in
            if arrayOfUsers == nil {
                
                // Показываем алерт о неизвестной ошибке:
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self)
                }
            } else if arrayOfUsers?.count == 0 {
                
                // Показываем алерт о том, что лист пустой:
                DispatchQueue.main.async {
                    Alert.showEmptyArray(vc: self)
                }
            } else {
                
                // Показываем таблицу с юзерами:
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(TableViewController(users: arrayOfUsers!, title: "Likes"), animated: true)
                }
            }
        }
    }
    
    func showProfile(userId: User.Identifier) {
        DataProviders.shared.usersDataProvider.user(with: userId, queue: self.queue) { user in
            if user == nil {
                
                // Показываем алерт о неизвестной ошибке:
                DispatchQueue.main.async {
                    Alert.showBasic(vc: self)
                }
            } else {
                
                // Показываем страницу юзера:
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
                }
            }
        }
    }
    
}

// Добавляем глобальную очередь:
extension FeedViewController {
    
    var queue: DispatchQueue { DispatchQueue.global() }
    
}

