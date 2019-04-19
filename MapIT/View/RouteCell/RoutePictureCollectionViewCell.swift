//
//  RoutePictureCollectionViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RoutePictureCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    var actionBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func cancelImage(_ sender: UIButton) {
        actionBlock?()
    }
    
}
