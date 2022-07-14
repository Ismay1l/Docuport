//
//  AccountsOldVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/13/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class AccountsOldVC: UIViewController {
    @IBOutlet var tableAccounts: UITableView!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var buttonPlus: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchType = .accounts
        
        addMenuNavButton()
        addSearchNavButton()
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
    }
    
    @IBAction func btnPlus(_ sender: Any) {
        let addAccountVC = storyboard?.instantiateViewController(withIdentifier: "AddAccountVC") as! AddAccountVC
        customPresentViewController(presenter, viewController: addAccountVC, animated: true)
    }
    
}

extension AccountsOldVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsCell") as! AccountsCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
