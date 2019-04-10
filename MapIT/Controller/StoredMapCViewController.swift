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
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        toolBarView.layer.cornerRadius
            = 10.0
        tableView.separatorStyle = .none
        tableView.mr_registerCellWithNib(identifier: String(describing: EditArticleTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(identifier: String(describing: MapTableViewCell.self), bundle: nil)

    }

    @IBAction func cancelStore(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }

}

extension StoredMapCViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch  indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MapTableViewCell.self),
                for: indexPath
            )
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: EditArticleTableViewCell.self),
                for: indexPath
            )
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        case 1:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
}
