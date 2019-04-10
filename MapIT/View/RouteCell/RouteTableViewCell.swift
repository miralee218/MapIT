//
//  RouteTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var pointTitleLabel: UILabel!
    @IBOutlet weak var pointRecordTimeLabel: UILabel!
    @IBOutlet weak var pointDescriptionLabel: UILabel!
    var actionBlock: (() -> Void)?
    var editLocation: (() -> Void)?
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {

            collectionView?.dataSource = self

            collectionView?.delegate = self

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.mr_registerCellWithNib(
            identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func moreOption(_ sender: UIButton) {

        actionBlock?()

    }

}

extension RouteTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
            for: indexPath
        )

        return cell
    }

}
