//
//  DateFormatter+extensions.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 01.03.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import Foundation

class LocaleAutoupdatingDateFormatter: DateFormatter {
    override init() {
        super.init()
        
        updateLocale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateLocale()
    }
    
    @objc func updateLocale() {
        locale = .current
    }
}

extension DateFormatter {
    static let payrollDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    static let longDate: LocaleAutoupdatingDateFormatter = {
        let formatter = LocaleAutoupdatingDateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}
