//
//  EditLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class EditLocationCViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var postNameTextFeild: UITextField!

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var locationNameCollectionView: UICollectionView! {
        didSet {
            locationNameCollectionView.delegate = self
            locationNameCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var photoCollectionView: UICollectionView! {
        didSet {
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
        }
    }

    var mutableArray = NSMutableArray()
    var travel: Travel?
//    lazy var locationPost = self.travel?.locationPosts?.allObjects as? LocationPost
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBarView.layer.cornerRadius = 10

        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor

        locationNameCollectionView.mr_registerCellWithNib(
            identifier: String(
                describing: AddLocationNameCollectionViewCell.self),
            bundle: nil)

        photoCollectionView.mr_registerCellWithNib(
            identifier: String(
                describing: AddPictureMethodCollectionViewCell.self),
            bundle: nil)
        photoCollectionView.mr_registerCellWithNib(
            identifier: String(
                describing: RoutePictureCollectionViewCell.self),
            bundle: nil)

        guard let locationPost = travel?.locationPosts?.allObjects as? [LocationPost],
              let title = locationPost.first?.title, let content = locationPost.first?.content
        else {
            return
        }
        postNameTextFeild.text = title
        contentTextView.text = content

    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
    }
    @IBAction func deleteLocation(_ sender: UIButton) {
    }

}

extension EditLocationCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.locationNameCollectionView {

            return 4

        } else {

            return mutableArray.count + 1

        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {

        if collectionView == self.locationNameCollectionView {
            let cell = locationNameCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: AddLocationNameCollectionViewCell.self),
                for: indexPath
            )

            return cell
        } else if collectionView == self.photoCollectionView {

            if indexPath.row == 0 {

                let cell = photoCollectionView.dequeueReusableCell(
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
                let cell = photoCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
                    for: indexPath
                )

                guard let photoCell = cell as? RoutePictureCollectionViewCell else {return cell}

                guard self.mutableArray.count > 0  else { return photoCell }
                photoCell.photoImageView.image = self.mutableArray[indexPath.row - 1] as? UIImage

                return photoCell

            }

        }
        return UICollectionViewCell()
    }

    //item 行 間距
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int)
        -> CGFloat {
        return 24
    }

    //item 間距
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int)
        -> CGFloat {
        return 10

    }
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        mutableArray.add(image)
        self.photoCollectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}
