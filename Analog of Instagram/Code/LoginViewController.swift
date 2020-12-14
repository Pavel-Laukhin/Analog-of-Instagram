//
//  LoginViewController.swift
//  Analog of Instagram
//
//  Created by Павел on 10.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    private enum TextFieldTag: Int {
        case login = 0
        case password
        
        init(tag: Int) {
            switch tag {
            case 0: self = .login
            case 1: self = .password
            default:
                fatalError("Unknown tag: \(tag)")
            }
        }
    }
    
    private lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "login"
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.tag = TextFieldTag.login.rawValue
        textField.addTarget(self, action: #selector(checkTextFieldsIsNotEmpty), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.placeholder = "password"
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .send
        textField.autocapitalizationType = .none
        textField.clearsOnBeginEditing = true
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.tag = TextFieldTag.password.rawValue
        textField.addTarget(self, action: #selector(checkTextFieldsIsNotEmpty), for: .editingChanged)
        return textField
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton(type: .system)
        let title = "Log in"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        button.backgroundColor = .systemGreen
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.layer.cornerRadius = 5
        button.alpha = 0.3
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        addSubviews()
        setupSubviews()
    }
    
    private func addSubviews() {
        [loginTextField,
         passwordTextField,
         logInButton].forEach {
            view.addSubview($0)
            $0.toAutoLayout()
         }
    }
    
    private func setupSubviews() {
        
        let width = (view.frame.width * 0.7) > K.Size.textFieldWidth ? K.Size.textFieldWidth : (view.frame.width * 0.7)
        
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            loginTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTextField.widthAnchor.constraint(equalToConstant: width),
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 32),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: width),
            
            logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func logInButtonPressed() {
        print("log in button pressed")
        ActivityIndicatorViewController.startAnimating(in: self)
        
        guard let login = loginTextField.text,
              let password = passwordTextField.text else { return }
        DataProviders.shared.signIn(login: login, password: password) { error in
            ActivityIndicatorViewController.stopAnimating()
            guard error == nil else {
                //TODO: здесь должен выскакивать алёрт
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                let tabBarController = TabBarController()
                UIApplication.shared.windows.first { $0.isKeyWindow == true }?.rootViewController = tabBarController
            }
        }
    }
    
    private func add(content: UIViewController) {
        addChild(content)
        view.addSubview(content.view)
        content.view.toAutoLayout()
        
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: view.topAnchor),
            content.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            content.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            content.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        ActivityIndicatorViewController.stopAnimating()
        content.didMove(toParent: self)
    }
    
    /// Проверяем, все ли текстовые поля заполнены. Если да, то активируем кнопку.
    @objc private func checkTextFieldsIsNotEmpty(_ textField: UITextField) {
        guard let login = loginTextField.text, !login.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            logInButton.alpha = 0.3
            logInButton.isEnabled = false
            return
        }
        logInButton.alpha = 1
        logInButton.isEnabled = true
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch TextFieldTag(tag: textField.tag) {
        case .login:
            passwordTextField.becomeFirstResponder()
        case .password:
            view.endEditing(true)
            logInButtonPressed()
        }
        
        return true
    }
    
}
