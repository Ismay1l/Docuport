//
//  Date+Extensions.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 01.03.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import Foundation

extension Date {
    var longDate: String {
        return DateFormatter.longDate.string(from: self)
    }
}
