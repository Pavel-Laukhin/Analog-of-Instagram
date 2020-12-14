//
//  ProfileViewController+DataSource.swift
//  Course2FinalTask
//
//  Created by Павел on 05.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let postsOfUser = self.postsOfUser else { return 1 }
        return postsOfUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProfileFeedCell.self), for: indexPath) as? ProfileFeedCell else { return UICollectionViewCell() }
        guard let postsOfUser = postsOfUser else { return UICollectionViewCell() }
        cell.post = postsOfUser[indexPath.item]
        return cell
    }
    
    
}
