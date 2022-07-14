//
//  ClientServices.swift
//  Imposta
//
//  Created by Ismayil Ismayilov on 11.07.22.
//  Copyright © 2022 Imposta. All rights reserved.
//

import Foundation

// MARK: - ClientSevice
struct ClientServices2: Codable {
    let listIcon, gridIcon: String?
    let id, departmentID: Int?
    let displayName, departmentDisplayName, color: String?

    enum CodingKeys: String, CodingKey {
        case listIcon, gridIcon, id
        case departmentID = "departmentId"
        case displayName, departmentDisplayName, color
    }
}
