//
//  UICollectionView+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func mr_registerCellWithNib(identifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: identifier, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
