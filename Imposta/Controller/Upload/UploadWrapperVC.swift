//
//  UploadWrapperVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class UploadWrapperVC: ButtonBarPagerTabStripViewController, SBCardPopupContent {
    
    @IBOutlet weak var clientButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var servicesButton: UIButton!
    @IBOutlet weak var tagsButton: UIButton!
    
    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = false
    var allowsSwipeToDismissPopupCard = false
    
    public var clientId: Int?
    var uploadClientListVC: UploadClientListVC?
    var uploadServiceListVC: UploadServiceListVC?
    var uploadDescriptionVC: UploadDescriptionVC?
    var uploadTagsVC: UploadTagsVC?
    
    var activeDescriptionButton = false
    
    let buttonColor = UIColor.init(hexString: "#0093FF")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientButton.backgroundColor = .clear

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

        guard changeCurrentIndex == true else {return}
            oldCell?.label.textColor = .white
            newCell?.label.textColor = .white
        }
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        uploadClientListVC = R.storyboard.advisor.uploadClientListVC()
        uploadClientListVC?.delegate = self
        uploadServiceListVC = R.storyboard.advisor.uploadServiceListVC()
        uploadServiceListVC?.delegate = self
        uploadTagsVC = initController(with: "Main", withIdentifier: "UploadTagsVC") as? UploadTagsVC
        uploadTagsVC?.tagsDelegate = self
        uploadDescriptionVC = R.storyboard.advisor.uploadDescriptionVC()
        return [uploadClientListVC!, uploadServiceListVC!, uploadTagsVC!, uploadDescriptionVC!,]
    }
    
    func onTags() {
        tagsButton.backgroundColor = .clear
        clientButton.backgroundColor = buttonColor
        servicesButton.backgroundColor = buttonColor
        descriptionButton.backgroundColor = buttonColor
        moveTo(viewController: uploadTagsVC!)
    }
    
    @IBAction func btnsAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            clientButton.backgroundColor = .clear
            servicesButton.backgroundColor = buttonColor
            descriptionButton.backgroundColor = buttonColor
            tagsButton.backgroundColor = buttonColor
            
            moveTo(viewController: uploadClientListVC!)
        case 1:
            if (clientId != nil) {
                servicesButton.backgroundColor = .clear
                clientButton.backgroundColor = buttonColor
                descriptionButton.backgroundColor = buttonColor
                tagsButton.backgroundColor = buttonColor
                
                DocumentSingleton.shared.clientId = clientId
                uploadServiceListVC!.clientId = clientId
                moveTo(viewController: uploadServiceListVC!)
            } else {
                self.alert(title: "WARNING", message: "Services Required", actionButton: "OK")
            }
        case 2:
            if uploadTagsVC?.serviceId != -1 {
                onTags()
            } else {
                self.alert(title: "WARNING", message: "Services Required", actionButton: "OK")
            }
        case 3:
            if (clientId != nil && activeDescriptionButton) {
                clientButton.backgroundColor = buttonColor
                servicesButton.backgroundColor = buttonColor
                tagsButton.backgroundColor = buttonColor
                descriptionButton.backgroundColor = .clear
                moveTo(viewController: uploadDescriptionVC!)
            } else {
                self.alert(title: "WARNING", message: "Client and Services Required", actionButton: "OK")
            }
        default:
            break
        }
    }
    
}

extension UploadWrapperVC: DocumentClientDelegate {
    func showServiceList(clientId: Int) {
        SVProgressHUD.show()
        
        DocumentApi.shared.saveDocumentClient(clientId: clientId,
         success: {
            self.clientId = clientId
            
            self.clientButton.backgroundColor = self.buttonColor
            self.servicesButton.backgroundColor = .clear
            self.descriptionButton.backgroundColor = self.buttonColor
            DocumentSingleton.shared.clientId = clientId
            self.uploadServiceListVC!.clientId = clientId
            self.moveTo(viewController: self.uploadServiceListVC!)
             SVProgressHUD.dismiss()
            
         }, failure: {
             SVProgressHUD.dismiss()
             self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
         })
    }
}

extension UploadWrapperVC: UploadTagsDelegate {
    func selectedTags(tags: [Int]) {
        guard let docId = editDocument?.id else { return }
        let params = TagsOfDocumentParams(id: docId, tags: tags)

        SVProgressHUD.show()
        DocumentApi.shared.saveDocumentTags(params: params, success: { [weak self] in
            self?.showDesc(active: true)
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Couldn't add document", actionButton: "OK")
        })
    }
}

extension UploadWrapperVC: DocumentRelatedDelegate {
    func showTags() {
        SVProgressHUD.show()
        DocumentApi.shared.saveDocumentClientService(docId: editDocument?.id ?? -1, serviceId: DocumentSingleton.shared.serviceId ?? -1, success: { [weak self] in
            self?.uploadTagsVC?.serviceId = DocumentSingleton.shared.serviceId ?? -1
            self?.onTags()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
        })
    }
    
    func showDesc(active: Bool) {
        self.activeDescriptionButton = active
        self.clientButton.backgroundColor = self.buttonColor
        self.servicesButton.backgroundColor = self.buttonColor
        self.tagsButton.backgroundColor = self.buttonColor
        self.descriptionButton.backgroundColor = .clear
        self.moveTo(viewController: self.uploadDescriptionVC!)
    }
}
