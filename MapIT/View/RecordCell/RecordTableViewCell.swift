//
//  RecordTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import CoreData

class RecordTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var travelNameLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var travelContentLabel: UILabel!
    var actionBlock: (() -> Void)?
    var travel = Travel() {
        didSet {
            collectionView.reloadData()
        }
    }
    var count = 0
    var photos = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: NormalPictureCollectionViewCell.self), bundle: nil)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreOption(_ sender: UIButton) {
        actionBlock?()
    }
}

extension RecordTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count = 0
        var allLocationPost = travel.locationPosts?.allObjects as? [LocationPost]
        guard let allLocationCount = allLocationPost?.count else {
            return 0
        }
        guard allLocationCount > 0 else {
            return 0
        }
        for localPost in 0...allLocationCount - 1 {
            guard let allLocationPhotoCount = allLocationPost?[localPost].photo?.count else {
                return 0
            }
            count += allLocationPhotoCount
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
            photos.removeAll()
            var allLocationPost = travel.locationPosts?.allObjects as? [LocationPost]
            for localPost in 0...allLocationPost!.count - 1 {
                for index in 0...(allLocationPost?[localPost].photo!.count)! - 1 {
                    photos.append((allLocationPost?[localPost].photo?[index])!)
                }
            }
            let photo = photos[indexPath.row]
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
