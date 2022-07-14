//
//  Tags.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 13.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import Foundation

struct Tags: Decodable {
    var result: [Tag]?
}

struct Tag: Decodable {
    var id: Int?
    var name: String?
    var color: String?
    var listIcon: String?
    var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, color, listIcon
    }
}

struct TagsGroup: Decodable {
    var result: [TagGroup]?
}

struct TagGroup: Decodable {
    var id: Int?
    var name: String?
    var color: String?
    var tags: [Tag]?
    var isShown = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, color, tags
    }
    
    
}

struct TagsOfDocumentParams {
    var id: Int = 0
    var tags: [Int] = []
}

struct TagsParameter: Encodable {
    var id: Int?
}

struct TagsClientParameter: Encodable {
    var serviceId: Int?
    var clientId: Int?
}

struct TagsGroupParameter: Encodable {
    var serviceId: Int?
    var tagId: Int?
}

struct TagGroupElement: Codable {
    let listIcon: String?
    let id: Int?
    let displayName: String?
    let isActive: Bool?
    let servicesItDepends, tagGroupsItActivates: String?
    let tagGroup: TagGroupClass?
}

// MARK: - TagGroupClass
struct TagGroupClass: Codable {
    let id: Int?
    let name, displayName: String?
    let isMainTagGroup: Bool?
    let color: String?
    let ordinal: Int?
}
