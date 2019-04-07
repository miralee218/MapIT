//
//  AddLocationCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import PullUpController

class RecordListCViewController: PullUpController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    var initialPointOffset: CGFloat {

        return swipeView.frame.height + 65
        
    }
    @IBOutlet weak var firstPreviewView: UIView!
    @IBOutlet weak var secondPreviewView: UIView!
    @IBOutlet weak var swipeView: UIView! {
        didSet {
            swipeView.layer.cornerRadius = 15.0
        }
    }
    @IBOutlet weak var searchSeparatorView: UIView!{
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    
    private var locations = [(title: String, location: CLLocationCoordinate2D)]()
    
    public var portraitSize: CGSize = .zero
    public var landscapeFrame: CGRect = .zero
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: secondPreviewView.frame.maxY)
        
        tableView.mr_registerCellWithNib(identifier: String(describing: RouteTableViewCell.self), bundle: nil)

    }
    
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return portraitSize
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return landscapeFrame
    }
    
    
    override var pullUpControllerBounceOffset: CGFloat {
        return 10
    }
    
    override func pullUpControllerAnimate(action: PullUpController.Action,
                                          withDuration duration: TimeInterval,
                                          animations: @escaping () -> Void,
                                          completion: ((Bool) -> Void)?) {
        switch action {
        case .move:
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        default:
            UIView.animate(withDuration: 0.3,
                           animations: animations,
                           completion: completion)
        }
    }
    
    




}


extension RecordListCViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RouteTableViewCell.self),
            for: indexPath
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 195
    }
    
    
}
