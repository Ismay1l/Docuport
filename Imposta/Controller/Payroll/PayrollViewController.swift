//
//  PayrollViewController.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel

class PayrollViewController: UIViewController {
    private let viewModel = PayrollViewModel()
    
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var clientView: UIView!
    @IBOutlet weak var advisorView: UIView!
    @IBOutlet weak var submitPayrollView: UIStackView!
    @IBOutlet weak var payrollPeriodTextField: PayrollPeriodTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var logoNav: UIImageView!
    
    @IBOutlet weak var addEmployeeButton: UIButton!
    @IBOutlet weak var grossLabel: UILabel!
    @IBOutlet weak var grossTextField: PayrollTextField!
    @IBOutlet weak var submitPayrollLabel: UILabel!
    @IBOutlet weak var submitIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    private var refreshControl = UIRefreshControl()
    private var payrollPeriodPicker = UIPickerView()
    private var userPayrollInfo = [PayrollInfoCellViewModel]()
    private var storedOffsets = [Int: CGFloat]()
    
    private var showSearchView = false
    private var isInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        getPayrollPeriods()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInProgress {
            _ = IsPayrollAvailable()
        }
        
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
}

extension PayrollViewController {
    private func setupView() {
        submitPayrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSubmit)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
                
        setupLogo()
    }
    
    private func disableSubmit() {
        addEmployeeButton.isEnabled = false
        addEmployeeButton.borderColor = .disablePayroll
        addEmployeeButton.setTitleColor(.disablePayroll, for: .normal)
        
        grossLabel.textColor = .disablePayroll
        grossTextField.layer.borderColor = UIColor.disablePayroll.cgColor
        
        submitPayrollView.isUserInteractionEnabled = false
        submitPayrollLabel.textColor = .disablePayroll
        submitIcon.image = UIImage(named: "payroll_uncheck_ic")
    }
    
    private func enableSubmit() {
        addEmployeeButton.isEnabled = true
        addEmployeeButton.borderColor = .mainColor
        addEmployeeButton.setTitleColor(.mainColor, for: .normal)
        
        grossLabel.textColor = .black
        grossTextField.layer.borderColor = UIColor.mainColor.cgColor
        
        submitPayrollView.isUserInteractionEnabled = true
        submitPayrollLabel.textColor = .mainColor
        submitIcon.image = UIImage(named: "payroll_check_ic")
    }
    
    @IBAction func showAccounts(_ sender: Any) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
                    VC.arrUserNew = clients
                    VC.delegate = self
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }

//            AppApi.shared.getAllAccount(success: { response in
//                guard let clients = response.result else { return }
//                VC.arrUser = clients
//                VC.delegate = self
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    
    @IBAction func addEmployeeTap(_ sender: Any) {
        let controller = AddEmployeeViewController(with: viewModel)
        controller.modalPresentationStyle = .fullScreen
        controller.onDismiss = { [weak self] in
            self?.viewModel.saveType = .save
            self?.viewModel.selectedPayrollInfo = nil
            self?.refreshData()
            controller.dismiss(animated: true)
        }
        self.present(controller, animated: true)
    }
    
    private func onDeleteTap() {
        let controller = DeleteEmployeeViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.onDelete = { [weak self] in
            self?.deletePayrollInfo()
            controller.dismiss(animated: true)
        }
        self.present(controller, animated: true)
    }
    
    @objc private func onSubmit() {
        let controller = CommentViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.onSave = { [weak self] comment in
            self?.submitPayroll(comment: comment)
            controller.dismiss(animated: true)
        }
        self.present(controller, animated: true)
    }
}

// MARK: - PickerView methods
extension PayrollViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func setupPickerView() {
        payrollPeriodPicker.dataSource = self
        payrollPeriodPicker.delegate = self
        
        payrollPeriodTextField.inputView = payrollPeriodPicker
        
        if !IsPayrollAvailable() {
            return
        }
        
        let period = viewModel.payrollPeriods[0]
        let isSubmitted = period.isSubmitted ?? true
        if isSubmitted {
            disableSubmit()
        } else {
            enableSubmit()
        }
        
