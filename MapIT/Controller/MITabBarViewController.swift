//
//  MITabBarViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

private enum Tab {
    case lobby
    case record
    case mapping
    case notification
    case profile
    
    func controller() -> UIViewController {
        
        var controller: UIViewController
        
        switch self {
            
        case .lobby: controller = UIStoryboard.lobby.instantiateInitialViewController()!
            
        case .record: controller = UIStoryboard.record.instantiateInitialViewController()!
            
        case .mapping: controller =
            UIStoryboard.mapping.instantiateInitialViewController()!
            
        case .notification: controller = UIStoryboard.notification.instantiateInitialViewController()!
            
        case .profile: controller = UIStoryboard.profile.instantiateInitialViewController()!
            
            
        }
        
        controller.tabBarItem = tabBarItem()
        
    

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)


        
        return controller
    }
    
    func tabBarItem() -> UITabBarItem {
        
        switch self {
            
        case .lobby:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_Home_Unselected),
                selectedImage: UIImage.asset(.Icons_Home_Selected)
            )
            
        case .record:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_Book_Unselected),
                selectedImage: UIImage.asset(.Icons_Book_Selected)
            )
            
        case .mapping:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_Mapit_Unselected),
                selectedImage: UIImage.asset(.Icons_Mapit_Selected)
                
            )
            
        case .notification:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_Notification_Unselected),
                selectedImage: UIImage.asset(.Icons_Notification_Selected)
            )
        case .profile:
            return UITabBarItem(
                title: nil,
                image: UIImage.asset(.Icons_User_Unselected),
                selectedImage: UIImage.asset(.Icons_User_Selected)
            )
        }
    }
}


class STTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let tabs: [Tab] = [.lobby, .record, .mapping, .notification, .profile]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        delegate = self
        
    }
    
    

}
