//
//  ShareTravelContent.swift
//  MapIT
//
//  Created by Mira on 2019/5/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import UIKit

class ShareTravelContent {
    static func allContent(tableView: UITableView?, vc: UIViewController?) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: (tableView?.contentSize.width)!,
                                                      height: (tableView?.contentSize.height)!),
                                               false,
                                               0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        let previousFrame = tableView?.frame
        tableView?.frame = CGRect(x: (tableView?.frame.origin.x)!,
                                  y: (tableView?.frame.origin.y)!,
                                  width: (tableView?.contentSize.width)!,
                                  height: (tableView?.contentSize.height)!)
        tableView?.layer.render(in: context!)
        tableView?.frame = previousFrame!
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        vc?.present(activityViewController, animated: true, completion: nil)
    }
}
