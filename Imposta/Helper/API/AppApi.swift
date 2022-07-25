//
//  AppApi.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Alamofire
import AlamofireImage

class AppApi: NSObject {
    static let shared = AppApi()
    private override init() {}
    
    var header: HTTPHeaders {
        
        var header: HTTPHeaders = ["Content-Type": "application/json"]
        
        if let accessToken = UserDefaultsHelper.shared.getToken() as? String {
            header["Authorization"] = "Bearer \(accessToken)"
        }
        return header
    }
    
    private let baseURL = "https://dev.docuport.app"
    
}
   
extension AppApi {
    
//    func login(tenancyName: String, usernameOrEmail: String, password: String, success: @escaping(Auth) -> Void, failure: @escaping(String) -> Void) {
//        let params: Parameters = ["tenancyName": "string", "usernameOrEmailAddress": usernameOrEmail, "password": password]
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json"
//        ]
//        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/authentication/account/authenticate",
//                   method: .post,
//                   parameters: params,
//                   encoding: JSONEncoding.default,
//                   headers: headers
//        ).responseData { response in
//                guard let data = response.data else {
////                    let ans = try JSONDecoder().decode(ErrorMessage.self, from: response.data)
//                    return
//
//                }
//
//                print("data: \(data)")
//                do {
//                    let auth = try JSONDecoder().decode(Auth.self, from: data)
//
//                    if auth.resultType == 1 {
//                        UserDefaultsHelper.shared.setClientID(id: auth.user?.id ?? 0)
//                        UserDefaultsHelper.shared.setUserEmail(email: usernameOrEmail, password: password)
//                        UserDefaultsHelper.shared.setUserType(user: auth.user?.roles ?? [""])
//                        UserDefaultsHelper.shared.setToken(token: auth.user?.jwtToken?.accessToken ?? "")
////                        UserDefaultsHelper.shared.setUserProfileImageUrl(url: auth.user?.profilePictureUrl ?? "")
//                        UserDefaultsHelper.shared.setAuthToken(token: auth.user?.jwtToken?.accessToken ?? "")
//                        UserDefaultsHelper.shared.setFullname(firstName: auth.user?.firstName ?? "", lastName: auth.user?.lastName ?? "")
//                        success(auth)
//                        print("Success: \(auth)")
//                    }
////                    else if auth.resultType == 2 {
////                        failure(auth.errorMessage ?? "")
////                    }
//                    else {
//
//                        failure(auth.errorMessage ?? "")
//                    }
//                } catch let err {
//
//
//                    print("error: \(String(describing: err))")
//                    failure("")
//                }
//
////            if let error = response.error {
////                let ans = try JSONDecoder().decode(ErrorMessage.self, from: error)
////            }
//        }
//    }
    
    func loginWithUserDefaults(success: @escaping() -> Void, failure: @escaping() -> Void) {
        ProfileApi.shared.loginProfile(tenancyName: "", usernameOrEmail: UserDefaultsHelper.shared.getUserEmail(), password: UserDefaultsHelper.shared.getUserPassword(), success: { _ in
            success()
        }, failure: { _ in
            failure()
        })
    }
    
    /*func forgotPassword(email: String, success: @escaping() -> Void, failure: @escaping(Int, String) -> Void) {
        let params: Parameters = ["email": email]
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/account/password/reset",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    //
                } catch let err {
                    print("error: \(err)")
                    //print("\(String(data: data, encoding: .utf8))")
                    failure(1000, "")
                }
        }
    }*/
    
//    func forgotPassword(email: String, success: @escaping() -> Void, failure: @escaping (String) -> Void) {
//        let params: Parameters = ["email": email]
//        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/account/password/reset",
//            method: .post,
//            parameters: params).responseData { response in
//                guard let data = response.data else { return }
//
//                do {
//                    let forgotPassword = try JSONDecoder().decode(ForgotPassword.self, from: data)
//                    let isSuccess = forgotPassword.success ?? false
//
//                    if isSuccess {
//                        success()
//                    } else {
//                        let errorMessage = forgotPassword.result?.errorMessage ?? ""
//                        failure(errorMessage)
//                    }
//                } catch let err {
//                    print("error: \(err)")
//                    failure("Data not found")
//                }
//        }
//    }
    
