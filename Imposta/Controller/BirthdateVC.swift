//
//  BirthdateVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/16/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class BirthdateVC: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func btnDone(_ sender: Any) {
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "MMMM dd, yyyy"
        
        let dict:[String: String] = ["birthdate": dateFromatter.string(from: datePicker.date)]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "birthdate"), object: nil, userInfo: dict)
        dismiss(animated: true, completion: nil)
    }
}
