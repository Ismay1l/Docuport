//
//  CommentViewController.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var onSave: ((String) -> Void)?
    
    init() {
        super.init(nibName: "CommentView", bundle: nil)
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
        popupView.backgroundColor = .mainColor
    }
    
    @IBAction func onCancelTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onSaveTap(_ sender: Any) {
        let textCount = commentTextField.text?.count ?? 0
        if textCount > 300 {
            self.alert(title: "Message", message: "Comment cannot exceed 300 characters", actionButton: "OK")
            return
        }
        
        let commentText = commentTextField.text ?? ""
        onSave?(commentText)
    }
}
