//
//  Search.swift
//  Imposta
//
//  Created by Shamkhal on 11/21/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct DocumentSearch: Decodable {
    var name: String?
    var clientId: Int?
    var serviceId: Int?
    var creationTime: String?
    var status: Int?
    var offset: Int?
    var limit: Int?
    var relatedDocId: Int?
}

struct ClientSearch: Decodable {
    var name: String?
    var tin: Int?
    var ssn: Int?
    var serviceId: Int?
    var clientType: Int?
}
