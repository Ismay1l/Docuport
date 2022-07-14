//
//  Inbox.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 10/4/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Document: Decodable {
    var result: DocumentResult?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct DocumentResult: Decodable {
    var documents: [ResultDocument]?
    var totalCount: Int?
}

struct UploadedDocument: Decodable {
    var result: ResultDocument?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct ResultDocument: Decodable {
    var id: Int?
    var docNumber: String?
    var name: String?
    var client: DocumentClient?
    var service: DocumentService?
    var dueDate: String?
    var attachment: DocumentsAttachment?
    var status: String?
    var statusNote: String?
    var docType: String?
    var desc: String?
    var creationTime: String?
    var creatorUser: DocumentCreator?
    var relatedDocs: [DocumentRelatedDocs]?
    var tags: [DocumentTags]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case docNumber = "docNumber"
        case name = "name"
        case client = "client"
        case service = "service"
        case dueDate = "dueDate"
        case attachment = "attachment"
        case status = "status"
        case statusNote = "statusNote"
        case docType = "docType"
        case desc = "description"
        case creatorUser = "creatorUser"
        case relatedDocs = "relatedDocs"
        case creationTime = "creationTime"
        case tags = "tags"
    }
}

struct DocumentClient: Decodable {
    var id: Int?
    var name: String?
    var clientType: String?
}

struct DocumentTags: Decodable {
    var id: Int?
    var name: String?
    var color: String?
}

struct DocumentService: Decodable {
    var id: Int?
    var name: String?
    var department: DocumentServiceDepartment?
    var color: String?
}

struct DocumentServiceDepartment: Decodable {
    var id: Int?
    var name: String?
}

struct DocumentsAttachment: Decodable {
    var fileName: String?
    var genFileName: String?
    var fileSize: Int?
    var contentType: String?
}

struct DocumentCreator: Decodable {
    var id: Int?
    var fullName: String?
    var userName: String?
    var emailAddress: String?
}

struct DocumentRelatedDocs: Decodable {
    var id: Int?
    var docNumber: String?
    var name: String?
    var isSelected: Bool? //it's not comes from api. when user select related document, it will keep the selection status
}

struct DocumentStatus: Decodable {
    var result: String? //DocumentStatusResult?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct DocumentStatusResult: Decodable {
    
}

struct RelatedDocs: Decodable {
    var result: [DocumentRelatedDocs]?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}
