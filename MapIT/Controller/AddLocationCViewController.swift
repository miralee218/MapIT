//
//  AddLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class AddLocationCViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
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
    
    var mutableArray = NSMutableArray()
    

    
}

extension AddLocationCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.locationNameCollectionView {
            
            return 4
            
        } else {
            
            return mutableArray.count + 1
            
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

            if indexPath.row == 0 {

                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddPictureMethodCollectionViewCell.self),
                    for: indexPath
                )
                guard let optionCell = cell as? AddPictureMethodCollectionViewCell else {return cell}
                
                optionCell.openCamera = {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        AccessPhoto.accessCamera(viewController: self)
                    }
                }
                
                optionCell.openLibrary = {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        AccessPhoto.accessLibrary(viewController: self)
                        

                    }
                }
                
                return optionCell

                
            } else {
                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
                    for: indexPath
                )
                
                guard let photoCell = cell as? RoutePictureCollectionViewCell else {return cell}
                
                guard (self.mutableArray.count > 0)  else { return photoCell }
                photoCell.photoImageView.image = self.mutableArray[indexPath.row - 1] as? UIImage
                
                return photoCell
                
                
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        mutableArray.add(image)
        self.pictureCollectionView.reloadData()
        picker.dismiss(animated:true, completion: nil)
        
        
    }


    
    
}
