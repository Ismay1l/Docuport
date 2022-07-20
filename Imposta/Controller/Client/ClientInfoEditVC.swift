//
//  ClientInfoEditVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import TagListView
import SVProgressHUD

class ClientInfoEditVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagView: TagListView!
    @IBOutlet weak var photoIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var nameTF: TFLRPadding10!
    @IBOutlet weak var surnameTF: TFLRPadding10!
    @IBOutlet weak var emailTF: TFLRPadding10!
    @IBOutlet weak var phoneNumberTF: TFLRPadding10!
    @IBOutlet weak var surnameView: UIView!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    var client: ResultClients?
    var arrTag = [ClientServiceData]()
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagView.textFont = UIFont(name: "HelveticaNeue", size: 16.0)!
        tagView.delegate = self
        setup()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(gesture:)))
        photoIV.addGestureRecognizer(tapGesture)
        photoIV.isUserInteractionEnabled = true
        
//        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
//        setLogout(view: logoutIcon)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onLogout))
                self.logoutIcon.isUserInteractionEnabled = true
                self.logoutIcon.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func onLogout() {
                print(#function)
                ProfileApi.shared.logoutProfile { result in
                    print(result)
                }
            let appDelegate = AppDelegate()
            appDelegate.setRoot()
    //        setLogout(view: logoutIcon)
            print("gestured used")
        }
}

//Funcs
extension ClientInfoEditVC {
    func setup() {
        client = editClient
        arrTag.removeAll()
        tagView.removeAllTags()
        if let services = client?.services {
            for service in services {
                arrTag.append((service.service)!)
                tagView.addTag((service.service?.name)!)
            }
        }
        if client?.clientType == ClientType.Business.rawValue {
            surnameView.isHidden = true
            surnameView.hideVerticalView()
            nameLbl.text = "Full name"
            nameTF.text = client?.name
        } else {
            nameTF.text = client?.firstName
            surnameTF.text = client?.lastName
        }
        
        emailTF.text = client?.emailAddress
        phoneNumberTF.text = client?.phoneNumber
        if let profileImg = client?.profileImageUrl {
            photoIV.showProfilePic(url: profileImg)
            photoIV.contentMode = .scaleAspectFill
        }
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
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
    }
    
    func camera() {
        self.getImage(fromSourceType: .camera)
    }
    
    func photoLibrary() {
        self.getImage(fromSourceType: .photoLibrary)
    }
    
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func updatePersonalClient() -> Bool {
        if let name = nameTF.text, let surname = surnameTF.text, let phoneNumber = phoneNumberTF.text, let email = emailTF.text, name.count > 0, surname.count > 0, arrTag.count > 0 {
            if email.count > 0 {
                if email.isValidEmail() {
                    client?.firstName = name
                    client?.lastName = surname
                    client?.phoneNumber = phoneNumber
                    client?.emailAddress = email
                    return true
                } else {
                    alert(title: "WARNING", message: "Email address is not valid", actionButton: "OK")
                    return false
                }
            } else {
                client?.firstName = name
                client?.lastName = surname
                client?.phoneNumber = phoneNumber
                client?.emailAddress = email
                return true
            }
        } else {
            alert(title: "WARNING", message: "Please fill in the fields", actionButton: "OK")
            return false
        }
    }
    
    func updateBusinessClient() -> Bool {
        if let name = nameTF.text, let phoneNumber = phoneNumberTF.text, let email = emailTF.text, name.count > 0, arrTag.count > 0 {
            if email.count > 0 {
                if email.isValidEmail() {
                    client?.name = name
                    client?.phoneNumber = phoneNumber
                    client?.emailAddress = email
                    return true
                } else {
                    alert(title: "WARNING", message: "Email address is not valid", actionButton: "OK")
                    return false
                }
            } else {
                client?.name = name
                client?.phoneNumber = phoneNumber
                client?.emailAddress = email
                return true
            }
        } else {
            alert(title: "WARNING", message: "Please fill in the fields", actionButton: "OK")
            return false
        }
    }
    
    func saveClient(clientType: String) {
        SVProgressHUD.show()
        ClientApi.shared.saveClientProfilePic(client!, clientType, photoIV.image!, success: {
            SVProgressHUD.dismiss()
            self.alertWithHandler(title: "SUCCESS", message: "Client information has changed successfully", actionButton: "OK") {
                NotificationCenter.default.post(name: .editClient, object: nil)
                NotificationCenter.default.post(name: .closePopup, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }, failure: { errorMessage in
            SVProgressHUD.dismiss()
            self.alert(title: errorMessage, message: "", actionButton: "OK")
        })
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillShow(noti: Notification) {
        guard let keyboardFrame = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height - 200.0
    }
}

//Toggle
extension ClientInfoEditVC {
    @IBAction func addServiceAction(_ sender: UIButton) {
        if let VC = R.storyboard.advisor.selectServiceVC() {
            VC.client = client
            VC.delegate = self
            let showPopup = SBCardPopupViewController(contentViewController: VC)
            showPopup.show(onViewController: self)
        }
    }

    @IBAction func backBtnAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .closePopup, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        if client?.clientType == ClientType.Business.rawValue {
            if updateBusinessClient() {
                saveClient(clientType: "business")
                
            }
        } else if client?.clientType == ClientType.Personal.rawValue {
            if updatePersonalClient() {
                saveClient(clientType: "personal")
            }
        }
    }
}

extension ClientInfoEditVC: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {}
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        if let idx = self.client?.services?.firstIndex(where: {$0.service?.name == title}) {
            self.arrTag.remove(at: idx)
            self.client?.services?.remove(at: idx)
        }
    }
}

extension ClientInfoEditVC: ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {
        editClient = client
        editClient?.advisor = self.client?.advisor
        setup()
    }
    
    func serviceSelection(clientService: ClientServiceData) {}
}

extension ClientInfoEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) { [weak self] in
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self?.photoIV.image = image.resize()
            self?.photoIV.contentMode = .scaleAspectFill
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
