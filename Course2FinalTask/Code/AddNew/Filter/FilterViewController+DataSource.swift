//
//  FilterViewController+DataSource.swift
//  Course2FinalTask
//
//  Created by Павел on 22.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension FilterViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Filters.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FilterViewCell.self), for: indexPath) as? FilterViewCell else { return UICollectionViewCell() }
        cell.image = self.thumbnailImage
        guard let filter = Filters(rawValue: indexPath.item) else { return cell }
        cell.title = String(describing: filter)
        return cell
    }
    
}
