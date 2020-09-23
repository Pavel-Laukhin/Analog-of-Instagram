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
        return CGSize(width: 120, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Снимаем рамки выделения у всех видимых ячеек:
        collectionView.visibleCells.forEach {
            $0.layer.borderWidth = 0
        }
        
        // Устанавливаем рамку у текущей ячейки:
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.gray.cgColor
    }
    
}
