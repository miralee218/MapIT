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

class RecordViewController: UIViewController {
    private enum LayoutType {
        case list
        case grid
    }
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
//        navigationController?.navigationBar.isTranslucent = false
        tableView.mr_registerCellWithNib(identifier: String(describing: RecordTableViewCell.self), bundle: nil)
        collectionView.mr_registerCellWithNib(
            identifier: String(describing: RecordCollectionViewCell.self), bundle: nil)
        getTravel()
        launchAnimation()
        myGifView.loadGif(name: "MapMark")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = true
        getTravel()
        tableView.reloadData()
        collectionView.reloadData()
    }
    func launchAnimation() {
        let vc = (UIStoryboard(name: "LaunchScreen",
                               bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        )
        let launchView = vc.view
        let delegate = UIApplication.shared.delegate
        delegate?.window??.addSubview(launchView!)
        UIView.animate(withDuration: 1, delay: 0.5, options: .beginFromCurrentState,
                       animations: {
                        launchView?.alpha = 0.0
                        let transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1.5)
                        launchView?.layer.transform = transform
        }) { finished in
            launchView?.removeFromSuperview()
        }
    }

    @IBAction func switchView(_ sender: UIBarButtonItem) {
        isListLayout = !isListLayout
    }
    private func showListLayout() {
        layoutBtn.image = UIImage.asset(.Icons_verticalCell)
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.alpha = 1
            })

    }
    private func showGridLayout() {
        layoutBtn.image = UIImage.asset(.Icons_horizontalCell)
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.alpha = 0
        })
    }
    func getTravel() {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Travel.createTimestamp), ascending: false)]
        let isEditting = "0"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        fetchRequest.fetchLimit = 0
        do {
            let context = CoreDataStack.context
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // no matching object

                noDataView.isHidden = false
                layoutBtn.isEnabled = false
                print("no present")
            } else {
                // at least one matching object exists
                guard let edittingTravel = try? context.fetch(fetchRequest) else { return }
                self.allTravel = edittingTravel
                noDataView.isHidden = true
                layoutBtn.isEnabled = true
                print("have\(count) travel")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        tableView.reloadData()
        collectionView.reloadData()
    }

    func getSpecificTravel() {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Travel.createTimestamp), ascending: false)]

        let isEditting = "0"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        guard let selected = self.seletedDate as? NSData else {
            return
        }
        fetchRequest.predicate = NSPredicate(format: "timestamp <= %@", selected)
        fetchRequest.fetchLimit = 0
        do {
            let context = CoreDataStack.context
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // no matching object

                noDataView.isHidden = false
                layoutBtn.isEnabled = false
                print("no present")
            } else {
                // at least one matching object exists
                guard let edittingTravel = try? context.fetch(fetchRequest) else { return }
                self.allTravel = edittingTravel
                noDataView.isHidden = true
                layoutBtn.isEnabled = true
                print("have\(count) travel")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        tableView.reloadData()
        collectionView.reloadData()
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
    func showDeleteDialog(animated: Bool = true) {
        // Prepare the popup
        let title = "確定刪除?"
        let message = "若刪除紀錄，將無法再次回復唷QAQ"
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        // Create first button
        let buttonOne = CancelButton(title: "取消") {
        }
        // Create second button
        let buttonTwo = DestructiveButton(title: "刪除") { [weak self] in
            self?.deleteHandler?()
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
}
extension RecordViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.seletedDate = date.toLocalTime()
        print(seletedDate)
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
            let option3 = UIAlertAction(title: "分享", style: .default) { [weak self] (_) in
                let vc = UIStoryboard.record.instantiateViewController(
                    withIdentifier: String(describing: SharedOptionViewController.self))
                self?.present(vc, animated: true, completion: nil)
            }
            let option2 = UIAlertAction(title: "刪除", style: .destructive) { [weak self] (_) in
                self?.showDeleteDialog()
                self?.deleteHandler = { [weak self] in
                    guard let removeOrder = self?.allTravel?[indexPath.row] else { return }
                    CoreDataStack.delete(removeOrder)
                    self?.getTravel()
                    self?.allTravel?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                    print("YOU HAVE DELETED YOUR RECORD")
                }
            }
            let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            sheet.addAction(option3)
            sheet.addAction(option2)
            sheet.addAction(option1)
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
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionViewCell.self),
            for: indexPath
        )
        guard let recordCell = cell as? RecordCollectionViewCell else { return cell }
        recordCell.actionBlock = { [weak self] in
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let option3 = UIAlertAction(title: "分享", style: .default) { [weak self] (_) in
                let vc = UIStoryboard.record.instantiateViewController(
                    withIdentifier: String(describing: SharedOptionViewController.self))
                self?.present(vc, animated: true, completion: nil)
            }
            let option2 = UIAlertAction(title: "刪除", style: .destructive) { [weak self] (_) in
                self?.showDeleteDialog()
                self?.deleteHandler = { [weak self] in
                    guard let removeOrder = self?.allTravel?[indexPath.row] else { return }
                    CoreDataStack.delete(removeOrder)
                    self?.getTravel()
                    collectionView.reloadData()
                    print("YOU HAVE DELETED YOUR RECORD")
                }
            }
            let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            sheet.addAction(option3)
            sheet.addAction(option2)
            sheet.addAction(option1)
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionViewCell.self),
            for: indexPath
        )
        guard let recordCell = cell as? RecordCollectionViewCell else { return }
        self.collectionView.animateCell(recordCell)
    }
}
