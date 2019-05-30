//
//  EditTravelCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/23.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import SwiftMessages

class EditTravelCViewController: UIViewController {
    var travel: Travel?
    @IBOutlet weak var travelNameTextField: UITextField!
    @IBOutlet weak var contentTextView: RSKPlaceholderTextView!

    @IBOutlet weak var toolBarView: UIView!
    var saveHandler: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBarView.layer.cornerRadius
            = 10.0
        contentTextView.placeholder = "旅程描述..."
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor
        guard let titleName = travel?.title,
            let content = travel?.content else {
                return
        }
        travelNameTextField.text = titleName
        contentTextView.text = content

    }

    @IBAction func storedEdit(_ sender: UIButton) {
        saveTravelContent()
        MiraMessage.updateSuccessfully()
        dismiss(animated: true, completion: nil)
    }

    func saveTravelContent() {
        self.travel?.title = ContentManager.handleNullContent(
            input: &self.travelNameTextField.text,
            nullCase: .noTitle)
        self.travel?.content = ContentManager.handleNullContent(
            input: &self.contentTextView.text,
            nullCase: .noDescription)
        CoreDataManager.shared.saveContext()
        saveHandler?()

    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
