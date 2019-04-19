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
    var editLocation: (() -> Void)?
    var locationPost = [LocationPost]()
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

        getLocationPost()
    }
    func getLocationPost() {
        //Core Data - Fetch Data
        let fetchRequest: NSFetchRequest<LocationPost> = LocationPost.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(LocationPost.timestamp), ascending: true)]
        do {
            let locationPost = try CoreDataStack.context.fetch(fetchRequest)
            self.locationPost = locationPost
        } catch {
        }
        collectionView.reloadData()
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
//        guard let count = locationPost[section].photo?.count else {
//            return 0
//        }
//        return count
        return 5
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: NormalPictureCollectionViewCell.self),
            for: indexPath
        )
//        guard let photoCell = cell as? NormalPictureCollectionViewCell else { return cell }
//            guard let photo = locationPost[indexPath.item].photo else { return cell }
//            photoCell.photoImageView.image = UIImage(data: photo, scale: 1.0)
//
//        return photoCell

            return cell

    }
}
