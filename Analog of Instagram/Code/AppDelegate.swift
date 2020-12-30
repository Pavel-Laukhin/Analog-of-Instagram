//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let loginViewController = LoginViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
            print(#function)
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            print(#function)
        }
        
        func applicationWillResignActive(_ application: UIApplication) {
            print(#function)
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            print(#function)
            // При входе в фоновый режим отсчет времени показывает 30 секунд. При этом комплишен хендлер срабатывает за 5 секунд до конца.
        }
        
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            print(#function)
            return true
        }
        
        func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
            print(#function)
            return true
        }
    
}
