//
//  AccessPhoto.swift
//  MapIT
//
//  Created by Mira on 2019/4/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import AVFoundation

class AccessPhoto {
    static func accessCamera(viewController: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        //button size
        let scaleView = imagePicker.view
        scaleView?.transform = CGAffineTransform(scaleX: 1, y: 1)

        viewController.present(imagePicker, animated: true, completion: nil)

    }
    static func accessLibrary(viewController: UIViewController) {
        let imagePicker = UIImagePickerController()

        imagePicker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.navigationBar.barTintColor = UIColor.EndYellow
        imagePicker.navigationBar.tintColor = .white
        imagePicker.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}
