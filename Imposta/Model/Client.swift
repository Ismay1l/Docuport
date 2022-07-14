//
//  Client.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 10/24/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Client: Decodable {
    var result: ClientResult?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct ClientDetail: Decodable {
    var result: ResultClients?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct ClientResult: Decodable {
    var totalCount: Int?
    var clients: [ResultClients]?
}

struct ResultClients: Decodable {
    var id: Int?
    var name: String? //business
    var tradeName: String? //business
    var taxpayerIdentificationNumber: String? //business
    var website: String? //business
    var emailAddress: String?
    var firstName: String?
    var lastName: String?
    var fullClientName: String?
    var socialSecurityNumber: String?
    var birthDate: String?
    var clientType: String?
    var phoneNumber: String?
    var fullAddress: String?
    var advisor: ClientAdvisor?
    var creatorUser: ClientAdvisor?
    var services: [ClientServiceResult]?
    var isSelected: Bool?
    var profileImage: AuthUserProfilePicture?
    var profileImageUrl: String?
}

struct ClientAdvisor: Codable {
    var id: Int?
    var fullName: String?
    var userName: String?
    var emailAddress: String?
    var isSelected: Bool?
    var phoneNumber: String?
}

struct ClientService: Decodable {
    var service: ClientServiceData?
}

struct ClientServiceData: Decodable {
    var id: Int?
    var name: String?
    var department: ClientServiceDepartment?
    var isSelected: Bool?
    var listIcon: String?
    var gridIcon: String?
    var color: String?
    var isMyUploads: Bool?
}

struct ClientServiceDepartment: Decodable {
    var id: Int?
    var name: String?
}

struct ClientEmployee: Decodable {
    var id: Int?
    var fullName: String?
    var userName: String?
    var emailAddress: String?
    var isSelected: Bool?
}

//import Foundation

// MARK: - AccountOnHeaderElement
struct AccountOnHeaderElement: Codable {
    let id: Int?
    let name: String?
    let clientType: Int?
    let advisor: AdvisorAccount?
}

// MARK: - Advisor
struct AdvisorAccount: Codable {
    let id: Int?
    let firstName, lastName, fullName, emailAddress: String?
    let phoneNumber: String?
}


// MARK: - ClientList
struct ClientList: Codable {
    let totalCount: Int?
    let items: [Item]?
}

// MARK: - Item
struct Item: Codable {
    let id, clientType: Int?
    let name, firstName, lastName: String?
    let fullName, emailAddress: String?
    let phoneNumber: String?
    let owner: String?
    let advisor: String?
    let creationTime: String?
    let services: [String]?
    let isActive: Bool?
}
