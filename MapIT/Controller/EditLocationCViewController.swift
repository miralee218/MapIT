//
//  EditLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class EditLocationCViewController: UIViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var locationNameCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBarView.layer.cornerRadius = 10
        

    }
    
    @IBAction func cancel(_ sender: UIButton) {
    }
    @IBAction func store(_ sender: UIButton) {
    }
    @IBAction func deleteLocation(_ sender: UIButton) {
    }
    

}
