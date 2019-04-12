//
//  SignInViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signContainerView: UIView!
    @IBOutlet weak var loginContainerView: UIView!
    private enum SignType: Int {
        case logIn = 0
        case signUp = 1
    }
    private struct Segue {
        static let signUp = "SegueSignUp"
        static let logIn = "SegueLogIn"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func viewSignUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.loginButton.setImage(UIImage(named: ImageAsset.Image_Login_Unselected.rawValue), for: .normal)
            self.signUpButton.setImage(UIImage(named: ImageAsset.Image_SignUp_Selected.rawValue), for: .normal)
            self.loginContainerView.alpha = 0
            self.signContainerView.alpha = 1
        })
    }
    @IBAction func viewLogIn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.loginButton.setImage(UIImage(named: ImageAsset.Image_Login_Selected.rawValue), for: .normal)
            self.signUpButton.setImage(UIImage(named: ImageAsset.Image_SignUp_Unselected.rawValue), for: .normal)
            self.loginContainerView.alpha = 1
            self.signContainerView.alpha = 0
        })

    }
}
