//
//  TabBarController.swift
//  Course2FinalTask
//
//  Created by Павел on 19.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

final class TabBarController: UITabBarController {
    
    /// Индекс последнего элемента табБара
    private lazy var lastVCIndex: Int = {
        guard let viewControllers = viewControllers else { return 0 }
        if !viewControllers.isEmpty {
            let number = viewControllers.count - 1
            return number
        } else {
            return 0
        }
    }()
    
    var currentUser: User? {
        didSet {
            // Создаем контроллер с текущим юзером, настраиваем, передаем в навигейшн контроллер и обновляем навигейшн контроллер у табБар контроллера:
            guard let user = currentUser else { return }
            let profileViewController = ProfileViewController(user: user, currentUser: user)
            profileNavigationController.viewControllers = [profileViewController]
            viewControllers?[lastVCIndex] = profileNavigationController
        }
    }
    
    let feedViewController = FeedViewController()
    let feedNavigationController = UINavigationController()
    let newPostNavigationController = UINavigationController()
    let newPostViewController: UICollectionViewController = {
        let layout = UICollectionViewFlowLayout()
        let vc = NewPostViewController(collectionViewLayout: layout)
        return vc
    }()
    var profileNavigationController = UINavigationController()

    override func viewDidLoad() {
        super.viewDidLoad()

        feedNavigationController.viewControllers = [feedViewController]
        newPostNavigationController.viewControllers = [newPostViewController]
        
        // Задаем названия контроллеров, которые будут отображаться на панели Таб Бара:
        feedViewController.title = "Feed"
        profileNavigationController.title = "Profile"
        
        // Добавляем на панель Таб Бара наши контроллеры:
        viewControllers = [feedNavigationController, newPostNavigationController, profileNavigationController]
        
        // Задаем иконки кнопок у панели Таб Бара:
        tabBar.items?[0].image = UIImage(named: "feed")
        newPostNavigationController.tabBarItem = UITabBarItem(title: "New", image: UIImage(named: "plus"), tag: 0)
        tabBar.items?[2].image = UIImage(named: "profile")
        
        
        // Загружаем информацию о текущем юзере
        let queue = DispatchQueue.global(qos: .utility)
        DataProviders.shared.usersDataProvider.currentUser(queue: queue) { user in
            guard let user = user else {
                print("AppDelegate: ERROR: currentUser not found")
                return
            }
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }        
    }
    
}
