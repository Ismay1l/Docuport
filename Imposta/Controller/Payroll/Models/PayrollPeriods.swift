//
//  PayrollPeriodsResponse.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

struct PayrollPeriods: Decodable {
    var result: [PayrollPeriod]?
    var targetUrl: String?
    var success: Bool?
    var error: String?
    var unAuthorizedRequest: Bool?
}

struct PayrollPeriod: Decodable {
    var id: Int?
    var clientId: Int?
    var payPeriodStartDate: String?
    var payPeriodEndDate: String?
    var payDate: String?
    var inputColumns: [PayrollInput]?
    var payFrequency: String?
    var isSubmitted: Bool?
    var comment: String?
}

enum PayrollInput: String, Codable {
    case payRate = "PayRate"
    case regularHours = "RegularHours"
    case overtime = "Overtime"
    case salary = "Salary"
    case tip = "Tip"
    case commission = "Commission"
    case bonus = "Bonus"
    case advancePaid = "AdvancePaid"
    case reimbursement = "Reimbursement"
}
