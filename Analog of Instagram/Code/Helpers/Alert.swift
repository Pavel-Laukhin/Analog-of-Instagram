//
//  Alert.swift
//  Course2FinalTask
//
//  Created by Павел on 27.08.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import Foundation
import UIKit

/// При получении ошибки с сервера нужно отобразить алерт с ее названием.
///
/// 404 -> “Not found” 400 -> “Bad request” 401 -> “Unauthorized” 406 -> “Not acceptable” 422 -> “Unprocessable”
///
/// Для прочих ошибок, полученных с сервера и при получении неверных данных от сервера нужно отобразить алерт “Transfer error”.
final class Alert {
    
    /** Создает и отображает алёрт.
     
    - parameter withTitle: Заголовок, который будет отображать алерт. По умолчанию будет отображаться заголовок "Unknown error!".
    - parameter withMessage: Сообщение, который будет отображать алерт. По умолчанию будет отображаться пустая строка
     */
    class func show(withTitle title: String? = nil, withMessage message: String? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = UIAlertController(title: title ?? "Unknown error!", message: message ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alert, animated: true)
            }
        }
    }
    
    class func show(withStatusCode code: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch code {
            case 404:
                Alert.show(withTitle: "Not found")
                return
            case 400:
                Alert.show(withTitle: "Bad request", withMessage: "Please, try again later.")
                return
            case 401:
                Alert.show(withTitle: "Unauthorized")
                return
            case 406:
                Alert.show(withTitle: "Not acceptable")
                return
            case 422:
                Alert.show(withTitle: "Unprocessable", withMessage: "Please, try again later.")
                return
            case 400...:
                Alert.show(withTitle: "Transfer error", withMessage: "Please, try again later.")
                return
            default:
                show()
            }
        }
    }
    
}
