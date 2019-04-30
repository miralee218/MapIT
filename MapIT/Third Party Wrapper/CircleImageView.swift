//
//  CircleImageView.swift
//  MapIT
//
//  Created by Mira on 2019/4/29.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

import UIKit
@IBDesignable
class CircleImageView: UIImageView {
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
}
