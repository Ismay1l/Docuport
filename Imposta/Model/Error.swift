//
//  Error.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 10/4/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Error: Decodable {
    var code: Int?
    var message: String?
    var details: String?
    var validationErrors: String?
}

