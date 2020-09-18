//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = UITabBarController()
        let feedViewController = FeedViewController()
        let feedNavigationController = UINavigationController()
        let profileNavigationController = UINavigationController()
        
        feedNavigationController.viewControllers = [feedViewController]
        
        
        // Задаем названия контроллеров, которые будут отображаться на панели Таб Бара:
        feedViewController.title = "Feed"
        profileNavigationController.title = "Profile"
//        profileViewController.title = "Profile"
        
        // Добавляем на панель Таб Бара наши контроллеры:
        tabBarController.viewControllers = [feedNavigationController, profileNavigationController]
        
        // Задаем иконки кнопок у панели Таб Бара:
        tabBarController.tabBar.items?[0].image = UIImage(named: "feed")
        tabBarController.tabBar.items?[1].image = UIImage(named: "profile")

        // Альтернативный вариант задачи названий кнопок у панели Таб Бара и их изображений:
        //        feedViewController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "feed"), tag: 0)
        //        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), tag: 0)
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        print("makeKeyAndVisible")
        
        // Загружаем информацию о текущем юзере
        let queue = DispatchQueue.global(qos: .utility)
        var currentUser: User?
        DataProviders.shared.usersDataProvider.currentUser(queue: queue) { user in
            guard let user = user else { return }
            currentUser = user
        }
        
        // Ждем, пока текущий юзер загружается из DataProviders
        while currentUser == nil {
            ()
        }
        
        // Создаем контроллер с текущим юзером, настраиваем, передаем в навигейшн контроллер и обновляем навигейшн контроллер у табБар контроллера:
        guard let user = currentUser else { return true }
        let profileViewController = ProfileViewController(user: user, allPosts: feedViewController.allPosts)
        profileNavigationController.viewControllers = [profileViewController]
        tabBarController.viewControllers?[1] = profileNavigationController
        
        return true
    }
}
