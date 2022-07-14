//
//  PayrollApi.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 28.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import Alamofire

class PayrollApi: NSObject {
    static let shared = PayrollApi()
        
    func getPayrollPeriods(clientId: Int, success: @escaping([PayrollPeriod]) -> Void, failure: @escaping() -> Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/\(clientId)/payroll/pay-periods",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollPeriods.self, from: data)
                    let result = data.result ?? []
                    success(result)
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func getPayrollInfos(payPeriodId: Int, success: @escaping([PayrollInfo]) -> Void, failure: @escaping() -> Void) {
        let param = PayrollInfoParameter(payPeriodId: payPeriodId)
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/payroll",
            method: .get,
            parameters: param,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollInfos.self, from: data)
                    let result = data.result?.payrollInfo ?? []
                    success(result)
                } catch let err {
                    print("error: \(err)")
                    failure()
                }
        }
    }
    
    func savePayroll(params: Parameters, success: @escaping () -> Void, failure: @escaping () -> Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/payroll",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollResult.self, from: data)
                    let result = data.success
                    
                    if result == true {
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
    
    func updatePayroll(params: Parameters, success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let id = params["id"] else { return }
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/payroll/\(id)",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollResult.self, from: data)
                    let result = data.success
                    
                    if result == true {
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
    
    func submitPayroll(payrollSubmit: PayrollSubmit, success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let id = payrollSubmit.payPeriodId else { return }
        let params: Parameters = [
            "payPeriodId": id,
            "comment": payrollSubmit.comment ?? ""
        ]
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/payroll/pay-periods/\(id)/submit",
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollResult.self, from: data)
                    let result = data.success
                    
                    if result == true {
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
    
    func deletePayroll(employeeId: Int, success: @escaping () -> Void, failure: @escaping () -> Void) {
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/payroll/\(employeeId)",
            method: .delete,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(PayrollResult.self, from: data)
                    let result = data.success
                    
                    if result == true {
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
    
    func hasPayrollService(success: @escaping () -> Void, failure: @escaping () -> Void) {
        let clientId = UserDefaultsHelper.shared.getClientID()
        
        AF.request("\(ApiRequirements.apiUrl.rawValue)/api/clients/\(clientId)/has-payroll-service",
            method: .get,
            headers: Header.shared.headerWithToken()).responseData { response in
                guard let data = response.data else { return }
                
                do {
                    let data = try JSONDecoder().decode(HasPayrollServiceResult.self, from: data)
                    let result = data.result
                    
                    if result == true {
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
}
