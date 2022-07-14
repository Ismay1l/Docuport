//
//  AddEmployeeViewController.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 24.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class AddEmployeeViewController: UIViewController {
    private let viewModel: PayrollViewModel!
    private var params = [String: Any]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var salaryStack: UIStackView!
    @IBOutlet weak var payRateStack: UIStackView!
    @IBOutlet weak var tipsStack: UIStackView!
    @IBOutlet weak var bonusStack: UIStackView!
    @IBOutlet weak var regularHoursStack: UIStackView!
    @IBOutlet weak var overtimeStack: UIStackView!
    @IBOutlet weak var commissionStack: UIStackView!
    @IBOutlet weak var advancePaidStack: UIStackView!
    @IBOutlet weak var reimbursementStack: UIStackView!
    @IBOutlet weak var payPeriodStack: UIStackView!
    
    @IBOutlet weak var nameTextField: PayrollTextField!
    @IBOutlet weak var surnameTextField: PayrollTextField!
    @IBOutlet weak var middlenameTextField: PayrollTextField!
    @IBOutlet weak var salaryTextField: PayrollTextField!
    @IBOutlet weak var payrateTextField: PayrollTextField!
    @IBOutlet weak var tipsTextField: PayrollTextField!
    @IBOutlet weak var bonusTextField: PayrollTextField!
    @IBOutlet weak var regularHoursTextField: PayrollTextField!
    @IBOutlet weak var overtimeTextField: PayrollTextField!
    @IBOutlet weak var commissionTextField: PayrollTextField!
    @IBOutlet weak var advancePaidTextField: PayrollTextField!
    @IBOutlet weak var reimbursementTextField: PayrollTextField!
    @IBOutlet weak var payPeriodTextField: PayrollTextField!
    
    lazy var onDismiss: (() -> Void) = { [weak self] in self?.dismiss(animated: true) }
    
    init(with model: PayrollViewModel) {
        self.viewModel = model
        super.init(nibName: "AddEmployeeView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        setupInputs()
    }
    
    private func setupView() {
        scrollView.layer.cornerRadius = 10
        scrollView.layer.masksToBounds = true
    }
    
    private func setupInputs() {
        nameTextField.text = viewModel.selectedPayrollInfo?.firstName
        surnameTextField.text = viewModel.selectedPayrollInfo?.lastName
        middlenameTextField.text = viewModel.selectedPayrollInfo?.middleName
        
        guard let inputs = viewModel.selectedPeriod?.inputColumns else { return }
        for input in inputs {
            switch input {
            case .payRate:
                payRateStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.payRate ?? -1
                payrateTextField.text = value == -1 ? "" : String(value)
            case .regularHours:
                regularHoursStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.regularHours ?? -1
                regularHoursTextField.text = value == -1 ? "" : String(value)
            case .overtime:
                overtimeStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.overtime ?? -1
                overtimeTextField.text = value == -1 ? "" : String(value)
            case .salary:
                salaryStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.salary ?? -1
                salaryTextField.text = value == -1 ? "" : String(value)
            case .tip:
                tipsStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.tip ?? -1
                tipsTextField.text = value == -1 ? "" : String(value)
            case .commission:
                commissionStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.commission ?? -1
                commissionTextField.text = value == -1 ? "" : String(value)
            case .bonus:
                bonusStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.bonus ?? -1
                bonusTextField.text = value == -1 ? "" : String(value)
            case .advancePaid:
                advancePaidStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.advancePaid ?? -1
                advancePaidTextField.text = value == -1 ? "" : String(value)
            case .reimbursement:
                reimbursementStack.isHidden = false
                let value = viewModel.selectedPayrollInfo?.reimbursement ?? -1
                reimbursementTextField.text = value == -1 ? "" : String(value)
            }
        }
    }
}

extension AddEmployeeViewController {
    @IBAction func onCancelTap(_ sender: Any) {
        self.onDismiss()
    }
    
    @IBAction func onSaveTap(_ sender: Any) {
        let verified = verifyInputs()
        guard verified else { return }
        
        let periodID = viewModel.selectedPeriod?.id
        let payrollInfoId = viewModel.selectedPayrollInfo?.id
        
        params["firstName"] = nameTextField.text
        params["lastName"] = surnameTextField.text
        params["middleName"] = middlenameTextField.text
        params["payRate"] = Double(payrateTextField.text ?? "")
        params["regularHours"] = Int(regularHoursTextField.text ?? "")
        params["overtime"] = Double(overtimeTextField.text ?? "")
        params["salary"] = Double(salaryTextField.text ?? "")
        params["tip"] = Double(tipsTextField.text ?? "")
        params["commission"] = Double(commissionTextField.text ?? "")
        params["bonus"] = Double(bonusTextField.text ?? "")
        params["advancePaid"] = Double(advancePaidTextField.text ?? "")
        params["reimbursement"] = Double(reimbursementTextField.text ?? "")
        
        if viewModel.saveType == .save {
            params["payPeriodId"] = periodID
            viewModel.savePayrollInfo(params: params) { [weak self] result in
                if result {
                    self?.onDismiss()
                } else {
                    self?.alert(title: "Error", message: "Please try again!", actionButton: "OK")
                }
            }
        } else {
            params["id"] = payrollInfoId
            viewModel.updatePayrollInfo(params: params) { [weak self] result in
                if result {
                    self?.onDismiss()
                } else {
                    self?.alert(title: "Error", message: "Please try again!", actionButton: "OK")
                }
            }
        }
    }
    
    private func verifyInputs() -> Bool {
        guard let firstName = nameTextField.text, firstName.count > 0,
              let lastName = surnameTextField.text, lastName.count > 0 else {
            self.alert(title: "Message", message: "Please fill the required fields!", actionButton: "OK")
            return false
        }
        
        return true
    }
}
