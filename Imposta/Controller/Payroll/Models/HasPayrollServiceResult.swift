//
//  PayrollServiceResult.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 07.03.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

struct HasPayrollServiceResult: Decodable {
    var result: Bool?
    var success: Bool?
    var error: PayrollError?
}
