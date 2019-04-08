//
//  RecordViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

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
        navigationController?.navigationBar.setGradientBackground(colors: UIColor.mainColor as! [UIColor])
    }
    

    @IBAction func searchRecord(_ sender: UIBarButtonItem) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search..."
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController
//        searchController.searchBar.backgroundColor = UIColor.red
        
        
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
        return 360
    }
    
    
}
