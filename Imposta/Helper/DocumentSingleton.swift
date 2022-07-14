//
//  DocumentSingleton.swift
//  Imposta
//
//  Created by Shamkhal on 12/30/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

class DocumentSingleton: NSObject {
    static let shared = DocumentSingleton()
    
    var isFileIploaded = false
    var docID: Int?
    var clientId: Int?
    var serviceId: Int?
    var documentClientId: Int?
}
