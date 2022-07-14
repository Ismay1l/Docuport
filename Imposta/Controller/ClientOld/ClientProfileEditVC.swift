//
//  ClientProfileEditVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/15/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import TagListView
import SVProgressHUD

class ClientProfileEditVC: UIViewController {    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet weak var imgCalendar: UIImageView!
    
    @IBOutlet var txtFieldSSN: UITextField!
    @IBOutlet var txtFieldPhoneNumber: UITextField!
    @IBOutlet weak var txtFieldLastname: UITextField!
    @IBOutlet weak var txtFieldFirstname: UITextField!
    
    @IBOutlet weak var lblAdvisor: UILabel!
    @IBOutlet weak var lblServices: UILabel!
    @IBOutlet weak var lblBirthdate: UILabel!
    
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonAdvisor: UIButton!
    @IBOutlet weak var buttonChangePicture: UIButton!

    @IBOutlet weak var tagView: TagListView!

    var count = 0
    var strDate: String?
    var client: ResultClients?
    var advisor: ClientAdvisor?
    var arrTag = [ClientServiceData]()
    var imagePicker: UIImagePickerController!
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openDatePicker))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(birthdate), name: NSNotification.Name(rawValue: "birthdate"), object: nil)
    }
    
    func setup() {
        client = editClient
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        imgCalendar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openDatePicker)))
        
        tagView.delegate = self
        tagView.enableRemoveButton = true
        
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
        if let profileImg = client?.profileImageUrl {
            imgProfile.showProfilePic(url: profileImg)
        }
        
        lblBirthdate.text = client?.birthDate
        lblAdvisor.text = client?.advisor?.fullName
        txtFieldPhoneNumber.text = client?.phoneNumber
        
        if client?.clientType == ClientType.Business.rawValue {
            imgCalendar.isHidden = true
            lblBirthdate.isHidden = true
            txtFieldLastname.isHidden = true
            txtFieldFirstname.text = client?.name
            txtFieldSSN.text = client?.taxpayerIdentificationNumber
        } else {
            imgCalendar.isHidden = false
            lblBirthdate.isHidden = false
            txtFieldLastname.isHidden = false
            txtFieldLastname.text = client?.lastName
            txtFieldFirstname.text = client?.firstName
            txtFieldSSN.text = client?.socialSecurityNumber
        }
        
        arrTag.removeAll()
        tagView.removeAllTags()
        if let services = client?.services {
            for service in services {
                arrTag.append((service.service)!)
                tagView.addTag((service.service?.name)!)
            }
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func birthdate(notification: Notification) {
        let userInfo = notification.userInfo as! [String: String]
        lblBirthdate.text = userInfo["birthdate"]
    }
    
    @objc func openDatePicker() {
        customPresentViewController(presenter, viewController: getVC(id: "BirthdateVC"), animated: true)
    }
    
    @objc func hideKeyboard() {
        txtFieldSSN.resignFirstResponder()
        txtFieldLastname.resignFirstResponder()
        txtFieldFirstname.resignFirstResponder()
        txtFieldPhoneNumber.resignFirstResponder()
    }
    
    func updatePersonalClient() {
        client?.birthDate = lblBirthdate.text
        client?.lastName = txtFieldLastname.text
        client?.firstName = txtFieldFirstname.text
        client?.phoneNumber = txtFieldPhoneNumber.text
        client?.socialSecurityNumber = txtFieldSSN.text
        ClientApi.shared.savePersonalClient(client: client!, success: {
            SVProgressHUD.dismiss()
            self.alertWithHandler(title: "SUCCESS", message: "Client information has changed successfully", actionButton: "OK") {                
                self.dismiss(animated: true, completion: nil)
            }
        }, failure: { errorMessage in
            SVProgressHUD.dismiss()
            self.alert(title: errorMessage, message: "", actionButton: "OK")
        })
    }
    
    func updateBusinessClient() {
        client?.name = txtFieldFirstname.text
        client?.phoneNumber = txtFieldPhoneNumber.text
        client?.taxpayerIdentificationNumber = txtFieldSSN.text
        ClientApi.shared.saveBusinessClient(client: client!, success: {
            SVProgressHUD.dismiss()
            self.alertWithHandler(title: "SUCCESS", message: "Client information has changed successfully", actionButton: "OK") {
                self.dismiss(animated: true, completion: nil)
            }
        }, failure: { errorMessage in
            SVProgressHUD.dismiss()
            self.alert(title: errorMessage, message: "", actionButton: "OK")
        })
    }
    
    func saveClientProfilePic(clientType: String, success: @escaping()->()) {
        ClientApi.shared.saveClientProfilePic(client!, clientType, imgProfile.image!, success: {
            success()
            SVProgressHUD.dismiss()
        }, failure: { errorMessage in 
            SVProgressHUD.dismiss()
            self.alert(title: errorMessage, message: "", actionButton: "OK")
        })
    }
    
    func camera() {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func photoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnChangePicture(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.camera()
        })
        
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.photoLibrary()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func btnEditAdvisor(_ sender: Any) {
        let advisorVC = getVC(id: "AdvisorListVC") as! AdvisorListVC
        advisorVC.delegate = self
        show(advisorVC, sender: nil)
    }
    
    @IBAction func btnAddServices(_ sender: Any) {
        let serviceVC = getVC(id: "ServiceListVC") as! ServiceListVC
        serviceVC.client = client
        serviceVC.delegate = self
        show(serviceVC, sender: nil)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        if !txtFieldSSN.text!.isEmpty {
            SVProgressHUD.show()
            if client?.clientType == ClientType.Business.rawValue {
                saveClientProfilePic(clientType: "business") {
                    self.updateBusinessClient()
                }
            } else {
                saveClientProfilePic(clientType: "personal") {
                    self.updatePersonalClient()
                }
            }
        } else {
            alert(title: "Please, enter Social Security Number", message: "", actionButton: "OK")
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ClientProfileEditVC: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {}
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if let idx = self.client?.services?.firstIndex(where: {$0.service?.name == title}) {
            self.arrTag.remove(at: idx)
            self.client?.services?.remove(at: idx)
        }
    }
}

extension ClientProfileEditVC: AdvisorListDelegate {
    func advisorSelection(advisor: ClientAdvisor) {
        editClient?.advisor = advisor
        self.advisor = advisor
        self.lblAdvisor.text = self.advisor?.fullName
    }
}

extension ClientProfileEditVC: ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {
        editClient = client
        editClient?.advisor = self.client?.advisor //if advisor change is called first, advisor object will bi nil after service change happened
        setup()
    }
    
    func serviceSelection(clientService: ClientServiceData) {}
}

extension ClientProfileEditVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension ClientProfileEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imgProfile.image = img?.resize()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
