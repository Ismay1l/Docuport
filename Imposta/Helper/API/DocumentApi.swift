//
//  Document.swift
//  Imposta
//
//  Created by Shamkhal on 12/8/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import Alamofire
import Foundation

class DocumentApi: NSObject {
    static let shared = DocumentApi()
    
    func getDocument(docType: String, limit: Int, offset: Int, serviceId: Int? = nil,
                     tagId: Int = -1,
                     searchText: String? = nil,
                     isSearch: Bool = false,
                     success: @escaping(DocumentResult) -> Void, failure: @escaping(Int, String) -> Void) {
        var params: Parameters = [String: Any]()
//        if isSearch {
//            if searchDocument.clientId != nil {
//                params.updateValue(searchDocument.clientId!, forKey: "clientId")
//            }
//            if searchDocument.creationTime != nil {
//                params.updateValue(searchDocument.creationTime!, forKey: "creationTime")
//            }
//            if searchDocument.status != nil {
//                params.updateValue(searchDocument.status!, forKey: "status")
//            }
//            if searchDocument.relatedDocId != nil {
//                params.updateValue(searchDocument.relatedDocId!, forKey: "relatedDocumentId")
//            }
//        } else {
//            params = ["limit": limit, "offset": offset]
//
//        }
        if searchText != nil && searchText != "" {
            params.updateValue(searchText ?? "", forKey: "name")
        }
        if serviceId != nil {
            params.updateValue(serviceId ?? 0, forKey: "serviceId")
        }
        params.updateValue(limit, forKey: "limit")
        params.updateValue(offset, forKey: "offset")
        
        if tagId != -1 {
            params.updateValue(tagId, forKey: "tagId")
        }
        
        if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
            params.updateValue(UserDefaultsHelper.shared.getClientID(), forKey: "clientId")
        }
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(docType)",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let document = try JSONDecoder().decode(Document.self, from: data)
                    if document.success == true {
                        if (document.result?.totalCount)! > 0 {
                            success(document.result!)
                        } else {
                            failure(1000, "There is not any inbox data")
                        }
                    } else {
                        failure((document.error?.code)!, document.error?.message ?? "")
                    }
                } catch let err {
                    print("error: \(err)")
                    //print("\(String(data: data, encoding: .utf8))")
                    failure(1000, "")
                }
        }
        debugPrint("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(docType)")
        print("parameters: \(params)")
    }
    
    func getDocTypeTags(serviceId: Int, success: @escaping ([Tag]) -> Void, failure: @escaping () -> Void) {
        let param = TagsParameter(id: serviceId)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/services/\(serviceId)/doc-type-tags",
            method: .get,
            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let result = try JSONDecoder().decode(Tags.self, from: data)
                    if result.result != nil {
                        success(result.result ?? [])
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    // For advisors
    func getDocTypeTagsForAdvisor(serviceId: Int, success: @escaping ([Tag]) -> Void, failure: @escaping () -> Void) {
        let param = TagsParameter(id: serviceId)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/services/\(serviceId)/doc-type-tags/assigned",
            method: .get,
            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let result = try JSONDecoder().decode(Tags.self, from: data)
                    if result.result != nil {
                        success(result.result ?? [])
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    // For clients
    func getDocTypeTagsForClientNew(serviceId: Int, success: @escaping ([TagGroupElement]) -> Void, failure: @escaping () -> Void) {
//        let clientId = UserDefaultsHelper.shared.getClientID()
//        let param = TagsClientParameter(serviceId: serviceId, clientId: clientId)
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/v1/document/services/\(serviceId)/main-tag-group-tags/document-assigned",
            method: .get,
//            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
            print("docData: \(data)")
            print("docId: \(serviceId)")
                
                do {
                    let result = try JSONDecoder().decode([TagGroupElement].self, from: data)
                    if result != nil {
                        print("tags: \(result)")
                        success(result )
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getDocTypeTagsForClient(serviceId: Int, success: @escaping ([Tag]) -> Void, failure: @escaping () -> Void) {
        let clientId = UserDefaultsHelper.shared.getClientID()
        let param = TagsClientParameter(serviceId: serviceId, clientId: clientId)
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/\(clientId)/services/\(serviceId)/doc-type-tags/assigned",
            method: .get,
            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let result = try JSONDecoder().decode(Tags.self, from: data)
                    if result.result != nil {
                        success(result.result ?? [])
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getDocTypeTagGroups(serviceId: Int, tagId: Int, success: @escaping ([TagGroup]) -> Void, failure: @escaping () -> Void) {
        let param = TagsGroupParameter(serviceId: serviceId, tagId: tagId)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/services/\(serviceId)/doc-type-tags/\(tagId)/tag-groups",
            method: .get,
            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let result = try JSONDecoder().decode(TagsGroup.self, from: data)
                    if result.result != nil {
                        success(result.result ?? [])
                    } else {
                        failure()
                    }
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func setDocumentStatus(documentId: Int, documentStatus: Int, success: @escaping()->Void, failure: @escaping()->Void) {
        let param = DocumentStatusParam(id: documentId, status: documentStatus)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(documentId)/status",
            method: .put,
            parameters: param,
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
    
    /*func downloadFile(fileName: String, success: @escaping(Data)->Void, failure: @escaping()->Void) {
        let destionation = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        AF.download("\(ApiRequirements.apiUrl.rawValue)/api/documents/file/\(fileName)",
            method: .get,
            headers: Header.shared.headerWithToken(), to: destionation).responseData { response in
                if let data = response.value {
                    success(data)
                } else {
                    failure()
                }
        }
    }*/
    
    func saveDocumentClient(clientId: Int, success: @escaping()->Void, failure: @escaping()->Void) {
        let param = DocumentClientParam(id: editDocument?.id, clientId: clientId)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(editDocument?.id ?? 0)/client",
            method: .put,
            parameters: param,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let documentClient = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if documentClient.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func saveDocumentClientService(docId: Int, serviceId: Int, success: @escaping()->Void, failure: @escaping()->Void) {
        print("saveDocumentClientService docId \(docId)")
        let param = DocumentClientServiceParam(id: docId, serviceId: serviceId)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(docId)/service",
            method: .put,
            parameters: param,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let documentClientService = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if documentClientService.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func saveDocumentTags(params: TagsOfDocumentParams, success: @escaping()->Void, failure: @escaping()->Void) {
        let param = DocumentTagParameter(id: params.id, tags: params.tags)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(params.id)/tags",
            method: .put,
            parameters: param,  
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
            DocumentSingleton.shared.isFileIploaded = true
                do {
                    let documentClientService = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if documentClientService.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func saveDocumentTags2(docId: Int,params: TagsOfDocumentParams, success: @escaping()->Void, failure: @escaping()->Void) {
        print("saveDocumentTags2 docId \(docId)")
        let param = DocumentTagParameter(id: docId, tags: params.tags)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(docId)/tags",
            method: .put,
            parameters: param,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let documentClientService = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if documentClientService.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func saveDocumentDescription(documentId: Int, desc: String, success: @escaping()->Void, failure: @escaping()->Void) {
        print("saveDocumentDescription docId \(documentId)")
        let param = DocumentDescriptionParam(id: documentId, description: desc)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(documentId)/description",
            method: .put,
            parameters: param,
            encoder: JSONParameterEncoder.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
            DocumentSingleton.shared.isFileIploaded = true
                do {
                    let descResult = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if descResult.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                    failure()
                }
        }
    }
    
    func searchRelatedDoc(clientId: Int, searchTerm: String, success: @escaping(RelatedDocs)->Void, failure: @escaping()->Void) {
        let params: Parameters = ["clientId": clientId, "searchTerm": searchTerm]
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/request",
            method: .get,
            parameters: params,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let relatedDcos = try JSONDecoder().decode(RelatedDocs.self, from: data)
                    if relatedDcos.success! {
                        success(relatedDcos)
                    } else {
                        failure()
                    }
                    
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func saveRealtedDocs(documentId: Int, arrRelatedDocs: [Int], success: @escaping()->Void, failure: @escaping()->Void) {
        let param = DocsRelatedParam(id: documentId, relatedDocs: arrRelatedDocs)
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/documents/\(documentId)/related-docs",
            method: .put,
            parameters: param,
            encoder: JSONParameterEncoder.prettyPrinted,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let realtedDocsResult = try JSONDecoder().decode(DocumentStatus.self, from: data)
                    if realtedDocsResult.success! {
                        success()
                    } else {
                        failure()
                    }
                } catch {
                    print("error: \(error)")
                }
        }
    }
    
    //func setDocumentClientAndService(client: ResultClients, success: @escaping()->Void, failure: @escaping()->Void) {}
    
    func uploadDocument(uploadFile: Data, fileName: String, isImage: Bool, uploadProgress: @escaping(Double)->Void, success: @escaping(UploadedDocument)->Void, failure: @escaping()->Void) {
        let params: Parameters = ["ClientId": UserDefaultsHelper.shared.getClientID()]
        
        AF.upload(multipartFormData: { multipartFormData in
            if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
                for (key, value) in params {
                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                }
            } else {
                multipartFormData.append("".data(using: .utf8)!, withName: "ClientId")
            }
            if isImage {
                multipartFormData.append(uploadFile, withName: "File", fileName: fileName, mimeType: "image/jpeg")
            } else {
                multipartFormData.append(uploadFile, withName: "File", fileName: fileName, mimeType: "application/\(String(fileName.suffix(3)))")
            }
            
        }, to: "\(ApiRequirements.apiUrl.rawValue)/api/documents", method: .post, headers: Header.shared.headerWithToken())
            .responseData { response in
            guard let data = response.data else { return }
            
            do {
                let uploadedDoc = try JSONDecoder().decode(UploadedDocument.self, from: data)
                if uploadedDoc.success! {
                    success(uploadedDoc)
                } else {
                    failure()
                }
            } catch let err {
                print("error: \(err)")
                failure()
            }
        }
        .uploadProgress { progess in
            uploadProgress(progess.fractionCompleted)
        }
    }
}
