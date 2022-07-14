//
//  DocumentCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

protocol DocumentCellDelegate {
    func setDocumentStatus(documentId: Int, status: DocumentStatusValue)
}

class DocumentCell: UITableViewCell {
    @IBOutlet weak var lblDocumentId: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAccountName: UILabel!
    @IBOutlet weak var lblDocumentService: UILabel!
    @IBOutlet weak var viewServiceColor: UIView!    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var viewStatus: UIStackView!
    @IBOutlet weak var statusViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewInProgress: UIView!
    @IBOutlet weak var viewOpen: UIView!
    @IBOutlet weak var viewDone: UIView!
    
    var document: ResultDocument?
    var delegate: DocumentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.setViewShadow()
        viewServiceColor.roundCorners(corners: [.bottomRight, .topRight], radius: 10.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadData(document: ResultDocument, documentType: DocumentType) {
        self.document = document
        statusViewLeadingConstraint.constant = frame.width * 2
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(openStatusView))
        swipeGesture.direction = .left
        
        if GetUserType.user.isUserAdvisor() || GetUserType.user.isUseEmployeeAdvisor() {
            if documentType == .inbox {
                viewServiceColor.isHidden = false
                view.addGestureRecognizer(swipeGesture)
                viewOpen.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setDocumentStatus)))
                viewDone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setDocumentStatus)))
                viewInProgress.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setDocumentStatus)))
            } else {
                viewServiceColor.isHidden = true
                view.gestureRecognizers?.removeAll()
            }
        } else {
            if documentType == .inbox {
                viewServiceColor.isHidden = true
            } else {
                viewServiceColor.isHidden = false
            }
            view.gestureRecognizers?.removeAll()
        }
        
        viewServiceColor.roundCorners(corners: [.topRight, .bottomRight], radius: 5)
        
        
        if document.status == DocumentStatusValue.inProgress.rawValue {
            viewServiceColor.backgroundColor = UIColor(hexStr: "237FEF", colorAlpha: 1) //blue
        } else if document.status == DocumentStatusValue.open.rawValue {
            viewServiceColor.backgroundColor = UIColor(hexStr: "969696", colorAlpha: 1) //gray
        } else if document.status == DocumentStatusValue.done.rawValue {
            viewServiceColor.backgroundColor = UIColor(hexStr: "63D66B", colorAlpha: 1) //green
        } else if document.status == DocumentStatusValue.draft.rawValue {
            viewServiceColor.backgroundColor = UIColor(hexStr: "E15151", colorAlpha: 1) //red
        }
        
        lblDate.text = document.creationTime
        lblDocumentId.text = document.docNumber
        lblAccountName.text = document.client?.name
        lblDocumentService.text = document.name
    }
    
    @objc func openStatusView(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            statusViewLeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else if gesture.direction == .right {
            statusViewLeadingConstraint.constant = self.frame.width * 2
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc func setDocumentStatus(gesture : UITapGestureRecognizer) {
        let tag = gesture.view?.tag
        if tag == 0 {
            delegate?.setDocumentStatus(documentId: (document?.id)!, status: .inProgress)
        } else if tag == 1 {
            delegate?.setDocumentStatus(documentId: (document?.id)!, status: .open)
        } else if tag == 2 {
            delegate?.setDocumentStatus(documentId: (document?.id)!, status: .done)
        }
        
        statusViewLeadingConstraint.constant = self.frame.width + 20
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
