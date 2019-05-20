//
//  RecordViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData
import Gemini
import PopupDialog
import SwiftMessages

class RecordViewController: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var calendarButton: UIBarButtonItem!
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self

        }
    }
    @IBOutlet weak var layoutBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: GeminiCollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.gemini
                .cubeAnimation()
                .cubeDegree(30)
        }
    }
    @IBOutlet weak var noDataView: UIView!

    @IBOutlet weak var myGifView: UIImageView!
    var allTravel: [Travel]?
    var selectedTravel: Travel?
    var seletedDate: Date?
    var isListLayout: Bool = true {

        didSet {

            switch isListLayout {

            case true: showListLayout()

            case false: showGridLayout()

            }
        }
    }
    var deleteHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )
        tableView.separatorStyle = .none
        tableView.mr_registerCellWithNib(identifier: String(describing: RecordTableViewCell.self), bundle: nil)
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: RecordCollectionViewCell.self), bundle: nil)
        LaunchScreen.launchAnimation()
        myGifView.loadGif(name: "MapMark")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllTravel()
        tableView.reloadData()
        collectionView.reloadData()
    }
    private func getAllTravel() {
        allTravel = MapManager.getAllTravel(noDataAction: { [weak self] in
            self?.noDataView.isHidden = false
            self?.layoutBtn.isEnabled = false
            }, hadDataAction: { [weak self] in
                self?.noDataView.isHidden = true
                self?.layoutBtn.isEnabled = true
        })
        tableView.reloadData()
        collectionView.reloadData()
    }
    @IBAction func switchView(_ sender: UIBarButtonItem) {
        isListLayout = !isListLayout
        collectionView.reloadData()
        tableView.reloadData()
    }
    private func showListLayout() {
        layoutBtn.image = UIImage.asset(.Icons_verticalCell)
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.alpha = 1
            })

    }
    private func showGridLayout() {
        layoutBtn.image = UIImage.asset(.Icons_horizontalCell)
        UIView.animate(withDuration: 0.8, animations: {
            self.collectionView.alpha = 0
        })
    }
    var searchByCalendar = false
    @IBAction func searchByCalendar(_ sender: UIBarButtonItem) {
        if searchByCalendar == false {
            selectCalendarImage()

            searchBarButton.image = UIImage(named: ImageAsset.Icons_Search_Unselected.rawValue)
            searchBySearchBar = false
        } else {

            unselectCalendarImage()

        }

    }

    var searchBySearchBar = false
    @IBAction func searchRecord(_ sender: UIBarButtonItem) {
        print("search")
        tableView.reloadData()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController

        if searchBySearchBar == false && searchByCalendar == true {
            searchBarButton.image = UIImage(named: ImageAsset.Icons_Search_Selected.rawValue)
            searchBySearchBar = true

            unselectCalendarImage()

        } else if searchBySearchBar == false {
            searchBarButton.image = UIImage(named: ImageAsset.Icons_Search_Selected.rawValue)
            searchBySearchBar = true
        } else {
            searchBarButton.image = UIImage(named: ImageAsset.Icons_Search_Unselected.rawValue)
            searchBySearchBar = false

        }

    }

    func selectCalendarImage() {
        calendarButton.image = UIImage(named: ImageAsset.Icons_Calendar_Selected.rawValue)
        calendarView.isHidden = false
        calendarTopConstraints.constant += 300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        searchByCalendar = true
    }
    func unselectCalendarImage() {
        calendarButton.image = UIImage(named: ImageAsset.Icons_Calendar_Unselected.rawValue)
        calendarTopConstraints.constant -= 300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        searchByCalendar = false

    }

    private func showDetailVC(travel: Travel) {

        let vc = UIStoryboard.record.instantiateViewController(withIdentifier:
            String(describing: RecordDetailViewController.self)
        )

        guard let detailVC = vc as? RecordDetailViewController else { return }

        detailVC.travel = selectedTravel

        show(detailVC, sender: nil)
    }
    @IBAction func goToMap(_ sender: UIButton) {
        tabBarController?.selectedViewController = tabBarController?.viewControllers![1]
    }
}
extension RecordViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.seletedDate = date.toLocalTime()
    }
}
extension Date {
    // Convert UTC (or GMT) to local time

