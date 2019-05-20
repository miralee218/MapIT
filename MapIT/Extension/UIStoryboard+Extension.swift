//
//  UIStoryboard+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

import UIKit

private struct StoryboardCategory {

    static let main = "Main"

    static let lobby = "Lobby"

    static let record = "Record"

    static let mapping = "Mapping"

    static let notification = "Notification"

    static let profile = "Profile"

}

extension UIStoryboard {

    static var main: UIStoryboard { return stStoryboard(name: StoryboardCategory.main) }

    static var lobby: UIStoryboard { return stStoryboard(name: StoryboardCategory.lobby) }

    static var record: UIStoryboard { return stStoryboard(name:
        StoryboardCategory.record)
    }

    static var mapping: UIStoryboard { return stStoryboard(name:
        StoryboardCategory.mapping)

    }

    static var notification: UIStoryboard { return stStoryboard(name: StoryboardCategory.notification)

    }

    static var profile: UIStoryboard { return stStoryboard(name: StoryboardCategory.profile) }

    private static func stStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
