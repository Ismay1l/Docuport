//
//  PayrollInfos.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

struct PayrollInfos: Decodable {
    var result: PayrollInfoResult?
    var targetUrl: String?
    var success: Bool?
    var error: String?
    var unAuthorizedRequest: Bool?
}

struct PayrollInfoResult: Decodable {
    var payrollInfo: [PayrollInfo]?
    var totalCount: Int?
}

struct PayrollInfo: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var payRate: Double?
    var regularHours: Int?
    var overtime: Double?
    var salary: Double?
    var tip: Double?
    var commission: Double?
    var bonus: Double?
    var advancePaid: Double?
    var reimbursement: Double?
    var grossPay: Double?
    var payPeriodId: Int?
    var isSubmitted = true
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case middleName
        case payRate
        case regularHours
        case overtime
        case salary
        case tip
        case commission
        case bonus
        case advancePaid
        case reimbursement
        case grossPay
        case payPeriodId
    }
}

struct PayrollInfoParameter: Encodable {
    var payPeriodId: Int?
}
