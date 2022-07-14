//
//  Encodable+extensions.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import UIKit

extension Encodable {
    func encodeBody() -> String {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        
        return ""
    }
}
