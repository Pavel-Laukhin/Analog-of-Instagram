//
//  Alert.swift
//  Course2FinalTask
//
//  Created by Павел on 27.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class Alert {
    
    /** Создает базовый алерт
    - parameters:
        - vc: Контроллер, который будет отображать алерт
     */
    class func showBasic(vc: UIViewController) {
        let alert = UIAlertController(title: "Unknown error!", message: "Please, try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    /** Создает алерт о том, что список пуст
    - parameters:
        - vc: Контроллер, который будет отображать алерт
     */
    class func showEmptyArray(vc: UIViewController) {
        let alert = UIAlertController(title: "List is empty!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
}
