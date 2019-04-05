//
//  UIImage+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

enum ImageAsset: String {
    
    // Profile tab - Tab
    case Icons_Home_Unselected
    case Icons_Home_Selected
    case Icons_Notification_Unselected
    case Icons_Notification_Selected
    case Icons_Mapping_Selected
    case Icons_Mapping_Unselected
    case Icons_Book_Unselected
    case Icons_Book_Selected
    case Icons_User_Unselected
    case Icons_User_Selected
    
    case Icons_Calendar_Selected
    case Icons_Calendar_Unselected
    case Icons_Search_Selected
    case Icons_Search_Unselected

}



extension UIImage {
    
    static func asset(_ asset: ImageAsset) -> UIImage? {
        
        return UIImage(named: asset.rawValue)
    }
}
