//
//  AddAccountVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class AddAccountVC: UIViewController {

    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var txtFieldFirstName: UITextField!
    @IBOutlet var txtFieldLastName: UITextField!
    @IBOutlet var viewFirstName: UIView!
    @IBOutlet var viewLastName: UIView!
    
    @IBOutlet var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lastNameTopConstraint: NSLayoutConstraint!
    @IBOutlet var lastNameHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            viewLastName.isHidden = false
            viewHeightConstraint.constant = 272
            lastNameTopConstraint.constant = 12
            lastNameHeightConstraint.constant = 35
        } else {
            viewLastName.isHidden = true
            viewHeightConstraint.constant = 265
            lastNameTopConstraint.constant = 0
            lastNameHeightConstraint.constant = 0
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
