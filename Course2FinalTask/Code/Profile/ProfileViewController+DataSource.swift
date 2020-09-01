//
//  ProfileViewController+DataSource.swift
//  Course2FinalTask
//
//  Created by Павел on 05.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let postsCount = self.postsCount else { return 1 }
        return postsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProfileFeedCell.self), for: indexPath) as? ProfileFeedCell else { return UICollectionViewCell() }
        if let user = user {
            DataProviders.shared.postsDataProvider.findPosts(by: user.id, queue: queue) { posts in
                if posts != nil {
                    DispatchQueue.main.async {
                        cell.post = posts![indexPath.item]
                    }
                } else {
                    DispatchQueue.main.async {
                        Alert.showBasic(vc: self)
                    }
                }
            }
            
        }
        cell.turnActivityOn()
        return cell
    }
    
    
}
