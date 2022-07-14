//
//  Enum.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

enum ApiRequirements: String {
    case auth = "Auth"
    case userAgent = "User-Agent"
    case acceptLang = "Accept-Language"
    case contentType = "Content-Type"
    case contentTypeValue = "application/json"
//    case apiUrl = "https://app.imposta.com"
    case apiUrl = "https://dev.docuport.app"
}

enum ClientType: String {
    case Personal
    case Business
}

enum UserType: String {
    case Advisor
    case Client
    case Employee
}

enum SerachType {
    case clients
    case documents
    case downloads
    case invitations
    case accounts
}

enum DocumentType: String {
    case inbox
    case outbox
}

enum PickerType {
    case client
    case service
    case dueDate
    case createdDate
    case relatedDocs
}

enum InvitationStatus: Int {
    case sent = 1
    case received = 2
    case registered = 3
}

enum iPhoneScreenHeight: CGFloat {
    case iPhone4 = 480  //iPhone 4, iPhone 4S
    case iPhone5 = 568 //iPhone 5, iPhone 5S, iPhone SE
    case iPhone6 = 667 //iPhone 6, iPhone 7, iPhone 8
    case iPhoneX = 2436 //iPhone X
    case iPhonePlus = 736 //iPhone Plus
    case iPhone11Pro = 812 //iPone 11 Pro
    case iPhone11 = 896 //iPhone 11, iPhone 11 Pro Max
}

enum DocumentStatusValue: String {
    case draft = "Draft"
    case open = "Open"
    case inProgress = "InProgress"
    case done = "Done"
}

enum InvitationType: String {
    case all = "All"
    case sent = "Sent"
    case received = "Received"
    case registered = "Registered"
}

struct Header {
    static let shared = Header()
    var headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaultsHelper.shared.getToken())", "Content-Type": "application/json"]
    func headerWithToken() -> HTTPHeaders {
        return ["Authorization": "Bearer \(UserDefaultsHelper.shared.getToken())", "Content-Type": "Application/json"]
    }
}

struct GetUserType {
    static let user = GetUserType()
    
    func isUserAdvisor() -> Bool {
        if UserDefaultsHelper.shared.getUserType() == UserType.Advisor.rawValue {
            return true
        }
        return false
    }
    
    func isUserClient() -> Bool {
        if UserDefaultsHelper.shared.getUserType() == UserType.Client.rawValue {
            return true
        }
        return false
    }
    
    func isUseEmployeeAdvisor() -> Bool {
        if UserDefaultsHelper.shared.getUserType() == UserType.Employee.rawValue {
            return true
        }
        return false
    }
}

struct DeviceType {
    static let shared = DeviceType()
    
    func isIphone4() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhone4.rawValue {
            return true
        }
        return false
    }
    
    func isIphone5() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhone5.rawValue {
            return true
        }
        return false
    }
    
    func isIphone6() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhone6.rawValue {
            return true
        }
        return false
    }
    
    func isIphoneX() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhoneX.rawValue {
            return true
        }
        return false
    }
    
    func isIphonePlus() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhonePlus.rawValue {
            return true
        }
        return false
    }
    
    func isIPhone11() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhone11.rawValue {
            return true
        }
        return false
    }
    
    func isIPhone11Pro() -> Bool {
        if UIScreen.main.bounds.height == iPhoneScreenHeight.iPhone11Pro.rawValue {
            return true
        }
        return false
    }
}
public enum UpdatesResult {
    case available(Update)
    case none
}
public struct Update {
   public let newVersionString: String
   public let releaseNotes: String?
   public let shouldNotify: Bool
}







