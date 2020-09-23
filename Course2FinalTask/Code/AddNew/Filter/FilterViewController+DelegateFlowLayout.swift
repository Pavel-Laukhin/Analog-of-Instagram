//
//  FilterViewController+DelegateFlowLayout.swift
//  Course2FinalTask
//
//  Created by Павел on 22.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension FilterViewController: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 87)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Устанавливаем рамку у текущей ячейки:
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
            selectedItemNumber = indexPath.item
            collectionView.reloadData()
        }
    }
    
}
