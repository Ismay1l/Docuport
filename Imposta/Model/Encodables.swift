//
//  Encodables.swift
//  Imposta
//
//  Created by Shamkhal on 12/3/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct DocumentJSON: Encodable {
    var limit: Int?
    var offset: Int?
}

struct DocumentStatusParam: Encodable {
    var id: Int?
    var status: Int?
}

struct InvitationParam: Encodable {
    var recipient: String?
    var clientId: Int?
}

struct ProfileUpdateParam: Encodable {
    var name: String?
    var surname: String?
    var phoneNumber: String?
    var internalPhoneNumber: String?
}

struct DocsRelatedParam: Encodable {
    var id: Int?
    var relatedDocs: [Int]?
}

struct DocumentDescriptionParam: Encodable {
    var id: Int?
    var description: String?
}

struct ClientProfileParam: Encodable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var socialSecurityNumber: String?
    var birthDate: String?
    var phoneNumber: String?
    var advisorUserId: Int?
//    var profileImage: String?
    var services: [ClientParofileServices]?
}

struct ClientBusinessProfileParam: Encodable {
    var id: Int?
    var name: String?
    var taxpayerIdentificationNumber: String?
    var phoneNumber: String?
    var advisorUserId: Int?
//    var profileImage: String?
    var services: [ClientParofileServices]?
}

struct ClientParofileServices: Encodable {
    var serviceId: Int?
    var employeeUserId: Int?
}

struct DocumentClientParam: Encodable {
    var id: Int?
    var clientId: Int?
}

struct DocumentClientServiceParam: Encodable {
    var id: Int?
    var serviceId: Int?
}

struct DocumentTagParameter: Encodable {
    var id: Int?
    var tags: [Int]?
}
