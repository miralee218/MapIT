//
//  EditLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit

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

    var travel: Travel?
    lazy var locationPost = self.travel?.locationPosts?.allObjects as? [LocationPost]
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    var currentLocation: CLLocationCoordinate2D?
    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    var seletedPost: LocationPost?
    var saveHandler: (() -> Void)?

    var imageFilePath = [String]()
    var originPhoto = [URL]()
    var totalPhoto = [UIImage]()
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

        guard let latitude = seletedPost?.latitude,
            let longitude = seletedPost?.longitude
            else {
                return
        }
        postNameTextFeild.text = seletedPost?.title
        contentTextView.text = seletedPost?.content
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if let layout = locationNameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            //            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 25)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)

        guard let photos = seletedPost?.photo else { return }
        if let dirPath = paths.first {
            if photos.count > 0 {
                for photo in 0...photos.count - 1 {
                    let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(photos[photo])
                    let image    = UIImage(contentsOfFile: imageURL.path)!
                    originPhoto.append(imageURL)
                    totalPhoto.append(image)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nearByLocation()
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
        self.seletedPost?.title = self.postNameTextFeild.text
        self.seletedPost?.content = self.contentTextView.text

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first

        // create image data and write to filePath
        if totalPhoto.count > 0 {
            do {
                for index in 0...self.totalPhoto.count - 1 {
                    if let seletedImage = totalPhoto[index].pngData() {

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
            self.seletedPost?.photo = imageFilePath
        } else {
            self.seletedPost?.photo = nil
        }
        if originPhoto.count > 0 {
            for photo in 0...originPhoto.count - 1 {
                do {
                    try fileManager.removeItem(at: originPhoto[photo])
                } catch {
                }
            }
        }

        CoreDataStack.saveContext()
        saveHandler?()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func deleteLocation(_ sender: UIButton) {
    }

    func nearByLocation() {
        let request = MKLocalSearch.Request()

        request.region = MKCoordinateRegion(center: currentLocation!, latitudinalMeters: 10, longitudinalMeters: 10)
        for param in params {
            request.naturalLanguageQuery = param
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, _ in

                guard let strongSelf = self else { return }

                guard let response = response else { return }
                strongSelf.mapItemList = response.mapItems
                for item in strongSelf.mapItemList {
                    let annotation = PlaceAnnotation()
                    annotation.coordinate = item.placemark.location!.coordinate
                    annotation.title = item.name
                    annotation.url = item.url
                    annotation.detailAddress = item.placemark.title
                    strongSelf.places.append(item)
                }
                strongSelf.places.shuffle()
                strongSelf.locationNameCollectionView.reloadData()
            }
        }
    }

}

extension EditLocationCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.locationNameCollectionView {

            return places.count

        } else {
            return totalPhoto.count + 1

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
                self?.postNameTextFeild.text =  placeCell.locationNameLabel.text
            }
            return placeCell
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
                guard let photoCell = cell as? RoutePictureCollectionViewCell else { return cell }

                guard totalPhoto.count > 0 else {

                    photoCell.photoImageView.image = nil

                    return photoCell
                }

                photoCell.photoImageView.image = totalPhoto[indexPath.row - 1]

                photoCell.actionBlock = {[weak self] in
                    self?.totalPhoto.remove(at: indexPath.row - 1)
                    self?.photoCollectionView.reloadData()
                }

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
        totalPhoto.append(image)
        self.photoCollectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}
