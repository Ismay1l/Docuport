//
//  File.swift
//  Imposta
//
//  Created by Ulxan Emiraslanov on 10/3/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import Foundation

protocol DocumentRelatedDelegate {
    func showDesc(active: Bool)
    func showTags()
}

extension DocumentRelatedDelegate {
    func showTags() {}
}
