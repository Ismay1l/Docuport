//
//  Invitations.swift
//  Imposta
//
//  Created by Shamkhal on 12/15/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Invitation: Decodable {
    var result: InvitationResult?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct InvitationResult: Decodable {
    var invitations: [Invitations]?
    var totalCount: Int?
}

struct Invitations: Decodable {
    var id: Int?
    var recipient: String?
    var client: InvitationClient?
    var status: String?
    var creationTime: String?
}

struct InvitationClient: Decodable {
    var id: Int?
    var name: String?
    var clientType: String?
}