    func toLocalTime() -> Date {

        let timezone = TimeZone.current

        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))

        return Date(timeInterval: seconds, since: self)

    }
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {

        let timezone = TimeZone.current

        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))

        return Date(timeInterval: seconds, since: self)

    }

}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = allTravel?.count else {
            return 0
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecordTableViewCell.self),
            for: indexPath
        )
        guard let recordCell = cell as? RecordTableViewCell else { return cell }
        recordCell.actionBlock = { [weak self] in
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteOption = UIAlertAction(title: "刪除", style: .destructive) { [weak self] (_) in
                guard let strongSelf = self else { return }
                MiraDialog.showDeleteDialog(animated: true, deleteHandler: { [weak self] in
                    guard let removeOrder = self?.allTravel?[indexPath.row] else { return }
                    CoreDataManager.delete(removeOrder)
                    self?.getAllTravel()
                    self?.tableView.reloadData()
                    MiraMessage.deleteSuccessfully()
                }, vc: strongSelf)
            }
            let cancelOption = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            sheet.addAction(deleteOption)
            sheet.addAction(cancelOption)
            self?.present(sheet, animated: true, completion: nil)
        }
        //
        let formattedDate = FormatDisplay.travelDate(allTravel?[indexPath.row].createTimestamp)
        recordCell.contentInit(name: allTravel?[indexPath.row].title,
                               time: formattedDate,
                               content: allTravel?[indexPath.row].content)
        guard let indexTravel = allTravel?[indexPath.row] else {
            return cell
        }
        recordCell.travel = indexTravel
        recordCell.selectionStyle = .none
        return recordCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let indexTravel = allTravel?[indexPath.row] else {
            return
        }
        self.selectedTravel = indexTravel

        guard let travel = selectedTravel else {
            return
        }
        showDetailVC(travel: travel)

    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.75) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }

}
extension RecordViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = allTravel?.count else {
            return 0
        }
        return count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionViewCell.self),
            for: indexPath
        )
        guard let recordCell = cell as? RecordCollectionViewCell else { return cell }
        recordCell.actionBlock = { [weak self] in
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteOption = UIAlertAction(title: "刪除", style: .destructive) { [weak self] (_) in
                guard let strongSelf = self else { return }
                MiraDialog.showDeleteDialog(animated: true, deleteHandler: { [weak self] in
                    guard let removeOrder = self?.allTravel?[indexPath.row] else { return }
                    CoreDataManager.delete(removeOrder)
                    self?.getAllTravel()
                    self?.collectionView.reloadData()
                    MiraMessage.deleteSuccessfully()
                }, vc: strongSelf)
            }
            let cancelOption = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            sheet.addAction(deleteOption)
            sheet.addAction(cancelOption)
            self?.present(sheet, animated: true, completion: nil)
        }
        recordCell.travelNameLabel.text = allTravel?[indexPath.row].title
        let formattedDate = FormatDisplay.travelDate(allTravel?[indexPath.row].createTimestamp)
        recordCell.travelTimeLabel.text = formattedDate
        recordCell.travelContentLabel.text = allTravel?[indexPath.row].content
        guard let indexTravel = allTravel?[indexPath.row] else {
            return cell
        }
        recordCell.travel = indexTravel
        //Animated
        self.collectionView.animateCell(recordCell)
        return recordCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexTravel = allTravel?[indexPath.row] else {
            return
        }
        self.selectedTravel = indexTravel
        guard let travel = selectedTravel else {
            return
        }
        showDetailVC(travel: travel)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.animateVisibleCells()
    }
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionViewCell.self),
            for: indexPath
        )
        guard let recordCell = cell as? RecordCollectionViewCell else { return }
        self.collectionView.animateCell(recordCell)
    }
}
