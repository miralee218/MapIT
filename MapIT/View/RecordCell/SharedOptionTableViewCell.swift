//
//  SharedOptionTableViewCell.swift
//  MapIT
//
//  Created by Mira on 2019/4/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class SharedOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionTitleLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    weak var delegate: SharedButtonDelegate?
//    var delegate: CustomTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func optionAction(_ sender: UIButton) {
    }

    func initCellItem() {
        optionButton.addTarget(self, action: #selector(self.radioButtonTapped), for: .touchUpInside)
    }
    @objc func radioButtonTapped(_ radioButton: UIButton) {
        print("radio button tapped")
        let isSelected = !self.optionButton.isSelected
        self.optionButton.isSelected = isSelected
        if isSelected {
            deselectOtherButton()
        }
        guard let tableView = self.superview as? UITableView else { return }
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        delegate?.buttonDidTap(self, tappedCellIndexPath)
    }

    func deselectOtherButton() {
        guard let tableView = self.superview as? UITableView else { return }
        let tappedCellIndexPath = tableView.indexPath(for: self)!
        let indexPaths = tableView.indexPathsForVisibleRows
        for indexPath in indexPaths! {
            if indexPath.row != tappedCellIndexPath.row && indexPath.section == tappedCellIndexPath.section {
                guard let cell = tableView.cellForRow(
                    at: IndexPath(row: indexPath.row, section: indexPath.section))
                    as? SharedOptionTableViewCell else { return }
                cell.optionButton.isSelected = false
            }
        }
    }
}

protocol SharedButtonDelegate: AnyObject {
    func buttonDidTap(_ sender: SharedOptionTableViewCell, _ indexPath: IndexPath)
}
