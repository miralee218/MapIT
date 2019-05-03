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
    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    var mapView = MKMapView()
    var travel: Travel?
    let recordListVC = RecordListCViewController()
    private var locationManager = LocationManager.shared
    var photoSelected = [UIImage]()
    lazy var isEditting = isEdittingTravel()
    var imageFilePath = [String]()
    var lat = CLLocationDegrees()
    var long = CLLocationDegrees()
    var coordinate = CLLocationCoordinate2D()
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

        if isEditting == true {
            print("123")
        }

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
    func isEdittingTravel() -> Bool {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        let isEditting = "1"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        fetchRequest.fetchLimit = 0
        do {
            let context = CoreDataStack.context
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // no matching object
                print("no present")
                return false
            } else if count == 1 {
                // at least one matching object exists
                let edittingTravel = try? context.fetch(fetchRequest).first
                self.travel = edittingTravel
                print("only:\(count) continue editing...")
                return true
            } else {
                print("matching items found:\(count)")
                return false
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    @IBAction func storeLocation(_ sender: UIButton) {
        saveLocation()
        NotificationCenter.default.post(name: .reloadRecordList, object: nil)
        NotificationCenter.default.post(name: .addMark, object: nil, userInfo: ["coordinate": coordinate])
        dismiss(animated: true, completion: nil)
    }
    private func saveLocation() {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.coordinate = locValue

        let newLocation = LocationPost(context: CoreDataStack.context)

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

        CoreDataStack.saveContext()

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
                            let alertController = UIAlertController (title: "相機啟用失敗", message: "相機服務未啟用，請開啟權限以便新增地點的照片紀錄", preferredStyle: .alert)
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
                            AccessPhoto.accessCamera(viewController: self)
                        }
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
