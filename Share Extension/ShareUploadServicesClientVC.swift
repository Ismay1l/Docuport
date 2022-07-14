//
//  File.swift
//  Share Extension
//
//  Created by Ulxan Emiraslanov on 10/3/20.
//  Copyright © 2020 Imposta. All rights reserved.
//


import UIKit

class ShareUploadServicesClientVC: UIViewController {

    
    var allowsTapToDismissPopupCard = false
    var allowsSwipeToDismissPopupCard = false
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var wrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var centerView: CardView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var delegate: ServiceListDelegate?
    var document: ResultDocument?
    var arrService = [ClientServiceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        wrapperHeight.constant = self.view.frame.size.height

        setup()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.endEditing(true)
    }
    
    func setup() {
        ClientApi.shared.getClientServiceList(clientId: "\(UserDefaultsHelper.shared.getClientID())", success: { response in
            guard let result = response.result else { return }
            self.arrService = result
            for index in 0..<self.arrService.count {
                self.arrService[index].service?.isSelected = false
            }
            
            if let idx = self.arrService.firstIndex(where: {$0.service?.id == self.document?.service?.id}) {
                self.arrService[idx].service?.isSelected = true
            }
            
            self.tableView.reloadData()
            self.hideSpinner(self.spinner)
        }, failure: {
            self.hideSpinner(self.spinner)
        })
    }
    
}

extension ShareUploadServicesClientVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contentHeight = CGFloat(arrService.count * 66)
        if contentHeight > UIScreen.main.bounds.height - 220 {
            tableViewHeight.constant = UIScreen.main.bounds.height - 220
        } else {
            tableViewHeight.constant = contentHeight
        }
        return arrService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploadServicesClientTVCell" , for: indexPath) as! UploadServicesClientTVCell
        
        cell.titleLbl.text = arrService[indexPath.item].service?.name
        if (arrService[indexPath.item].service?.isSelected)! {
            cell.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        delegate?.serviceSelection(clientService: arrService[indexPath.item].service ?? ClientServiceData())
    }
    
}
