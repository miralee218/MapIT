//
//  RecordViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setGradientBackground(colors: UIColor.mainColor as! [UIColor])
        

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
