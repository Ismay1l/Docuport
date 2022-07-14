//
//  DeleteEmployeeViewController.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import UIKit

class DeleteEmployeeViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var onDelete: (() -> Void)?
    
    init() {
        super.init(nibName: "DeleteEmployeeView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }
    
    @IBAction func onCancelTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onDeleteTap(_ sender: Any) {
        print("onDeleteTap")
        onDelete?()
    }
}
