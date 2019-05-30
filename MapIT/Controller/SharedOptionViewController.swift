//
//  SharedOptionViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class SharedOptionViewController: UIViewController {
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var submitButton: UIButton!
    var optaionList: [String] = Array()
    var selectedElement = [Int: String] ()
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBarView.layer.cornerRadius = 10
        optaionList.append("文章連結")
        optaionList.append("行程表圖檔")
        tableView.mr_registerCellWithNib(
            identifier: String(describing: SharedOptionTableViewCell.self), bundle: nil)
        tableView.reloadData()
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submit(_ sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let option4 = UIAlertAction(title: "在 Facebook 分享", style: .default) {(_) in
        }
        let option3 = UIAlertAction(title: "分享到 Messenger", style: .default) {(_) in
        }
        let option2 = UIAlertAction(title: "分享到 Line", style: .default) { (_) in
        }
        let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sheet.addAction(option4)
        sheet.addAction(option3)
        sheet.addAction(option2)
        sheet.addAction(option1)
        self.present(sheet, animated: true, completion: nil)
    }

}
extension SharedOptionViewController: UITableViewDelegate, UITableViewDataSource, SharedButtonDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optaionList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: SharedOptionTableViewCell.self),
            for: indexPath
        )
        guard let optionCell = cell as? SharedOptionTableViewCell else { return cell}
        optionCell.optionTitleLabel.text = optaionList[indexPath.row]
        optionCell.initCellItem()
        optionCell.delegate = self

        return optionCell

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func buttonDidTap(_ sender: SharedOptionTableViewCell, _ indexPath: IndexPath) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        if let tappedIndexPath = selectedElement[indexPath.row] {
            if tappedIndexPath == optaionList[indexPath.row] {
                selectedElement.removeValue(forKey: indexPath.row)
                return
            }
        }
        selectedElement.updateValue(optaionList[indexPath.row], forKey: indexPath.row)

    }
}
