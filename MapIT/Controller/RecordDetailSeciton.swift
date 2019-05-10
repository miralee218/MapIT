//
//  RecordDetailSeciton.swift
//  MapIT
//
//  Created by Mira on 2019/5/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

enum RecordDetailSeciton: Int, CaseIterable {
    case map = 0, description, route
    func identifier() -> String {

        switch self {

        case .map: return String(describing: MapTableViewCell.self)

        case .description: return String(describing: RecordDescriptionTableViewCell.self)

        case .route: return String(describing: RouteTableViewCell.self)

        }
    }
    
}