    func forgotPassword(email: String, success: @escaping() -> Void, failure: @escaping (String) -> Void) {
        let params =  ["emailAddress": email]
        let innerheader = self.header
        do {
            let data = try JSONEncoder().encode(params)
            guard let parameters = try JSONSerialization.jsonObject(with: data, options: []) as? Parameters else { fatalError() }
            
            AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/identity/account/send-reset-password-email",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: innerheader)
            .responseData { response in
                    guard let data = response.data else { return }
                print("data forgot pass: \(data)")

                do {
                    let result = try JSONDecoder().decode(ForgotPassword.self, from: data)
                    print("Result: \(result)")
                    print("Result type: \(result.resultType ?? 1)")
                    print("error message: \(result.errorMessage ?? "NS")")
                    if result.resultType == 1 {
                        success()
                    } else {
                        let errorMessage = result.errorMessage
                        failure(errorMessage ?? "No found")
                    }

                } catch {
                    print(error)
                }


            }
        } catch {
            print(error)
        }
        
        
        
    }
    
    func getUserProfile(success: @escaping(UserProfile) -> Void, failure: @escaping() -> Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/users/current",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    UserDefaultsHelper.shared.setFullname(firstName: profile.result?.firstName ?? "", lastName: profile.result?.lastName ?? "")
                    success(profile)
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func updateProfile(user: AuthUser, profilePic: UIImage, success: @escaping() -> Void, failure: @escaping() -> Void) {
        let imageData = profilePic.jpegData(compressionQuality: 0.2)
        let params: Parameters = ["name": user.firstName ?? "", "surname": user.lastName ?? "", "phoneNumber": user.phoneNumber ?? "", "internalPhoneNumber": user.internalPhoneNumber ?? ""]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }   
            if let data = imageData {
                multipartFormData.append(data, withName: "profilePicture", fileName: "image.png", mimeType: "image/jpeg")
            }
        }, to: "\(ApiRequirements.apiUrl.rawValue)/api/users/current",
            method: .put,
            headers: Header.shared.headerWithToken()).responseData { response in
            guard let data = response.data else { return }
            
            do {
                let status = try JSONDecoder().decode(DocumentStatus.self, from: data)
                if status.success! {
                    success()
                } else {
                    failure()
                }
            } catch let err {
                print("error: \(err)")
                failure()
            }
        }
    }
    
//    func getAllServices(success: @escaping(ServiceAll)->Void, failure: @escaping()->Void) {
//        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/services/all",
//            method: .get,
//            headers: Header.shared.headerWithToken()).responseData { response in
//                guard let data = response.data else { return }
//
//                do {
//                    let serviceAll = try JSONDecoder().decode(ServiceAll.self, from: data)
//                    success(serviceAll)
//                } catch let err {
//                    print("error: \(err)")
//                    failure()
//                }
//        }
//    }
    
    func getAllServicesNew(success: @escaping([HomePageService])->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/services/all?includeIcons=true",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let serviceAll = try JSONDecoder().decode([HomePageService].self, from: data)
                    if let service = serviceAll.first {
                        print("Display name: \(service.displayName)")
                        print("GridIcon: \(service.gridIcon)")
                        print("ListIcon: \(service.listIcon)")
                        print("id: \(service.id ?? 0)")
                    }
                    success(serviceAll)
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getServiceEmployeeNew(departId: Int, success: @escaping(ServiceEmployee)->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/departments/\(departId)/users/employee",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let employee = try JSONDecoder().decode(ServiceEmployee.self, from: data)
                    success(employee)
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func getServiceEmployee(departId: Int, success: @escaping(ServiceEmployee)->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/departments/\(departId)/users/employee",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let employee = try JSONDecoder().decode(ServiceEmployee.self, from: data)
                    success(employee)
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func getAllAccount(success: @escaping(Account)->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/accounts/all",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let account = try JSONDecoder().decode(Account.self, from: data)
                    success(account)
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func getAllAccountNew(success: @escaping([AccountOnHeaderElement])->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/users/me/clients",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let account = try JSONDecoder().decode([AccountOnHeaderElement].self, from: data)
                    success(account)
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func downloadImage(_ fileName: String, success: @escaping(Data)->Void, failure: @escaping()->Void) {
        let encodedURLString = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/file/\(encodedURLString)",
                   method: .get,
                   headers: Header.shared.headers).responseData { response in                    
                    guard let data = response.data else {
                        failure()
                        return
                    }
                    success(data)
        }
    }
    
    func getClientInfo() {
        
    }
}
