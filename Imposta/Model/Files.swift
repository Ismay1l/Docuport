//
//  Files.swift
//  Imposta
//
//  Created by Shamkhal on 11/11/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

struct RetriveFiles: Encodable {
    let path: String?
    let date: String?
    let type: String?
    let user: String?
    let fileName: String?
    let genFileName: String?
    let serviceName: String?
    let accountName: String?
}
