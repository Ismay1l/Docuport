//
//  InvitationSearchVC.swift
//  Imposta
//
//  Created by Shamkhal on 1/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit

enum Invitaion: String {
    case all = "All"
    case sent = "Sent"
    case received = "Received"
    case registered = "Registered"
}

protocol InvitationSearchDelegate {
    func reset()
    func didSegmentSelected(type: Invitaion)
    func invitationSearchResult(text: String)
}

class InvitationSearchVC: UIViewController {
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var buttonReset: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    
    var type: Invitaion?
    var selectedIndex = 0
    var delegate: InvitationSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func segmentSelection(_ sender: Any) {
        selectedIndex = segment.selectedSegmentIndex
    }
    
    @IBAction func btnReset(_ sender: Any) {
        selectedIndex = 3
        delegate?.reset()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        if txtField.text!.isEmpty {
            switch segment.selectedSegmentIndex {
            case 0:
                type = .sent
            case 1:
                type = .received
            case 2:
                type = .registered
            default:
                type = .all
            }
            delegate?.didSegmentSelected(type: type ?? .all)
        } else {
            delegate?.invitationSearchResult(text: txtField.text!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
