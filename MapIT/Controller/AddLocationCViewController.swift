//
//  AddLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit

class AddLocationCViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
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
    var mutableArray = NSMutableArray()
    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    var mapView = MKMapView()
    var locationPost: LocationPost?
    let recordListVC = RecordListCViewController()
    private var locationManager = LocationManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        toolBarView.layer.cornerRadius
        = 10.0

        locationNameCollectionView.mr_registerCellWithNib(
            identifier: String(describing: AddLocationNameCollectionViewCell.self), bundle: nil)
        pictureCollectionView.mr_registerCellWithNib(
            identifier: String(describing: AddPictureMethodCollectionViewCell.self), bundle: nil)
        pictureCollectionView.mr_registerCellWithNib(
            identifier: String(describing: RoutePictureCollectionViewCell.self), bundle: nil)

        nearByLocation()
        if let layout = locationNameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            //            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 25)
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor
    }

    func nearByLocation() {
        let request = MKLocalSearch.Request()
        request.region = mapView.region
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }

    @IBAction func storeLocation(_ sender: UIButton) {

        saveLocation()
        dismiss(animated: true, completion: nil)
    }
    private func saveLocation() {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")

        let newLocaiotn = LocationPost(context: CoreDataStack.context)
        newLocaiotn.timestamp = Date()
        newLocaiotn.title = self.locationName.text
        newLocaiotn.content = self.contentTextView.text
        newLocaiotn.latitude = locValue.latitude
        newLocaiotn.longitude = locValue.longitude

//        let newPicture = Picture(context: CoreDataStack.context)
//        for picture in 1...mutableArray.count {
//            newPicture.picture = mutableArray[picture] as? String
//        }
//        print(newPicture)

        CoreDataStack.saveContext()

        locationPost = newLocaiotn
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

                guard self.mutableArray.count > 0  else { return photoCell }
                photoCell.photoImageView.image = self.mutableArray[indexPath.row - 1] as? UIImage
                photoCell.actionBlock = {[weak self] in
                    self?.mutableArray.removeObject(at: indexPath.row - 1)
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
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else {
                return
        }
        mutableArray.add(image)
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
