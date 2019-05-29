//
//  AddLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AVFoundation
import RSKPlaceholderTextView
import TextFieldEffects
import SwiftMessages

class AddLocationCViewController: MapSearchViewController,
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var locationName: HoshiTextField!
    @IBOutlet weak var contentTextView: RSKPlaceholderTextView!
    @IBOutlet weak var locationNameCollectionView: UICollectionView! {
        didSet {

            locationNameCollectionView?.dataSource = self

            locationNameCollectionView?.delegate = self

        }

    }

    @IBOutlet weak var pictureCollectionView: UICollectionView! {
        didSet {

            pictureCollectionView?.dataSource = self

            pictureCollectionView?.delegate = self

        }

    }
    private var locationManager = LocationManager.shared
    var photoSelected = [UIImage]()
    var travel: Travel?
    var isEditting: Bool?
    var imageFilePath = [String]()
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()
    var coordinate = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.placeholder = "地點說明..."
        toolBarView.layer.cornerRadius
        = 10.0

        locationNameCollectionView.mr_registerCellWithNib(
            identifier: String(describing: AddLocationNameCollectionViewCell.self), bundle: nil)
        pictureCollectionView.mr_registerCellWithNib(
            identifier: String(describing: AddPictureMethodCollectionViewCell.self), bundle: nil)
        pictureCollectionView.mr_registerCellWithNib(
            identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)

        nearByLocation(region: mapView.region, collectionView: locationNameCollectionView)

        if let layout = locationNameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            //            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 25)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor

    }

    @IBAction func storeLocation(_ sender: UIButton) {
        saveLocation()
        NotificationCenter.default.post(name: .reloadRecordList, object: nil)
        NotificationCenter.default.post(name: .addAnnotations, object: nil, userInfo: ["coordinate": coordinate])
        MiraMessage.saveLocation()
        dismiss(animated: true, completion: nil)
    }
    private func saveLocation() {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.coordinate = locValue

        let newLocation = LocationPost(context: CoreDataManager.shared.viewContext)

        newLocation.timestamp = Date()
        newLocation.title = self.locationName.text
        newLocation.content = self.contentTextView.text
        newLocation.latitude = locValue.latitude
        newLocation.longitude = locValue.longitude

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        // create image data and write to filePath
        if photoSelected.count > 0 {
            do {
                for index in 0...self.photoSelected.count - 1 {
                    if let seletedImage = photoSelected[index].pngData() {

                        let date = Int(Date().timeIntervalSince1970 * 1000.0)

                        let path = "\(String(date)).png"

                        guard let filePath =
                            documentsURL?.appendingPathComponent(path) else {
                                return
                        }
                        try seletedImage.write(to: filePath, options: .atomic)
                        imageFilePath.append(path)
                    }
                }
            } catch {
                print("couldn't wirte image")
            }
            newLocation.photo = imageFilePath
        } else {
            newLocation.photo = nil
        }

        newLocation.travel = travel
        self.travel?.locationPosts?.adding(newLocation)

        CoreDataManager.shared.saveContext()

    }

    @IBAction func cancelAdd(_ sender: UIButton) {

        dismiss(animated: true, completion: nil)
    }

}

extension AddLocationCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.locationNameCollectionView {

            return places.count

        } else {

            return photoSelected.count + 1

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
            guard let placeCell = cell as? AddLocationNameCollectionViewCell else { return cell }
            placeCell.locationNameLabel.text = places[indexPath.row].name
            placeCell.actionBlock = { [weak self] in
                self?.locationName.text =  placeCell.locationNameLabel.text
            }
            return placeCell
        } else if collectionView == self.pictureCollectionView {

            if indexPath.row == 0 {

                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: AddPictureMethodCollectionViewCell.self),
                    for: indexPath
                )
                guard let optionCell = cell as? AddPictureMethodCollectionViewCell else {return cell}

                optionCell.openCamera = {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .notDetermined:
                            AVCaptureDevice.requestAccess(for: .video) { success in
                                guard success == true else { return }
                                AccessPhoto.accessCamera(viewController: self)
                            }
                        case .denied, .restricted:
                            let alertController = UIAlertController (title: "相機啟用失敗",
                                                                     message: "相機服務未啟用，請開啟權限以便新增地點的照片紀錄",
                                                                     preferredStyle: .alert)
                            let settingsAction = UIAlertAction(title: "立即權限", style: .default) { (_) -> Void in
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                }
                            }
                            alertController.addAction(settingsAction)
                            let cancelAction = UIAlertAction(title: "暫不啟用", style: .default, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        case .authorized:
                            print("Authorized, proceed")
                            DispatchQueue.main.async {
                                AccessPhoto.accessCamera(viewController: self)
                            }
                        @unknown default:
                            fatalError()
                        }
                    }
                }

                optionCell.openLibrary = {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        DispatchQueue.main.async {
                            AccessPhoto.accessLibrary(viewController: self)
                        }

                    }
                }

                return optionCell

            } else {
                let cell = pictureCollectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: RoutePictureCollectionViewCell.self),
                    for: indexPath
                )

                guard let photoCell = cell as? RoutePictureCollectionViewCell else {return cell}

                guard self.photoSelected.count > 0  else { return photoCell }
                photoCell.photoImageView.image = self.photoSelected[indexPath.row - 1]

                photoCell.actionBlock = {[weak self] in
                    self?.photoSelected.remove(at: indexPath.row - 1)
                    self?.pictureCollectionView.reloadData()
                }
                return photoCell

            }

        }

        return UICollectionViewCell()
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage
            else {
                print("selected image is nil")
                return
        }
//        // resize our selected image
//        let resizedImage = image.convert(toSize: CGSize(width: 120.0, height: 90.0), scale: UIScreen.main.scale)
        photoSelected.append(image)
        self.pictureCollectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }

}

extension AddLocationCViewController: UICollectionViewDelegateFlowLayout {
    //item 行 間距
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int)
        -> CGFloat {
            return 10
    }
    //item 間距
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int)
        -> CGFloat {
            return 5
    }
}
