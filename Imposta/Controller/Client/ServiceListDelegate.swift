//
//  ServiceListDelegate.swift
//  Imposta
//
//  Created by Ulxan Emiraslanov on 10/2/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import Foundation

protocol ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients)
    func serviceSelection(clientService: ClientServiceData)
}

extension ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {}
}
