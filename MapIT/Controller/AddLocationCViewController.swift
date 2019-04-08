//
//  AddLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class AddLocationCViewController: UIViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var stireButton: UIButton!
    @IBOutlet weak var locationNameCollectionView: UICollectionView!{
        didSet {
            
            locationNameCollectionView?.dataSource = self
            
            locationNameCollectionView?.delegate = self
            
        }

    }
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!{
        didSet {
            
            pictureCollectionView?.dataSource = self
            
            pictureCollectionView?.delegate = self
            
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolBarView.layer.cornerRadius
        = 10.0
        
        locationNameCollectionView.mr_registerCellWithNib(identifier: String(describing: AddLocationNameCollectionViewCell.self), bundle: nil)
        
        pictureCollectionView.mr_registerCellWithNib(identifier: String(describing: AddPictureMethodCollectionViewCell.self), bundle: nil)
        pictureCollectionView.mr_registerCellWithNib(identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)
    }
    
    @IBAction func storeLocation(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAdd(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddLocationCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.locationNameCollectionView {
            
            return 4
            
        } else {
            
            return 4
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.locationNameCollectionView {
            let cell = locationNameCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: AddLocationNameCollectionViewCell.self),
                for: indexPath
            )
            
            return cell
        } else if collectionView == self.pictureCollectionView {
            //            let cell = photoCollectionView.dequeueReusableCell(
            //                withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
            //                for: indexPath
            //            )
            //
            //            return cell
            if indexPath.row == 0 {
                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddPictureMethodCollectionViewCell.self),
                    for: indexPath
                )
                
                return cell
                
            } else {
                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
                    for: indexPath
                )
                
                return cell
                
                
            }
            
        }
        return UICollectionViewCell()
    }
    
    //item 行 間距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    //item 間距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
        
    }

    
    
}
