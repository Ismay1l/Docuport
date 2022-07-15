//
//  UserDefaultsHelper.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Foundation

class UserDefaultsHelper: NSObject {
    static var shared = UserDefaultsHelper()
    let userDefaults = UserDefaults(suiteName: "group.com.imposta")
    //USER EMAIL AND PASSWORD
    func setUserEmail(email: String, password: String) {
        userDefaults?.set(email, forKey: "userEmail")
        userDefaults?.set(password, forKey: "userPassword")
    }
    
    func getUserEmail() -> String {
        if let email = userDefaults?.string(forKey: "userEmail") {
            return email
        }
        return ""
    }
    
    //USER ID
    func setClientID(id: Int) {
        userDefaults?.set(id, forKey: "userId")
    }

    func getClientID() -> Int {
        return userDefaults?.integer(forKey: "userId") ?? -1
    }
    
    func setClientName(name: String) {
        userDefaults?.set(name, forKey: "clientName")
    }
    
    func getClientName() -> String {
        return userDefaults?.string(forKey: "clientName") ?? ""
    }
    
    func getUserPassword() -> String {
        if let password = userDefaults?.string(forKey: "userPassword") {
            return password
        }
        return ""
    }
    
    //USER TYPE
    func setUserType(user: String) {
        userDefaults?.set(user, forKey: "userType")
    }
    
    func getUserType() -> String {
        if let userType = userDefaults?.string(forKey: "userType") {
            return userType
        }
        return ""
    }
    
    //FULLNAME
    func setFullname(firstName: String, lastName: String) {
       userDefaults?.set("\(firstName) \(lastName)", forKey: "fullname")
    }
    
    func getFullname() -> String {
        if let fullname = userDefaults?.string(forKey: "fullname") {
            return fullname
        }
        
        return ""
    }
    
    //LEFT MENU SELECTION INDEX
    func setIndex(index: Int) {
        userDefaults?.set(index, forKey: "menuSelectionIndex")
    }
    
    func getIndex() -> Int {
        return userDefaults?.integer(forKey: "menuSelectionIndex") ?? -1
    }
    
    //TOKEN
    func setToken(token: String) {
        userDefaults?.set(token, forKey: "userToken")
    }
    
    func getToken() -> String {
        if let token = userDefaults?.string(forKey: "userToken") {
            return token
        }
        return ""
    }
    
    func setUserProfileImageUrl(url: String) {
        userDefaults?.set(url, forKey: "profileImage")
    }
    
    func getUserProfileImageUrl() -> String {
        if let profileImage = userDefaults?.string(forKey: "profileImage") {
            return profileImage
        }
        return ""
    }
    
    func setAuthToken(token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    func getAuthToken() -> String {
        if let authToken = UserDefaults.standard.string(forKey: "authToken") {
            return authToken
        }
        
        return ""
    }
    
    func removeAllObjects() {
        userDefaults?.removeObject(forKey: "userEmail")
        userDefaults?.removeObject(forKey: "userPassword")
        userDefaults?.removeObject(forKey: "userType")
        userDefaults?.removeObject(forKey: "fullname")
        userDefaults?.removeObject(forKey: "userToken")
        userDefaults?.removeObject(forKey: "menuSelectionIndex")
    }
}

extension UserDefaults {
    
    // MARK: - Save & Get Object
    static func saveObject<T: Codable>(_ object: T?, key: String) {
        if let object = object {
            
            if let data =
                try? JSONEncoder().encode(object) {
                let userDefaults = UserDefaults(suiteName: "group.com.imposta")
                userDefaults?.set(data, forKey: key)
                userDefaults?.synchronize()
            }
        }
    }
    
    static func getObject<T: Codable>(class: T?, key: String) -> T? {
         let userDefaults = UserDefaults(suiteName: "group.com.imposta")
        let decoder = JSONDecoder()
        if let data =
            userDefaults?.data(forKey: key),
            let object = try? decoder.decode(T.self, from: data) {
            return object
        } else {
            return nil
        }
    }
    
    // MARK: - Customer Info
    static var getAccountInfo: ClientAdvisor? {
        var accountInfo: ClientAdvisor? = nil
        if let object = getObject(class: accountInfo, key: "accountInfo") {
            accountInfo = object
        }
        return accountInfo
    }
    
    static func setAccountInfo(_ accountInfo: ClientAdvisor) {
        saveObject(accountInfo, key: "accountInfo")
    }
    
    static func setAccountInfoNew(_ accountInfo: AdvisorAccount) {
        saveObject(accountInfo, key: "accountInfo")
    }
    
}
