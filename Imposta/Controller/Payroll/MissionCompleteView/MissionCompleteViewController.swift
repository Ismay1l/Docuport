//
//  MissionCompleteView.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class MissionCompleteViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    
    init() {
        super.init(nibName: "MissionCompleteView", bundle: nil)
    }
    
    lazy var onDismiss: (() -> Void) = { [weak self] in self?.dismiss(animated: true, completion: nil) }
    
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
        popupView.backgroundColor = .mainColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.onDismiss()
        }
    }
}
