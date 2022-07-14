//
//  HomePageServices.swift
//  Imposta
//
//  Created by Ismayil Ismayilov on 10.07.22.
//  Copyright © 2022 Imposta. All rights reserved.
//

//import Foundation
//
//// MARK: - HomePageSevice
//struct HomePageSevice: Codable {
//    let id, departmentID: Int?
//    let displayName, departmentDisplayName, color: String?
//    let isMyUploads: Bool? = false
//    let gridIcon, listIcon: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case departmentID = "departmentId"
//        case displayName, departmentDisplayName, color
//    }
//}

import Foundation

// MARK: - HomePageService
struct HomePageService: Codable {
    let listIcon, gridIcon: String?
    let id, departmentID: Int?
    let displayName, departmentDisplayName, color: String?
    let isMyUploads: Bool? = false

    enum CodingKeys: String, CodingKey {
        case listIcon, gridIcon, id
        case departmentID = "departmentId"
        case displayName, departmentDisplayName, color
    }
}

