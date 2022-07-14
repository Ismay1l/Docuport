//
//  Employee.swift
//  Imposta
//
//  Created by Shamkhal on 12/13/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct ServiceEmployee: Decodable {
    var result: [ClientEmployee]?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}
