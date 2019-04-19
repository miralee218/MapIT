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
    var actionBlock: (() -> Void)?
    var pictures = [Picture]()
    var travel = [Travel]()

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: NormalPictureCollectionViewCell.self), bundle: nil)

        getLocationPost()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreOption(_ sender: UIButton) {
        actionBlock?()
    }

    func getLocationPost() {
        //Core Data - Fetch Data
        let fetchRequest: NSFetchRequest<Picture> = Picture.fetchRequest()
        do {
            let pictures = try CoreDataStack.context.fetch(fetchRequest)
            self.pictures = pictures
        } catch {
        }
        collectionView.reloadData()
    }

}

extension RecordTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
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

        return photoCell
    }

}
