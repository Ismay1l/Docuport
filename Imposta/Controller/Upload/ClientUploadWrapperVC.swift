//
//  ClientUploadWrapperVC.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 20.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class ClientUploadWrapperVC: ButtonBarPagerTabStripViewController, SBCardPopupContent {
    
    @IBOutlet weak var servicesButton: UIButton!
    @IBOutlet weak var tagsButton: UIButton!
    
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = false
    var allowsSwipeToDismissPopupCard = false
    var serviceSaved = false
    
    var documentId: Int?
    var uploadServicesClientVC: UploadServicesClientVC?
    var uploadTagsVC: UploadTagsVC?
        
    let buttonColor = UIColor.init(hexString: "#0093FF")
    
    weak var clientDelegate: ClientUploadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings.style.buttonBarBackgroundColor =  .red//UIColor(red: 35/255, green: 171/255, blue: 250/255, alpha: 1.0)
        settings.style.buttonBarItemBackgroundColor = .clear// UIColor(red: 35/255, green: 171/255, blue: 250/255, alpha: 1.0)

        settings.style.buttonBarItemFont = .systemFont(ofSize: 16.0)
        settings.style.selectedBarHeight = 0
        settings.style.selectedBarBackgroundColor = UIColor.red
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        //       settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        buttonBarView.selectedBar.backgroundColor = UIColor.white
        buttonBarView.backgroundColor = UIColor(red: 35/255, green: 171/255, blue: 250/255, alpha: 1.0)
        changeCurrentIndexProgressive = {[weak self](oldCell:ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage:CGFloat, changeCurrentIndex:Bool, animated:Bool)-> Void in
            
        self?.containerView.isScrollEnabled = false

        guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .white
            newCell?.label.textColor = .white
        }
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        uploadServicesClientVC = R.storyboard.client.uploadServicesClientVC()
        uploadServicesClientVC?.delegate = self
        uploadTagsVC = initController(with: "Main", withIdentifier: "UploadTagsVC") as? UploadTagsVC
        uploadTagsVC?.tagsDelegate = self
        return [uploadServicesClientVC!, uploadTagsVC!]
    }
    
    func onClientService() {
        tagsButton.backgroundColor = buttonColor
        servicesButton.backgroundColor = .clear
        moveTo(viewController: uploadServicesClientVC!)
    }
    
    func onTags() {
        tagsButton.backgroundColor = .clear
        servicesButton.backgroundColor = buttonColor
        moveTo(viewController: uploadTagsVC!)
    }
    
    @IBAction func btnsAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            onClientService()
        case 1:
            if serviceSaved {
                onTags()
            }
        default:
            break
        }
    }
}

extension ClientUploadWrapperVC: ServiceListDelegate {
    func serviceSelection(clientService: ClientServiceData) {
        guard let docId = documentId else { return }
        
        SVProgressHUD.show()
        DocumentApi.shared.saveDocumentClientService(docId: docId, serviceId: clientService.id!, success: { [weak self] in
            self?.serviceSaved = true
            self?.uploadTagsVC?.serviceId = clientService.id
            self?.onTags()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
        })
    }
}

extension ClientUploadWrapperVC: UploadTagsDelegate {
    func selectedTags(tags: [Int]) {
        guard let docId = documentId else { return }
        let params = TagsOfDocumentParams(id: docId, tags: tags)

        SVProgressHUD.show()
        DocumentSingleton.shared.isFileIploaded = true
        DocumentApi.shared.saveDocumentTags2(docId: docId,params: params, success: { [weak self] in
            SVProgressHUD.dismiss()
            self?.documentUploaded()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Couldn't add document", actionButton: "OK")
        })
    }
    
    private func documentUploaded() {
        self.alertWithHandler(title: "SUCCESS", message: "Document has successfully saved", actionButton: "OK") {
            NotificationCenter.default.post(name: .documentSaved, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
