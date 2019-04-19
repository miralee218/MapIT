//
//  EditArticleTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class EditArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var travelNameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
