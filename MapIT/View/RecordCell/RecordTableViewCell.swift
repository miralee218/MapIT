//
//  RecordTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.mr_registerCellWithNib(identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreOption(_ sender: UIButton) {
    }
    
}

extension RecordTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
            for: indexPath
        )
        
        return cell
    }
    

    
    
}
