//
//  ProfileViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    let iconTitle = ["設定", "收藏", "照片"]
    let iconImage = [ImageAsset.Icons_Setting, ImageAsset.Icons_Archive, ImageAsset.Icons_Photos]
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: ProfileCollectionViewCell.self),
            bundle: nil)

    }

}
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconTitle.count
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCollectionViewCell else { return cell }
        profileCell.iconTitleLabel.text = iconTitle[indexPath.row]
            profileCell.iconImageView.image = UIImage(named: iconImage[indexPath.row].rawValue)
        return profileCell
    }
}
