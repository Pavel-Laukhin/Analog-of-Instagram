//
//  NewPostViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 21.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

final class NewPostViewController: UICollectionViewController {

    let photos = DataProviders.shared.photoProvider.photos()
    let thumbnailPhotos = DataProviders.shared.photoProvider.thumbnailPhotos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ReusableCell")
        navigationItem.title = "New post"
        collectionView.backgroundColor = .white
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReusableCell", for: indexPath)
        let imageView = UIImageView()
        imageView.image = photos[indexPath.item]
        imageView.contentMode = .scaleAspectFit
        let width = view.bounds.width / 3
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filterViewController = FilterViewController(image: photos[indexPath.item], thumbnailImage: thumbnailPhotos[indexPath.item])
        navigationController?.pushViewController(filterViewController, animated: true)
    }
   
}

extension NewPostViewController {
    
    func updateFeed() {
        self.navigationController?.popToRootViewController(animated: false)
        self.navigationController?.tabBarController?.selectedIndex = 0
        if let feedNavController = self.navigationController?.tabBarController?.viewControllers?[0] as? UINavigationController {
            if let feed = feedNavController.viewControllers[0] as? FeedViewController {
                feed.updateFeed()
            }
        }
    }
    
}
