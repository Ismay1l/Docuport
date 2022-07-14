//
//  Account.swift
//  Imposta
//
//  Created by Shamkhal on 12/14/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Account: Decodable {
    var result: [ResultClients]?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}
