//
//  FilterViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 21.09.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

final class FilterViewController: UIViewController {
    
    private let initialImage: UIImage
    private var currentImage: UIImage? = nil
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let thumbnailImage: UIImage
    var filteredThumbnailImagesDictionary: [String: UIImage] = [:]
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FilterViewCell.self, forCellWithReuseIdentifier: String(describing: FilterViewCell.self))
        collectionView.backgroundColor = .white
        return collectionView
    }()
    var selectedItemNumber: Int = 0
    let queue = OperationQueue()
    
    /// Затемняющая вьюха, работающая вместе с индикатором активности
    private lazy var activityIndicatorShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        view.isHidden = true
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.center = view.center
        indicator.isHidden = true
        return indicator
    }()
    
    init(image: UIImage, thumbnailImage: UIImage) {
        imageView.image = image
        initialImage = image
        self.thumbnailImage = thumbnailImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        view.backgroundColor = .white
        
        addSubViews()
        setupLayout()
        addLongPressGestureRecognizer()
        setThumbnailImages()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNext))
    }
    
    private func addSubViews() {
        view.addSubview(imageView)
        view.addSubview(collectionView)
        [activityIndicatorShadowView, activityIndicator].forEach { view.addSubview($0) }
    }
    
    private func setupLayout() {
        imageView.frame = CGRect(
            x: 0,
            y: navigationController?.navigationBar.frame.maxY ?? 0,
            width: view.frame.width,
            height: view.frame.width
        )

        collectionView.frame = CGRect(
            x: 0,
            y: imageView.frame.maxY + 16,
            width: view.frame.width,
            height: 87
        )
        
        activityIndicatorShadowView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }
    
    private func setThumbnailImages() {
        for filter in Filters.filtersArray where filter.title != "Normal" {
            let operation = FilterImageOperation(inputImage: imageView.image, filter: filter.filter)
            operation.completionBlock = { [weak self] in
                guard let self = self,
                      let outputImage = operation.outputImage else { return }
                
                // Чтобы избежать race condition, будем обновлять словарь в последовательной очереди главного потока:
                DispatchQueue.main.async {
                    self.filteredThumbnailImagesDictionary[filter.title] = outputImage
                    self.collectionView.reloadData()
                }
            }
            queue.addOperation(operation)
        }
    }
    
    func setFilteredImage() {
        turnActivityOn()
        guard selectedItemNumber != 0 else {
            imageView.image = initialImage
            turnActivityOff()
            return
        }
        let filter = Filters.filtersArray[selectedItemNumber].filter
        let operation = FilterImageOperation(inputImage: initialImage, filter: filter)
        operation.completionBlock = {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let outputImage = operation.outputImage else { return }
                self.imageView.image = outputImage
                self.showHint()
                self.turnActivityOff()
            }
        }
        queue.addOperation(operation)
    }
    
    private func turnActivityOn() {
        // Установка активити индикатора и его фона:
        activityIndicatorShadowView.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func turnActivityOff() {
        // Установка активити индикатора и его фона:
        activityIndicator.stopAnimating()
        activityIndicatorShadowView.isHidden = true
        activityIndicator.isHidden = true
    }
    
    @objc func goNext() {
        let shareViewController = ShareViewController(image: imageView.image)
        navigationController?.pushViewController(shareViewController, animated: true)
    }
    
    private func addLongPressGestureRecognizer() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressGestureHandler(recognizer:)))
        pressGesture.minimumPressDuration = 0
        imageView.addGestureRecognizer(pressGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    /// Показывает оригинальное изображение, пока держишь палец.
    @objc private func pressGestureHandler(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            currentImage = imageView.image
            imageView.image = initialImage
        case .ended:
            imageView.image = currentImage
        default:
            ()
        }
    }
    
    /// Показывает сообщение, что можно увидеть оригинал, если дотронуться до картинки. Затем сообщение исчезает.
    func showHint() {
        let button = UIButton(type: .system)
        button.setTitle("Tap and hold for original", for: .normal)
        button.tintColor = .darkGray
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)
        button.sizeToFit()
        button.center.x = imageView.center.x
        button.center.y = imageView.frame.maxY - 20
        view.addSubview(button)
        UIView.animate(withDuration: 0.5, delay: 0.7, options: [.curveEaseInOut], animations: {
            button.alpha = 0
        }) { _ in
            button.removeFromSuperview()
        }
    }
    
}
