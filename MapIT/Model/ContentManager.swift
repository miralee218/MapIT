//
//  ContentManager.swift
//  MapIT
//
//  Created by Mira on 2019/5/30.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

class ContentManager {
    
    enum ContentMassege: String {
        case noTitle = "未命名"
        case noDescription = "未編輯內容"
    }
    static func handleContent(input: inout String, case: ContentMassege) -> String? {
        guard input != "" else {
            input = ContentMassege.noTitle.rawValue
            return input
        }
        return input
    }
}

