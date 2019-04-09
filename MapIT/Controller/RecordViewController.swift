//
//  RecordViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import FSCalendar

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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setGradientBackground(colors: UIColor.mainColor as! [UIColor])
        
        tableView.separatorStyle = .none
        
        tableView.mr_registerCellWithNib(identifier: String(describing: RecordTableViewCell.self), bundle: nil)
        
        
        

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

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
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController

        if searchBySearchBar == false && searchByCalendar == true{
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
    

}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecordTableViewCell.self),
            for: indexPath
        )
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SegueToRecordDetail", sender: indexPath)
    }
    
    
}
