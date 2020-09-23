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
    
    private let image: UIImage
    let thumbnailImage: UIImage
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
    
    init(image: UIImage, thumbnailImage: UIImage) {
        self.image = image
        self.thumbnailImage = thumbnailImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(
            x: 0,
            y: navigationController?.navigationBar.frame.maxY ?? 0,
            width: view.frame.width,
            height: view.frame.width
        )
        view.addSubview(imageView)
        view.addSubview(collectionView)
        collectionView.frame = CGRect(
            x: 0,
            y: imageView.frame.maxY + 16,
            width: view.frame.width,
            height: 87
        )
        view.backgroundColor = .white
    }
    
}

extension FilterViewController: AbleToReloadCollectionViewData {
    
    func reloadData() {
        collectionView.reloadData()
    }
    
}
