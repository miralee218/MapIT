//
//  ContentManager.swift
//  MapIT
//
//  Created by Mira on 2019/5/30.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

class ContentManager {
    
    enum NullCase: String {
        case noTitle = "未命名"
        case noDescription = "未編輯內容"
    }
    static func handleNullContent(input: inout String?, nullCase: NullCase) -> String? {
        switch nullCase {
        case .noTitle:
            guard input != "" else {
                input = NullCase.noTitle.rawValue
                return input
            }
            return input
        case .noDescription:
            guard input != "" else {
                input = NullCase.noDescription.rawValue
                return input
            }
            return input
            
        }
    }
}
