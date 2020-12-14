//
//  FeedViewController+DataSourse.swift
//  Course2FinalTask
//
//  Created by Павел on 02.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

extension FeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FeedCell.self), for: indexPath) as? FeedCell else { return UICollectionViewCell() }
        
        // Кастомизируем ячейку. Добавляю цвет фона и передаю пост:
        cell.backgroundColor = .white
        
        cell.post = allPosts?[indexPath.item]
        cell.maxWidth = view.frame.width
        cell.delegate = self
        cell.callback = { [weak self] authorId in
            guard let self = self else { return }
            self.turnActivityOn()
            DataProviders.shared.usersDataProvider.user(with: authorId, queue: self.queue) { user in
                if let user = user {
                    DispatchQueue.main.async {
                        self.turnActivityOff()
                        if let allPosts = self.allPosts {
                            self.navigationController?.pushViewController(ProfileViewController(user: user, allPosts: allPosts), animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.turnActivityOff()
                        Alert.showBasic(vc: self)
                    }
                }
            }
        }
        
        return cell
    }
    
}
