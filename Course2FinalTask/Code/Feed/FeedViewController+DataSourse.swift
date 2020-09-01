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
        while postsCount == nil {
            ()
        }
        return postsCount!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        
        // Кастомизируем ячейку. Добавляю цвет фона и передаю пост:
        cell.backgroundColor = .white
        
        cell.indexOfCell = indexPath.item
        
        cell.delegate = self
        cell.callback = { [weak self] authorId in
            self?.turnActivityOn()
            DataProviders.shared.usersDataProvider.user(with: authorId, queue: self?.queue) { user in
                if let user = user {
                    DispatchQueue.main.async {
                        self?.turnActivityOff()
                        self?.navigationController?.pushViewController(ProfileViewController(user: user, isFollowed: user.currentUserFollowsThisUser), animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.turnActivityOff()
                        Alert.showBasic(vc: self!)
                    }
                }
            }
        }
        
        return cell
    }
    
    
}
