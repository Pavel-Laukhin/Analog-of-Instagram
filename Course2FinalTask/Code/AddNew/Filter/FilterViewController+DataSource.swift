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
        return filters.filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FilterViewCell.self), for: indexPath) as? FilterViewCell else { return UICollectionViewCell() }
        let filter = filters.filterArray[indexPath.item]
        cell.delegate = self
        cell.title = filter
        cell.image = self.thumbnailImage
        
        // Устанавливаем рамку, если ячейка выделена. Стираем рамку, если нет.
        if indexPath.item == selectedItemNumber {
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
        } else {
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
        }
        
        return cell
    }
    
}
