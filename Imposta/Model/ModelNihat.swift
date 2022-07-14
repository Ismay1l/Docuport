//
//  ModelNihat.swift
//  Imposta
//
//  Created by Nihad Ismayilov on 08.07.22.
//  Copyright © 2022 Imposta. All rights reserved.
//

import Foundation
import UIKit

struct ClientListParameter: Codable {
    let ClientType: type?
    let FullName: String?
    let SocialSecurityNumber: String?
    let TaxpayerIdentificationNumber: String?
    let PhoneNumber: String?
    let EmailAddress: String?
    let City: String?
    let StateId: Int?
    let ServiceId: Int?
    let AdvisorUserId: Int?
    let OwnerOrCollaboratorUserId: Int?
    let IsActive: Bool?
    let SortedBy: String?
    let SortedDesc: Bool?
    let Offset: Int?
    let Limit: Int?
}

enum type: Int, Codable {
    case type1 = 1
    case type2 = 2
}



// MARK: - MyUploadsResponse
struct MyUploadsResponse: Codable {
    let totalCount: Int?
    let items: [Item1]?
}

struct Item1: Codable {
    let id: Int?
    let displayName: String?
    let client: String?
    let status: Int?
    let creatorUser: String?
    let creationTime: String?
    let numberOfComments: Int?
    let service: Service1?
    let attachment: Attachment1?
    let tags: [Tag1]?
}

struct Attachment1: Codable {
    let id: Int?
    let fileName: String?
    let genFileName: String?
    let fileSize: Int?
    let contentType: String?
}

struct Service1: Codable {
    let id: Int?
    let name, displayName: String?
    let departmentID: Int?
    let departmentDisplayName: String?
    let isActive: Bool?
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, displayName
        case departmentID = "departmentId"
        case departmentDisplayName, isActive, color
    }
}

struct Tag1: Codable {
    let id: Int?
    let displayName: String?
    let isActive: Bool?
    let servicesItDepends, tagGroupsItActivates: String?
    let tagGroup: TagGroup1?
}

struct TagGroup1: Codable {
    let id: Int?
    let name, displayName: String?
    let isMainTagGroup: Bool?
    let color: String?
    let ordinal: Int?
}

// MARK: - MyUploadParameter
struct MyUploadParameter: Codable {
    let Description: String?
    let DisplayName: String?
    let ClientId: Int?
    let UploadedOnBehalfOfClient: Bool?
    let ServiceId: Int?
    let Tags: Int?
    let Files: String?
}
