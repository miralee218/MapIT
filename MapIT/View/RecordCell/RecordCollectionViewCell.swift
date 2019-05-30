//
//  RecordCollectionViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/5/4.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import CoreData
import Gemini

class RecordCollectionViewCell: GeminiCell {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var travelNameLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var travelContentLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var blockView: UIView!
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
        collectionView.layer.cornerRadius = 10
        backView.layer.shadowColor = (UIColor.B2)?.cgColor
        backView.layer.shadowOpacity = 0.4
        backView.layer.shadowRadius = 2
        backView.layer.shadowOffset = CGSize(width: 2, height: 2)
        backView.layer.cornerRadius = 10
    }
    @IBAction func moreOption(_ sender: UIButton) {
        actionBlock?()
    }

}
extension RecordCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count = 0
        var allLocationPost = travel.locationPosts?.allObjects as? [LocationPost]
        guard let allLocationCount = allLocationPost?.count else {
            self.blockView.isHidden = false
            return 0
        }
        guard allLocationCount > 0 else {
            self.blockView.isHidden = false
            return 0
        }
        for localPost in 0...allLocationCount - 1 {
            if let allLocationPhotoCount = allLocationPost?[localPost].photo?.count {
                count += allLocationPhotoCount
            }
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
            guard let photoCell = cell as? NormalPictureCollectionViewCell else {
                self.blockView.isHidden = false
                return cell
                
            }
            photos.removeAll()
            var allLocationPost = travel.locationPosts?.allObjects as? [LocationPost]
            for localPost in 0...allLocationPost!.count - 1 {
                if let count = allLocationPost?[localPost].photo?.count {
                    for index in 0...count - 1 {
                        photos.append((allLocationPost?[localPost].photo?[index])!)
                    }
                    continue
                }
            }
            if photos.count == 0 {
                self.blockView.isHidden = false
            } else {
                self.blockView.isHidden = true
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