        payrollPeriodTextField.text = "\(period.payPeriodStartDate ?? "") - \(period.payPeriodEndDate ?? "") $Date: \(period.payDate ?? "")"
        setPickerRow()
    }
    
    func setPickerRow() {
        let index = viewModel.payrollPeriods.firstIndex(where: { $0.id == viewModel.selectedPeriod?.id }) ?? 0
        self.pickerView(payrollPeriodPicker, didSelectRow: index, inComponent: 0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.payrollPeriods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let period = viewModel.payrollPeriods[row]
        let date = "\(period.payPeriodStartDate ?? "") - \(period.payPeriodEndDate ?? "") $Date: \(period.payDate ?? "")"
        return date
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedPeriod = viewModel.payrollPeriods[row]
        
        let period = viewModel.payrollPeriods[row]
        let isSubmitted = period.isSubmitted ?? true
        
        if isSubmitted {
            disableSubmit()
        } else {
            enableSubmit()
        }
        
        let date = "\(period.payPeriodStartDate ?? "") - \(period.payPeriodEndDate ?? "") $Date: \(period.payDate ?? "")"
        payrollPeriodTextField.text = date
        getPayrollInfos()
    }
}

// MARK: - TableView methods
extension PayrollViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.payrollInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "payrollCell", for: indexPath) as! PayrollCell
        cell.configure(viewModel: viewModel.payrollInfos[indexPath.row])
        
        userPayrollInfo = viewModel.getCollectionData(viewModel: viewModel.payrollInfos[indexPath.row])
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        cell.setCollectionViewSize(size: userPayrollInfo.count)
        
        cell.onEdit = { [weak self] in
            self?.viewModel.saveType = .edit
            self?.viewModel.selectedPayrollInfo = self?.viewModel.payrollInfos[indexPath.row]
            self?.addEmployeeTap(UIButton())
        }
        
        cell.onDelete = { [weak self] in
            self?.viewModel.selectedPayrollInfo = self?.viewModel.payrollInfos[indexPath.row]
            self?.onDeleteTap()
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did select ", indexPath.row)
    }
}

// MARK: - CollectionView methods
extension PayrollViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPayrollInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "payrollInfoCell", for: indexPath) as! PayrollInfoCell
        cell.configure(viewModel: userPayrollInfo[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select ", indexPath.row)
    }
}

extension PayrollViewController: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func setupLogo() {
        logoIcon?.isUserInteractionEnabled = true
        logoIcon?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        
        logoNav?.isUserInteractionEnabled = true
        logoNav?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        
        setLogout(view: logoutIcon)
    }
}

// MARK: - Services
extension PayrollViewController {
    @objc private func refreshData() {
        getPayrollInfos()
    }
    
    private func getPayrollPeriods() {
        isInProgress = true
        viewModel.getPayrollPeriods { [weak self] in
            self?.setupPickerView()
            self?.isInProgress = false
        }
    }
    
    private func getPayrollInfos() {
        viewModel.getPayrollInfos { [weak self] in
            self?.grossTextField.text = String(format: "%.2f", self?.viewModel.totalGross ?? 0.0)
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func deletePayrollInfo() {
        viewModel.deletePayroll { [weak self] result in
            if result {
                self?.refreshData()
            } else {
                self?.alert(title: "Error", message: "Please try again!", actionButton: "OK")
            }
        }
    }
    
    private func submitPayroll(comment: String) {
        let periodId = viewModel.selectedPeriod?.id
        let payrollSubmit = PayrollSubmit(payPeriodId: periodId, comment: comment)
        viewModel.submitPayPeriod(payrollSubmit: payrollSubmit) { [weak self] result in
            if result {
                let controller = MissionCompleteViewController()
                controller.modalPresentationStyle = .fullScreen
                
                controller.onDismiss = {
                    self?.getPayrollPeriods()
                    controller.dismiss(animated: true, completion: nil)
                }
                self?.present(controller, animated: true)
                
            } else {
                self?.alert(title: "Error", message: "Please try again!", actionButton: "OK")
            }
        }
    }
    
    private func IsPayrollAvailable() -> Bool {
        if viewModel.payrollPeriods.isEmpty {
            alert(title: "Message", message: "There is no payroll data to display", actionButton: "OK")
            self.tabBarController?.selectedIndex = 0
            return false
        }
        return true
    }
}
