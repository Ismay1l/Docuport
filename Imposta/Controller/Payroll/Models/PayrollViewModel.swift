//
//  PayrollViewModel.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 27.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import SVProgressHUD

enum SaveType {
    case save
    case edit
}

class PayrollViewModel {
    var payrollPeriods: [PayrollPeriod] = []
    var payrollInfos: [PayrollInfo] = []
    
    var selectedPeriod: PayrollPeriod?
    var selectedPayrollInfo: PayrollInfo?
    var totalGross: Double = 0.0
    var saveType: SaveType = .save
    
    func getPayrollPeriods(completion: @escaping (() -> Void)) {
        let id = UserDefaultsHelper.shared.getClientID()
        
        SVProgressHUD.show()
        PayrollApi.shared.getPayrollPeriods(clientId: id, success: { [weak self] result in
            self?.payrollPeriods = result.map { value in
                let startDate = DateFormatter.payrollDateTime.date(from: value.payPeriodStartDate ?? "")?.longDate
                let endDate = DateFormatter.payrollDateTime.date(from: value.payPeriodEndDate ?? "")?.longDate
                let payDate = DateFormatter.payrollDateTime.date(from: value.payDate ?? "")?.longDate
                
                return PayrollPeriod(id: value.id, clientId: value.clientId, payPeriodStartDate: startDate, payPeriodEndDate: endDate, payDate: payDate, inputColumns: value.inputColumns, payFrequency: value.payFrequency, isSubmitted: value.isSubmitted, comment: value.comment)
            }
            completion()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func getPayrollInfos(completion: @escaping (() -> Void)) {
        guard let selectedPeriod = selectedPeriod else {
            completion()
            return
        }
        
        let periodId = selectedPeriod.id ?? 0
        totalGross = 0
        
        SVProgressHUD.show()
        PayrollApi.shared.getPayrollInfos(payPeriodId: periodId, success: { [weak self] result in
            self?.payrollInfos = result.map { value in
                var info = value
                info.isSubmitted = selectedPeriod.isSubmitted ?? true
                self?.totalGross += (value.grossPay ?? 0)
                return info
            }
            completion()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func savePayrollInfo(params: [String: Any], completion: @escaping ((Bool) -> Void)) {
        SVProgressHUD.show()
        PayrollApi.shared.savePayroll(params: params, success: {
            completion(true)
            SVProgressHUD.dismiss()
        }, failure: {
            completion(false)
            SVProgressHUD.dismiss()
        })
    }
    
    func updatePayrollInfo(params: [String: Any], completion: @escaping ((Bool) -> Void)) {
        SVProgressHUD.show()
        PayrollApi.shared.updatePayroll(params: params, success: {
            completion(true)
            SVProgressHUD.dismiss()
        }, failure: {
            completion(false)
            SVProgressHUD.dismiss()
        })
    }
    
    func deletePayroll(completion: @escaping ((Bool) -> Void)) {
        guard let employeeId = selectedPayrollInfo?.id else { return }
        
        SVProgressHUD.show()
        PayrollApi.shared.deletePayroll(employeeId: employeeId, success: { [weak self] in
            self?.selectedPayrollInfo = nil
            completion(true)
            SVProgressHUD.dismiss()
        }, failure: {
            completion(false)
            SVProgressHUD.dismiss()
        })
    }
    
    func submitPayPeriod(payrollSubmit: PayrollSubmit, completion: @escaping ((Bool) -> Void)) {
        SVProgressHUD.show()
        PayrollApi.shared.submitPayroll(payrollSubmit: payrollSubmit, success: {
            completion(true)
            SVProgressHUD.dismiss()
        }, failure: {
            completion(false)
            SVProgressHUD.dismiss()
        })
    }
    
    func getCollectionData(viewModel: PayrollInfo) -> [PayrollInfoCellViewModel] {
        var payrollInfos = [PayrollInfoCellViewModel]()
        
        guard let inputs = selectedPeriod?.inputColumns else { return [] }
        for input in inputs {
            switch input {
            case .payRate:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Pay rate", value: String(viewModel.payRate ?? 0.0)))
            case .regularHours:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Regular hours", value: String(viewModel.regularHours ?? 0)))
            case .overtime:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Overtime", value: String(viewModel.overtime ?? 0.0)))
            case .salary:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Salary", value: String(viewModel.salary ?? 0.0)))
            case .tip:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Tip", value: String(viewModel.tip ?? 0.0)))
            case .commission:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Commission", value: String(viewModel.commission ?? 0.0)))
            case .bonus:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Bonus", value: String(viewModel.bonus ?? 0.0)))
            case .advancePaid:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Advance paid", value: String(viewModel.advancePaid ?? 0.0)))
            case .reimbursement:
                payrollInfos.append(PayrollInfoCellViewModel(name: "Reimbursement", value: String(viewModel.reimbursement ?? 0.0)))
            }
        }

        return payrollInfos
    }
}
