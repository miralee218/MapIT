//
//  NotificationViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import Photos

class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)
    }
//    func grabPhoto() {
//        let imgManager = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//        requestOptions.deliveryMode = .highQualityFormat
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions){
//            if fetchResult.count > 0 {
//
//                
//            }
//        }
//    }

}

extension NotificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
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
