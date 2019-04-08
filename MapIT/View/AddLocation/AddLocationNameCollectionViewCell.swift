//
//  AddLocationNameCollectionViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class AddLocationNameCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        locationNameLabel.layer.borderWidth = 1
        locationNameLabel.layer.borderColor = UIColor.MiraBlue?.cgColor
        locationNameLabel.layer.cornerRadius = 10
    }
    


}
