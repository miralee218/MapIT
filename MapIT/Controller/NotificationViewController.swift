//
//  NotificationViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import Photos
import CoreData
import Lottie

class NotificationViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var cameraView: AnimationView!
    var allTravel: [Travel]?
    var travel: Travel?
    var count = 0
    var photos = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
    navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )
        navigationController?.navigationBar.isHidden = false
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: NormalPictureCollectionViewCell.self), bundle: nil)

    }
    let coreDataManager = CoreDataManager()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        collectionView.reloadData()
    }
    func fetchData() {
        CoreDataManager.shared.getAllTravels(completion: { result in
            switch result {
            case .success(let travels):
                if travels.count == 0 {
                    self.noDataView.isHidden = false
                } else {
                    self.allTravel = travels
                    self.noDataView.isHidden = true
                }
            case .failure(_):
                self.noDataView.isHidden = false
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cameraView = AnimationView(name: "CameraLottieFiles")
        cameraView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        cameraView.contentMode = .scaleAspectFill
        self.cameraView.addSubview(cameraView)
        cameraView.loopMode = .loop
        cameraView.play()
    }
    @IBAction func goToMap(_ sender: UIButton) {
                tabBarController?.selectedViewController = tabBarController?.viewControllers![1]
    }

}
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension NotificationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let count = allTravel?.count else {
            return 0
        }
        return count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        count = 0
        var allLocationPost = allTravel?[section].locationPosts?.allObjects as? [LocationPost]
        guard let allLocationCount = allLocationPost?.count else {
            return 0
        }
        guard allLocationCount > 0 else {
            return 0
        }
        for localPost in 0...allLocationCount - 1 {
            if let allLocationPhotoCount = allLocationPost?[localPost].photo?.count {
                count += allLocationPhotoCount
            }
        }
        return count

    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView!

        //分区头
        if kind == UICollectionView.elementKindSectionHeader {
            reusableview = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: "PhotoHeaderView", for: indexPath)
            //设置头部标题
            guard let label = reusableview.viewWithTag(1) as? UILabel else {
                return reusableview
            }
            label.text = allTravel?[indexPath.section].title
        }

        return reusableview
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
            photos.removeAll()
            guard let allLocationPost = allTravel?[indexPath.section].locationPosts?.allObjects as? [LocationPost] else {
                return photoCell
            }
            for localPost in 0...allLocationPost.count - 1 {
                if let count = allLocationPost[localPost].photo?.count {
                    for index in 0...count - 1 {
                        photos.append((allLocationPost[localPost].photo?[index])!)
                    }
                    continue
                }
            }
            let photo = photos[indexPath.row]
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            if let dirPath = paths.first {
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(photo)
                let image    = UIImage(contentsOfFile: imageURL.path)
                photoCell.photoImageView.image = image
                photoCell.photoImageView.layer.cornerRadius = 3
                photoCell.photoImageView.clipsToBounds = true
                // Do whatever you want with the image
            }
        return photoCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "FullScreenImageViewController") as? FullScreenImageViewController {
            photos.removeAll()
            guard let allLocationPost = allTravel?[indexPath.section].locationPosts?.allObjects as? [LocationPost] else {
                return
            }
            for localPost in 0...allLocationPost.count - 1 {
                if let count = allLocationPost[localPost].photo?.count {
                    for index in 0...count - 1 {
                        photos.append((allLocationPost[localPost].photo?[index])!)
                    }
                    continue
                }
            }
            vc.photos = photos
            vc.selectedIndex = indexPath.row
            print(indexPath)
            present(vc, animated: true, completion: nil)
        }
    }
}
