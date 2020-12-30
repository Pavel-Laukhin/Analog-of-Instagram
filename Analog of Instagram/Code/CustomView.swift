//
//  CustomView.swift
//  Analog of Instagram
//
//  Created by Павел on 30.12.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit
import iOSIntPackage
import SnapKit

final class CustomView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "checkmark")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

