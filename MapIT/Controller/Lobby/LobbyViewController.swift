//
//  LobbyViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class LobbyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        let layer = CAGradientLayer()
        layer.frame = view.bounds
        layer.colors = [UIColor.hexStringToUIColor(hex: "FA508C").cgColor,
                        UIColor.hexStringToUIColor(hex: "FFC86E").cgColor]
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        view.layer.addSublayer(layer)

    }

    private func setupLayout() {

        navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )

    }

}
