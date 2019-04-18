//
//  AddLocationNameCollectionViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class AddLocationNameCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var locationNameButton: UIButton!
    @IBOutlet weak var locationNameLabel: UILabel!
    var actionBlock: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        locationNameButton.layer.borderWidth = 1
        locationNameButton.layer.borderColor = UIColor.MiraBlue?.cgColor
        locationNameButton.layer.cornerRadius = 20
    }
    @IBAction func changeLocationName(_ sender: UIButton) {
        actionBlock?()
    }

}
