//
//  ClientApi.swift
//  Imposta
//
//  Created by Shamkhal on 12/8/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Alamofire
import Foundation

class ClientApi: NSObject {
    static let shared = ClientApi()
    
    func getClientListNew( success: @escaping(ClientList) -> Void, failure: @escaping() -> Void) {
      
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/clients",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
            print("dataWWW: \(data)")
                do {
                    let client = try JSONDecoder().decode(ClientList.self, from: data)
                    print("clientwww: \(client)")
                    success(client)
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getClientList(limit: Int, offset: Int, success: @escaping(Client) -> Void, failure: @escaping() -> Void) {
        let params: Parameters = ["limit": limit, "offset": offset]
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                do {
                    let client = try JSONDecoder().decode(Client.self, from: data)
                    success(client)
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getClientByIDBusiness(id: Int, success: @escaping(ClientInfoUser1) -> Void, failure: @escaping() -> Void) {
        
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
        AF.sessionConfiguration.timeoutIntervalForResource = 60
        
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/clients/business/\(id)",
                   method: .get,
                   headers: Header.shared.headerWithToken()).responseData { response in
            print("responePPP: \(response)")
            guard let data = response.data else {
                print("no data fetched")
                return
            }
            do {
                let client = try JSONDecoder().decode(ClientInfoUser1.self, from: data)
                success(client)
                
            } catch let err {
                print("error: \(err)")
                failure()
            }
        }
        
    }
    
    func getClientByIDPersonal(id: Int, success: @escaping(ClientInfoUser2) -> Void, failure: @escaping() -> Void) {
        
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
        AF.sessionConfiguration.timeoutIntervalForResource = 60
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/clients/personal/\(id)",
                   method: .get,
                   headers: Header.shared.headerWithToken()).responseData { response in
            print("responePPP: \(response)")
            guard let data = response.data else {
                print("no data fetched")
                return
            }
            do {
                let client = try JSONDecoder().decode(ClientInfoUser2.self, from: data)
                success(client)
                
            } catch let err {
                print("error: \(err)")
                failure()
            }
        }
        
    }
    
    func getSearchedClient(limit: Int, offset: Int, clientSearch: ClientSearch, success: @escaping(Client) -> Void, failure: @escaping() -> Void) {
        var params: Parameters = [String: Any]()
        
        if clientSearch.name != nil {
            params.updateValue(clientSearch.name!, forKey: "name")
        }
        if clientSearch.tin != nil {
            params.updateValue(clientSearch.tin!, forKey: "taxpayerIdentificationNumber")
        }
        if clientSearch.ssn != nil {
            params.updateValue(clientSearch.ssn!, forKey: "socialSecurityNumber")
        }
        if clientSearch.clientType != nil {
            params.updateValue(clientSearch.clientType!, forKey: "clientType")
        }
        if clientSearch.serviceId != nil {
            params.updateValue(clientSearch.serviceId!, forKey: "serviceId")
        }
        params.updateValue(limit, forKey: "limit")
        params.updateValue(offset, forKey: "offset")
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let profile = try JSONDecoder().decode(Client.self, from: data)
                    if profile.success! {
                        success(profile)
                    } else {
                        failure()
                    }
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getInvitations(limit: Int, offset: Int, recipient: String, status: String, success: @escaping(Invitation)->Void, failure: @escaping(String)->Void) {
        let params: Parameters = ["limit": limit, "offset": offset, "recipient": recipient, "status": status]
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/invitations",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let invitation = try JSONDecoder().decode(Invitation.self, from: data)
                    guard let invitationSuccess = invitation.success else { return }
                    if invitationSuccess {
                        success(invitation)
                    } else {
                        failure(invitation.error?.message ?? "")
                    }
                } catch {
                    print("error: \(error)")
                    failure("")
                }
        }
    }
    
    func sendInvitaion(email: String, success: @escaping()->Void, failure: @escaping()->Void) {
        let params = InvitationParam(recipient: email, clientId: UserDefaultsHelper.shared.getClientID())
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/invitations",
            method: .post,
            parameters: params,
            encoder: JSONParameterEncoder.default,
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
    
    func getAdvisorList(success: @escaping(Advisor)->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/users/advisor",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let advisor = try JSONDecoder().decode(Advisor.self, from: data)
                    success(advisor)
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getClientServiceList(clientId: String, success: @escaping(Service)->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/\(clientId)/services",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let service = try JSONDecoder().decode(Service.self, from: data)
                    if service.result != nil {
                        success(service)
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getClientServiceListNew(clientId: String, success: @escaping([ClientServices])->Void, failure: @escaping()->Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/clients/80/services?includeIcons=true",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else {
                    print("data is nil in getClientServiceListNew")
                    return }
                do {
                    let service = try JSONDecoder().decode([ClientServices].self, from: data)
                    if service != nil {
                        print("yyy: \(service)")
                        success(service)
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func savePersonalClient(client: ResultClients, success: @escaping()->Void, failure: @escaping(String)->Void) {
        var arrServices = [ClientParofileServices]()
        for service in client.services! {
            arrServices.append(ClientParofileServices(serviceId: service.service?.id, employeeUserId: service.employee?.id))
        }
        let params = ClientProfileParam(id: client.id, firstName: client.firstName ?? "", lastName: client.lastName ?? "", socialSecurityNumber: client.socialSecurityNumber ?? "", birthDate: client.birthDate ?? "", phoneNumber: client.phoneNumber ?? "", advisorUserId: client.advisor?.id, services: arrServices)
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/personal/\(client.id!)",
            method: .put,
            parameters: params,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let status = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if status.success! {
                        success()
                    } else {
                        failure(status.error?.message ?? "")
                    }
                } catch let err {
                    print("error: \(err)")
                    failure("")
                }
        }
    }
    
    func saveBusinessClient(client: ResultClients, success: @escaping()->Void, failure: @escaping(String)->Void) {
        var arrServices = [ClientParofileServices]()
        for service in client.services! {
            arrServices.append(ClientParofileServices(serviceId: service.service?.id, employeeUserId: service.employee?.id))
        }
        
        let params = ClientBusinessProfileParam(id: client.id, name: client.name ?? "", taxpayerIdentificationNumber: client.taxpayerIdentificationNumber ?? "", phoneNumber: client.phoneNumber ?? "", advisorUserId: client.advisor?.id, services: arrServices)
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/business/\(client.id!)",
            method: .put,
            parameters: params,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let status = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if status.success! {
                        success()
                    } else {
                        failure(status.error?.message ?? "")
                    }
                } catch let err {
                    print("error: \(err)")
                    failure("")
                }
        }
    }
    
    /// Save client profile picture.
    /// - Parameters:
    ///   - client: client model
    ///   - clientType: Personal or Business
    ///   - profilePic: UIImage()
    ///   - success: successfull response
    ///   - failure: fail response
    func saveClientProfilePic(_ client: ResultClients, _ clientType: String, _ profilePic: UIImage, success: @escaping() -> Void, failure: @escaping(String) -> Void) {
        AF.upload(multipartFormData: { multipartFormData in
            if let data = profilePic.jpegData(compressionQuality: 0.2) {
                multipartFormData.append(data, withName: "profileImage", fileName: "image.png", mimeType: "image/jpeg")
                multipartFormData.append("\(client.id ?? 0)".data(using: .utf8)!, withName: "id")
                multipartFormData.append("\(client.phoneNumber ?? "")".data(using: .utf8)!, withName: "phoneNumber")
                multipartFormData.append("\(client.emailAddress ?? "")".data(using: .utf8)!, withName: "emailAddress")
                multipartFormData.append("\(client.advisor?.id ?? 0)".data(using: .utf8)!, withName: "advisorUserId")
                if let services = client.services, services.count > 0 {
                    for i in 0...(services.count - 1) {
                        let keyEmployeeUserId = "services[\(i)].employeeUserId"
                        let keyServiceId = "services[\(i)].serviceId"
                        multipartFormData.append("\(client.services?[i].employee?.id ?? 0)".data(using: .utf8)!, withName: keyEmployeeUserId)
                        multipartFormData.append("\(client.services?[i].service?.id ?? 0)".data(using: .utf8)!, withName: keyServiceId)
                    }
                }
                if clientType == "business" {
                    multipartFormData.append("\(client.name ?? "")".data(using: .utf8)!, withName: "name")
                }
                else {
                    multipartFormData.append("\(client.firstName ?? " ")".data(using: .utf8)!, withName: "firstName")
                    multipartFormData.append("\(client.lastName ?? " ")".data(using: .utf8)!, withName: "lastName")
                }
            }
            
        }, to: "\(ApiRequirements.apiUrl.rawValue)/api/v2/clients/\(clientType)/\(client.id!)",
           method: .put,
           headers: Header.shared.headerWithToken()).responseData { response in
            guard let data = response.data else { return }
            
            do {
                let status = try JSONDecoder().decode(DocumentStatus.self, from: data)
                if status.success! {
                    success()
                } else {
                    failure(status.error?.message ?? "")
                }
            } catch let err {
                print("error: \(err)")
                failure("")
            }
        }
    }
}
