//
//  ClientUploadDelegate.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 22.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

protocol ClientUploadDelegate: AnyObject {
    func serviceSelection(clientService: ClientServiceData)
    func documentUploaded()
}
