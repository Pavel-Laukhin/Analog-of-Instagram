//
//  ActivityIndicatorViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 02.10.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

class ActivityIndicatorViewController: UIViewController {
        
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.alpha = 0.7
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        activityIndicator.color = .white
        activityIndicator.startAnimating()
    }
    
    /// Презентует модально поверх всего экрана полупрозрачный вью контроллер с работающим активити индикатором:
    class func startAnimating(in viewController: UIViewController) {
        let activityVC = ActivityIndicatorViewController()
        activityVC.modalPresentationStyle = .overFullScreen
//        viewController.navigationController?.tabBarController?.present(activityVC, animated: false, completion: nil)
        viewController.present(activityVC, animated: false, completion: nil)
    }
    
    /// Выключает анимацию активити индикатора на корневом вью
    class func stopAnimating() {
        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
                rootVC.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}
