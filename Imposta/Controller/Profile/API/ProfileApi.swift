//
//  ProfileApi.swift
//  Imposta
//
//  Created by Ismayil Ismayilov on 16.06.22.
//  Copyright © 2022 Imposta. All rights reserved.
//

import Foundation
import Alamofire
import UIKit


class ProfileApi: NSObject {
    static let shared = ProfileApi()
    private override init() {}
    
    var header1: HTTPHeaders {
        
        var header: HTTPHeaders = ["Content-Type": "application/json"]
        
        if let accessToken = UserDefaultsHelper.shared.getToken() as? String {
            header["Authorization"] = "Bearer \(accessToken)"
        }
        return header
    }
    
    var header2: HTTPHeaders {
        
        var header: HTTPHeaders = ["Content-Type": "application/json"]
        
        if let refreshToken = UserDefaultsHelper.shared.getAuthToken() as? String {
            header["Authorization"] = "Bearer \(refreshToken)"
        }
        return header
    }
    
    
    private let baseURL = "https://dev.docuport.app"
}



extension ProfileApi {
    // MARK: - Update Profile - Completed
    func updateProfile(completion: @escaping (ProfileModel) -> Void) {
        let url = baseURL + "/api/v1/identity/users/me"
        let innerHeader = self.header1
        let innerHeader2 = self.header2
        print(innerHeader)
        print(innerHeader2)
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: innerHeader
        ).responseData { response in
                guard let data = response.data else { return }
            print("UpdateProfile data: \(data)")
            do {
                let decoder = try JSONDecoder().decode(ProfileModel.self, from: data)
                completion(decoder)
                print("data: \(decoder)")
            }catch {
                print(error)
            }
        }
    }
    
    // MARK: - ChangeCurrentAccount - not completed - request returns 200 but empty response - needs to be implemented
        func changeCurrentAccount(clientId: Int, success: @escaping(String) -> Void, failure: @escaping(String) -> Void) {
             let url = baseURL + "/api/v1/document/users/me/clients/current"
            let innerHeader = self.header1
            
            let params: Parameters = ["clientId": clientId]
            
            AF.request(url,
                       method: .put,
                       parameters: params,
                       encoding: JSONEncoding.default,
                       headers: innerHeader).responseData { response in
                guard let data = response.data else {
                    print("data is nil in changeCurrentAccount")
                    return }
                print("changeCurrentAccount data: \(data)")
                do {
                    let decoder = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
    //                let decoder = try JSONDecoder().decode(String.self, from: data)
                    print("jsonSerialization: \(decoder)")
    //                success(decoder)
                } catch {
                    failure("error occured during decoding in changeCurrentAccount")
                }
            }
        }
    
    //MARK: - SendInvitation - needs to be implemented somewhere in app
        func sendInvitation(email: String, success: @escaping(SendInvitationResponse) -> Void, failure: @escaping(String) -> Void) {
            let url = baseURL + "/api/v1/document/invitations/send"
            let innerHeader = self.header1
            
            let params: Parameters = ["recipientEmailAddress": email]
            
            AF.request(url,
                       method: .post,
                       parameters: params,
                       encoding: JSONEncoding.default,
                       headers: innerHeader).responseData { response in
                guard let data = response.data else { return }
                print("sendInvitation data: \(data)")
                do {
    //                let decoder = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                    let decoder = try JSONDecoder().decode(SendInvitationResponse.self, from: data)
    //                print("jsonSerialization: \(decoder)")
                    success(decoder)
                } catch {
                    failure("error occured during decoding in SendInvitation")
                }
            }
        }
    
    //MARK: - ClientsList - needs to be implemented somewhere in app
        func clientsList(success: @escaping(ClientListParameter) -> Void, failure: @escaping(String) -> Void) {
            let url = baseURL + "/api/v1/document/clients"
            let innerHeader = self.header1
            
            AF.request(url,
                       method: .get,
                       encoding: JSONEncoding.default,
                       headers: innerHeader).responseData { reponse in
                guard let data = reponse.data else {
                    print("data is nil in clientList")
                    return }
                
                do {
                    let decoder = try JSONDecoder().decode(ClientListParameter.self, from: data)
                    success(decoder)
                } catch {
                    failure("error occure during decoding in Client List")
                }
            }
        }
    
    //MARK: - LoginProfile - completed
    func loginProfile(tenancyName: String, usernameOrEmail: String, password: String, success: @escaping(Auth) -> Void, failure: @escaping(String) -> Void) {
        let params: Parameters = ["tenancyName": "string", "usernameOrEmailAddress": usernameOrEmail, "password": password]
        
        let url = baseURL + "/api/v1/authentication/account/authenticate"
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default
        ).responseData { response in
                guard let data = response.data else { return }
                print("LoginProfile data: \(data)")
                do {
                    let auth = try JSONDecoder().decode(Auth.self, from: data)
                    
                    if auth.resultType == 1 {
                        UserDefaultsHelper.shared.setClientID(id: auth.user?.id ?? 0)
                        UserDefaultsHelper.shared.setUserEmail(email: usernameOrEmail, password: password)
                        UserDefaultsHelper.shared.setUserType(user: auth.user?.roles?.first ?? "")
                        print("UserType: \(UserDefaultsHelper.shared.getUserType())")
                        UserDefaultsHelper.shared.setToken(token: auth.user?.jwtToken?.accessToken ?? "")
    //                        UserDefaultsHelper.shared.setUserProfileImageUrl(url: auth.user?.profilePictureUrl ?? "")
                        UserDefaultsHelper.shared.setAuthToken(token: auth.user?.jwtToken?.refreshToken ?? "")
                        UserDefaultsHelper.shared.setFullname(firstName: auth.user?.firstName ?? "", lastName: auth.user?.lastName ?? "")
                        success(auth)
                    }
                    else {
                        failure(auth.errorMessage ?? "")
                    }
                } catch let err {
                    print("error: \(String(describing: err))")
                    failure("")
                }
        }
    }
    
    //MARK: - LogoutProfile - not completed
    func logoutProfile(completion: @escaping (String) -> Void) {
            let innerHeader = self.header1
                do {
                    AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/authentication/account/logout",
                        method: .post,
                        encoding: JSONEncoding.default,
                               headers: innerHeader)
                    .responseData { response in
                            guard let data = response.data else {
                                print("açaşsahib91@gmailş")
                                return
                            }
                    }
                } catch {
                    print(error)
                }
        }
    
    //MARK: - GetProfilePicture - completed
    func getProfilePicture(completion: @escaping (Data) -> Void) {
        let url = baseURL + "/api/v1/identity/users/me/profile-picture"
        let innerHeader = self.header1
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: innerHeader).responseData { response in
            print("data picture: \(response.data)")
            guard let data = response.data else { return }
            completion(data)
        }
    }
    
    //MARK: - GET MyUploads - needs to be implemented somwhere in app
    func myUploads(success: @escaping(MyUploadsResponse) -> Void, failure: @escaping(String) -> Void) {
        let url = baseURL + "/api/v1/document/documents/my-upload?offset=0&limit=10"
        let innerHeader = self.header1
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: innerHeader).responseData { response in
            guard let data = response.data else {
                print("no data receivedin myUploads")
                return
            }
            do {
                let decoder = try JSONDecoder().decode(MyUploadsResponse.self, from: data)
                success(decoder)
            } catch {
                failure("Error occured while decoding myUploads")
            }
        }
    }
    
    //MARK: - ReceivedDocs need to be implemented somewhere in app
        func receivedDocs(success: @escaping(MyUploadsResponse) -> Void, failure: @escaping(String) -> Void) {
            let url = baseURL + "/api/v1/document/documents/received"
            let innerHeader = self.header1
            
            AF.request(url,
                       method: .get,
                       encoding: JSONEncoding.default,
                       headers: innerHeader).responseData { response in
                guard let data = response.data else {
                    print("no data received")
                    return
                }
                
                do {
                    let decoder = try JSONDecoder().decode(MyUploadsResponse.self, from: data)
                    success(decoder)
                } catch {
                    failure("error occured while decoding in ReceivedDocs")
                }
            }
        }
    
    // MARK: - MyDocsPreview - request result came as picture (data) - needs to be implemented, check request response on android
    func MyDocsPreview(with id: Int, success: @escaping(String) -> Void, failure: @escaping(String) -> Void) {
        let url = baseURL + "/api/v1/document/documents/\(id)/preview"
        let innerHeader = self.header1
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: innerHeader).responseData { response in
            guard let data = response.data else {
                print("data is nil in MyDocsPreview")
                return
            }
            
            do {
                let decoder = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                print("jsonSerialization: \(decoder)")
                //                let decoder = try JSONDecoder().decode(String.self, from: data)
                //                success(decoder)
            } catch {
                failure("error occured during decoding in MyDocsPreview")
            }
        }
    }
    
    // MARK: - POST MyUploads haven't completed - needs to be implemented
        func myUploadsPost(with parameters: MyUploadParameter, success: @escaping(MyUploadsResponse) -> Void, failure: @escaping(String) -> Void) {
            let url = baseURL + "/api/v1/document/documents/my-upload"
            let innerHeader = self.header1
            
            do {
                let data = try JSONEncoder().encode(parameters)
                guard let params = try JSONSerialization.jsonObject(with: data, options: []) as? Parameters else { fatalError() }
                
                AF.request(url,
                           method: .post,
                           parameters: params,
                           encoding: JSONEncoding.default,
                           headers: innerHeader).responseData { response in
                    guard let data = response.data else {
                        print("data is nil in myUploadsPost")
                        return }
                }
            } catch {
                print(error)
            }
        }
    
    //MARK: getDocTypeTagsForClientNew function response is nil so nothing happens
}
