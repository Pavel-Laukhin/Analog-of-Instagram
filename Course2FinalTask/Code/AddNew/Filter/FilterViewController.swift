//
//  FilterViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 21.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

final class FilterViewController: UIViewController {
    
    private let initialImage: UIImage
    let imageView = UIImageView()
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
    let filters = Filters()
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
        let indicator = UIActivityIndicatorView(style: .white)
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
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(
            x: 0,
            y: navigationController?.navigationBar.frame.maxY ?? 0,
            width: view.frame.width,
            height: view.frame.width
        )
        view.addSubview(imageView)
        view.addSubview(collectionView)
        [activityIndicatorShadowView, activityIndicator].forEach { view.addSubview($0) }

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
        
        view.backgroundColor = .white
        
        setThumbnailImages()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(goNext))
    }
    
    private func setThumbnailImages() {
        for filter in filters.filtersArray where filter.title != "Normal" {
            let operation = FilterImageOperation(inputImage: imageView.image, filter: filter.filter)
            operation.completionBlock = {
                guard let outputImage = operation.outputImage else { return }
                
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
        let filter = filters.filtersArray[selectedItemNumber].filter
        let operation = FilterImageOperation(inputImage: initialImage, filter: filter)
        operation.completionBlock = {
            DispatchQueue.main.async {
                guard let outputImage = operation.outputImage else { return }
                self.imageView.image = outputImage
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
    
}
