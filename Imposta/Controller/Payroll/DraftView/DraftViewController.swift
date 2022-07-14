//
//  DraftViewController.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class DraftViewController: UIViewController {
    @IBOutlet weak var popUpView: UIView!
    
    init() {
        super.init(nibName: "DraftView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
    }
}
