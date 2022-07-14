//
//  PayrollResult.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 28.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

struct PayrollResult: Decodable {
    var result: PayrollInfo?
    var success: Bool?
    var error: PayrollError?
}

struct PayrollError: Decodable {
    var code: Int?
    var message: String?
}
