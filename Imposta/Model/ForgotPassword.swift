//
//  ForgotPassword.swift
//  Imposta
//
//  Created by Shamkhal on 12/1/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

//struct ForgotPassword: Decodable {
//    var result: ForgotPasswordResult?
//    var targetUrl: String?
//    var success: Bool?
//    var error: Error?
//    var unAuthorizedRequest: Bool?
//    var __abp: Bool?
//}
//
//struct ForgotPasswordResult: Decodable {
//    var errorMessage: String?
//    var forgotPasswordResultType: Int?
//}

struct ForgotPassword: Codable {
    let resultType: Int?
    let errorMessage: String?
}
