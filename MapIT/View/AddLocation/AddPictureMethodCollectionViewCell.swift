//
//  AddPictureMethodCollectionViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class AddPictureMethodCollectionViewCell: UICollectionViewCell {

    var openCamera: (() -> Void)?
    var openLibrary: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func openCamera(_ sender: UIButton) {
        openCamera?()
    }
    @IBAction func openPhotoLibrary(_ sender: UIButton) {
        openLibrary?()
    }

}
