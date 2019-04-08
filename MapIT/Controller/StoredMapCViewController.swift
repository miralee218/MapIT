//
//  StoredMapCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class StoredMapCViewController: UIViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolBarView.layer.cornerRadius
            = 10.0

    }
    
    @IBAction func cancelStore(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    

}
