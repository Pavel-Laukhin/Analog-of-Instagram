//
//  FeedViewController+DataSourse.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

extension FeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 1
        
        //Возвращаем количество постов для рассчета количества ячеек
        DataProviders.shared.postsDataProvider.feed(queue: queue) { posts in
            if let postsCount = posts?.count {
                count = postsCount
            } 
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        
        // Кастомизируем ячейку. Добавляю цвет фона и передаю пост:
        cell.backgroundColor = .white
        
        DataProviders.shared.postsDataProvider.feed(queue: queue) { (postsArray: [Post]?) -> Void in
            if let post = postsArray?[indexPath.item] {
                cell.post = post
            }
        }
        
        cell.delegate = self
        cell.callback = { [weak self] authorId in
            DataProviders.shared.usersDataProvider.user(with: authorId, queue: self?.queue) { user in
                if let user = user {
                    DispatchQueue.main.async {
                        self?.navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self!)
                    }
                }
            }
        }
        
        return cell
    }
    
    
}
