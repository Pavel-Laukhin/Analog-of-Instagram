//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = UITabBarController()
        let feedViewController = FeedViewController()
        let profileViewController = ProfileViewController()
        let feedNavigationController = UINavigationController()
        let profileNavigationController = UINavigationController()
        
        feedNavigationController.viewControllers = [feedViewController]
        profileNavigationController.viewControllers = [profileViewController]
        
        // Задаем названия контроллеров, которые будут отображаться на панели Таб Бара:
        feedViewController.title = "Feed"
        profileViewController.title = "Profile"
        
        // Добавляем на панель Таб Бара наши контроллеры:
        tabBarController.viewControllers = [feedNavigationController, profileNavigationController]
        
        // Задаем иконки кнопок у панели Таб Бара:
        tabBarController.tabBar.items?[0].image = UIImage(named: "feed")
        tabBarController.tabBar.items?[1].image = UIImage(named: "profile")

        // Альтернативный вариант задачи названий кнопок у панели Таб Бара и их изображений:
        //        feedViewController.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "feed"), tag: 0)
        //        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), tag: 0)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = tabBarController
        
        return true
    }
}
