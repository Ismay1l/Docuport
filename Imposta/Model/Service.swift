//
//  Service.swift
//  Imposta
//
//  Created by Shamkhal on 11/19/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Service: Decodable {
    var result: [ClientServiceResult]?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct ClientServiceResult: Decodable {
    var service: ClientServiceData?
    var employee: ClientEmployee?
}

struct ServiceAll: Decodable {
    var result: [ClientServiceData]?
}

struct ClientServices: Codable {
    let listIcon, gridIcon: String?
    let id, departmentID: Int?
    let displayName, departmentDisplayName, color: String?

    enum CodingKeys: String, CodingKey {
        case listIcon, gridIcon, id
        case departmentID = "departmentId"
        case displayName, departmentDisplayName, color
    }
}
