//
//  UserAuth.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 10/4/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct Auth: Codable {
    let resultType: Int?
    let errorMessage: String?
    let user: User?
}

struct User: Codable {
    let id: Int?
    let firstName, lastName, username, emailAddress: String?
    let roles, permissions: [String]?
    let jwtToken: JwtToken?
}

struct JwtToken: Codable {
    let accessToken, refreshToken: String?
}



struct AuthResult: Decodable {
    var loginResultType: Int?
    var errorMessage: String?
    var accessToken: String?
    var user: AuthUser?
}

struct AuthUser: Decodable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var userName: String?
    var emailAddress: String?
    var phoneNumber: String?
    var internalPhoneNumber: String?
    var department: String?
    var inviter: String?
    var supervisor: String?
    var role: String?
    var profilePictureUrl: String?
    var profilePicture: AuthUserProfilePicture?
}

struct UserProfile: Decodable {
    var result: AuthUser?
    var targetUrl: String?
    var success: Bool?
    var error: Error?
    var unAuthorizedRequest: Bool?
    var __abp: Bool?
}

struct AuthUserProfilePicture: Decodable {
    var fileName: String?
    var genFileName: String?
    var fileSize: Int?
    var contentType: String?
}

struct ErrorMessage: Decodable {
    let resultType: Int?
    let errorMessage: String?
    let user: User?
}
