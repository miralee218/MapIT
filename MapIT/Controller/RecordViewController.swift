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
    @IBOutlet weak var noDataView: UIView!

    var allTravel = [Travel]()
    lazy var selectedTravel = Travel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )
        navigationController?.navigationBar.isTranslucent = false

        tableView.separatorStyle = .none

        tableView.mr_registerCellWithNib(identifier: String(describing: RecordTableViewCell.self), bundle: nil)

        getTravel()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTravel()
        tableView.reloadData()
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
                print("no present")
            } else {
                // at least one matching object exists
                let edittingTravel = try? context.fetch(fetchRequest)
                self.allTravel = edittingTravel!
                noDataView.isHidden = true
                print("have\(count) travel")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        tableView.reloadData()
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

}
extension RecordViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        let date = date.toLocalTime()
        print(date)
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
        return allTravel.count
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
                guard let removeOrder = self?.allTravel[indexPath.row] else { return }
                CoreDataStack.delete(removeOrder)
                self?.getTravel()
                tableView.reloadData()
                print("YOU HAVE DELETED YOUR RECORD")
            }
            let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            sheet.addAction(option3)
            sheet.addAction(option2)
            sheet.addAction(option1)
            self?.present(sheet, animated: true, completion: nil)
        }
        recordCell.travelNameLabel.text = allTravel[indexPath.row].title
        let formattedDate = FormatDisplay.travelDate(allTravel[indexPath.row].createTimestamp)
        recordCell.travelTimeLabel.text = formattedDate
        recordCell.travelContentLabel.text = allTravel[indexPath.row].content

        return recordCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTravel = allTravel[indexPath.row]
        showDetailVC(travel: selectedTravel)

    }

}
