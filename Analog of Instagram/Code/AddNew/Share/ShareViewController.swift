//
//  ShareViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 25.09.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

final class ShareViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Add description"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    private lazy var textView: UITextView = {
        
        // Определяем шрифт, от которого будет зависеть размер вьюхи:
        let font = UIFont.systemFont(ofSize: 17.0)
        
        let textView = UITextView(frame: CGRect(x: 16, y: 0, width: self.view.frame.width - 2 * 16, height: font.capHeight))
        
        // Устанавливаем шрифт:
        textView.font = font
        
        // Устанавливаем рамку и скругляем углы:
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 7
        
        // Делаем возможность редактировать текст:
        textView.isEditable = true
        
        // Делаем вьюху растягивающейся вниз:
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.becomeFirstResponder()
        textView.delegate = self
        
        return textView
    }()
    
    /// Максимально допустимое количество символов в описании.
    private let maxCharactersLimit: Int = 160
    
    /// Максимально допустимое количество строк в описании.
    private let maxLinesLimit: Int = 7
        
    private let queue = DispatchQueue.global()
    
    init(image: UIImage?) {
        self.imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubviews()
        setLayout()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(sharePhoto))
    }
    
    private func addSubviews() {
        [imageView,
        label,
        textView].forEach { view.addSubview($0)}
    }
    
    private func setLayout() {
        imageView.frame = CGRect(
            x: 16,
            y: (navigationController?.navigationBar.frame.maxY ?? 0) + 16,
            width: 100,
            height: 100
        )
        label.sizeToFit()
        label.frame = CGRect(
            x: 16,
            y: imageView.frame.maxY + 32,
            width: label.frame.width,
            height: label.frame.height
        )
        
        // Закрепляем верх и боковые стороны, чтобы вьюха могла растягиваться вниз:
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // Метод, который убирает клавиатуру после того, как закончилось редактирование
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func sharePhoto() {
        guard let image = imageView.image,
              let rootVC = self.navigationController?.viewControllers[0] as? NewPostViewController else { return }
        rootVC.startAnimating()
        DataProviders.shared.postsDataProvider.newPost(with: image, description: textView.text, queue: queue) { post in
            guard post != nil else {
                    Alert.show(withMessage: "Please, try again later.")
                return
            }
            DispatchQueue.main.async {
                    rootVC.updateFeed()
            }
        }
    }
    
}

// Сделаем ограничение для количества символов в строке длиной в 500 символов
extension ShareViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Устанавливаем ограничение по количество вводимых символов
        if textView.text.count + (text.count - range.length) >= maxCharactersLimit {
            return false
        }
        
        // Устанавливаем ограничение по количеству строк таким образом, чтобы textView могла растянуться максимум до низа экрана. Если на экране есть таб бар, то до него, если нет, то тогда до самого низа
        guard let textViewFont = textView.font else { return false }
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let textAttributes = [NSAttributedString.Key.font : textViewFont]
        var textWidth: CGFloat = textView.frame.inset(by: textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding
        let boundingRect: CGRect = newText.boundingRect(with: CGSize(width: textWidth, height: 0), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: textAttributes, context: nil)
        let numberOfLines = Int(floor(boundingRect.height / textViewFont.lineHeight))
        
        return numberOfLines <= maxLinesLimit
    }
    
}
