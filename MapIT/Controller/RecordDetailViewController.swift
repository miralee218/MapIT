//
//  RecordDetailViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/9.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class RecordDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       navigationItem.title = "OwO"

        tableView.separatorStyle = .none

        tableView.mr_registerCellWithNib(
            identifier: String(describing: RecordImageTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(
            identifier: String(describing: RecordDescriptionTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(
            identifier: String(describing: RouteTableViewCell.self), bundle: nil)

    }

    @IBAction func articleMoreButton(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let option4 = UIAlertAction(title: "地圖導航", style: .default) { (_) in
            print("To Apple Map")
        }

        let option3 = UIAlertAction(title: "編輯旅程內容", style: .default) { [weak self] (_) in

            let vc = UIStoryboard.mapping.instantiateViewController(
                withIdentifier: String(describing: StoredMapCViewController.self))

            self?.present(vc, animated: true, completion: nil)
        }

        let option2 = UIAlertAction(title: "刪除", style: .destructive) { (_) in
            print("YOU HAVE DELETED YOUR RECORD")
        }

        let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        sheet.addAction(option4)
        sheet.addAction(option3)
        sheet.addAction(option2)
        sheet.addAction(option1)

        self.present(sheet, animated: true, completion: nil)
    }

}

extension RecordDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 5
        default:
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecordImageTableViewCell.self),
                for: indexPath
            )

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecordDescriptionTableViewCell.self),
                for: indexPath
            )

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RouteTableViewCell.self),
                for: indexPath
            )

            guard let routeCell = cell as? RouteTableViewCell else { return cell }

            routeCell.actionBlock = {

                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                let option4 = UIAlertAction(title: "地圖導航", style: .default) { (_) in
                    print("To Apple Map")
                }

                let option3 = UIAlertAction(title: "編輯", style: .default) { [weak self] (_) in

                    let vc = UIStoryboard.mapping.instantiateViewController(
                        withIdentifier: String(describing: EditLocationCViewController.self))

                    self?.present(vc, animated: true, completion: nil)
                }

                let option2 = UIAlertAction(title: "刪除", style: .destructive) { (_) in
                    print("YOU HAVE DELETED YOUR RECORD")
                }

                let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)

                sheet.addAction(option4)
                sheet.addAction(option3)
                sheet.addAction(option2)
                sheet.addAction(option1)

                self.present(sheet, animated: true, completion: nil)

            }

            return routeCell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 420
        case 1:
            return UITableView.automaticDimension
        case 2:
            return 200
        default:
            return 0
        }
    }

}
