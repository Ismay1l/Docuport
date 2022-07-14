//
//  DocumentEditVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class DocumentEditVC: ButtonBarPagerTabStripViewController {
    @IBOutlet weak var buttonSave: UIButton!
    
    public var clientId: Int?
    var descVC: DocumentDescVC?
    var clientListVC: DocumentClientListVC?
    var serviceListVC: DocumentServicesVC?
    var relatedDocsVC: DocumentRealtedDocsVC?
    
    override func viewDidLoad() {
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarItemTitleColor = #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1)
        settings.style.selectedBarBackgroundColor = #colorLiteral(red: 0.2666666667, green: 0.7294117647, blue: 0.5450980392, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        super.viewDidLoad()
        
        buttonBarView.backgroundColor = .clear
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        clientListVC = getVC(id: "DocumentClientListVC") as? DocumentClientListVC
        clientListVC?.delegate = self
        
        serviceListVC = getVC(id: "DocumentServicesVC") as? DocumentServicesVC
        serviceListVC?.delegate = self
        
        relatedDocsVC = getVC(id: "DocumentRealtedDocsVC") as? DocumentRealtedDocsVC
        relatedDocsVC?.delegate = self
        
        descVC = getVC(id: "DocumentDescVC") as? DocumentDescVC
        
        return [clientListVC!, serviceListVC!, relatedDocsVC!, descVC!]
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension DocumentEditVC: DocumentClientDelegate {
    func showServiceList(clientId: Int) {
        self.clientId = clientId
        DocumentSingleton.shared.clientId = clientId
        serviceListVC!.clientId = clientId
        moveTo(viewController: serviceListVC!)
    }
}

extension DocumentEditVC: DocumentServiceDelegate {
    func showRelatedDocs() {
        relatedDocsVC?.clientId = clientId
        DocumentSingleton.shared.clientId = clientId
        moveTo(viewController: relatedDocsVC!)
    }
}

extension DocumentEditVC: DocumentRelatedDelegate {
    func showDesc(active: Bool) {
        moveTo(viewController: descVC!)
    }
}

