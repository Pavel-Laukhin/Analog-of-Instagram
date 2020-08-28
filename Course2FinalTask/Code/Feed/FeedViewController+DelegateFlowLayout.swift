//
//  FeedViewController+DelegateFlowLayout.swift
//  Course2FinalTask
//
//  Created by Павел on 04.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = view.bounds.width
        let imageHeight = width
        let height = LayoutConstants.topOffset + LayoutConstants.avatarHeight + LayoutConstants.topPostImageOffset + imageHeight + LayoutConstants.isLikeIconHeight + LayoutConstants.descriptionHeight

        return CGSize(width: width, height: height)
    }
    
}

