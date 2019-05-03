//
//  RouteTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import CoreData

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var pointTitleLabel: UILabel!
    @IBOutlet weak var pointRecordTimeLabel: UILabel!
    @IBOutlet weak var pointDescriptionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    var actionBlock: (() -> Void)?
    var count = Int()
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    var locationPost = LocationPost() {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {

            collectionView?.dataSource = self

            collectionView?.delegate = self

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.mr_registerCellWithNib(
            identifier: String(describing: NormalPictureCollectionViewCell.self), bundle: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func moreOption(_ sender: UIButton) {

        actionBlock?()

    }

}

extension RouteTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = locationPost.photo?.count else {
            return 0
        }

        return count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: NormalPictureCollectionViewCell.self),
            for: indexPath
        )
            guard let photoCell = cell as? NormalPictureCollectionViewCell else { return cell }

            guard let photo = locationPost.photo?[indexPath.item]  else {

                photoCell.photoImageView.image = nil

                return photoCell
            }

            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)

            if let dirPath = paths.first {
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(photo)
                let image    = UIImage(contentsOfFile: imageURL.path)
                photoCell.photoImageView.image = image
                // Do whatever you want with the image

            }

            return photoCell
    }
}
