//
//  ProfileOldVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class ProfileOldVC: UIViewController {
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var buttonChangeProfilePicture: UIButton!
    @IBOutlet var txtFieldFirstName: UITextField!
    @IBOutlet var txtFieldLastName: UITextField!
    @IBOutlet var txtFieldPhone: UITextField!
    @IBOutlet var txtFieldExtension: UITextField!
    @IBOutlet weak var lblExtensionTitle: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblRole: UILabel!
    @IBOutlet var lblInviter: UILabel!
    @IBOutlet var lblInviterTitle: UILabel!
    @IBOutlet var buttonSave: UIButton!
    @IBOutlet weak var buttonUpdateProfile: UIBarButtonItem!
    
    @IBOutlet var extensionTopConstraint: NSLayoutConstraint!
    @IBOutlet var extensionHeightConstraint: NSLayoutConstraint!
    
    var user: AuthUser?
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        getUserProfile()
        addMenuNavButton()
        
        user = AuthUser()
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
        disableProfileUpdate()
    }
    
    @objc func closeKeyboard() {
        txtFieldPhone.resignFirstResponder()
        txtFieldLastName.resignFirstResponder()
        txtFieldFirstName.resignFirstResponder()
        txtFieldExtension.resignFirstResponder()
    }
    
    func disableProfileUpdate() {
        buttonSave.isHidden = true
        buttonChangeProfilePicture.isHidden = true
        
        imgProfile.layer.cornerRadius = 50
        
        txtFieldPhone.isEnabled = false
        txtFieldLastName.isEnabled = false
        txtFieldFirstName.isEnabled = false
        txtFieldExtension.isEnabled = false
    }
    
    func enableProfileUpdate() {
        buttonSave.isHidden = false
        if UI_USER_INTERFACE_IDIOM() == .pad {
            buttonChangeProfilePicture.isHidden = true
        } else {
            buttonChangeProfilePicture.isHidden = false
        }
        
        imgProfile.layer.cornerRadius = 20
        
        txtFieldPhone.isEnabled = true
        txtFieldLastName.isEnabled = true
        txtFieldFirstName.isEnabled = true
        txtFieldExtension.isEnabled = true
    }
    
    func getUserProfile() {
        SVProgressHUD.show()
        AppApi.shared.getUserProfile(success: { response in
            //profile pic will be added
            self.lblRole.text = response.result?.role
            self.lblEmail.text = response.result?.emailAddress
            self.txtFieldPhone.text = response.result?.phoneNumber
            self.txtFieldLastName.text = response.result?.lastName
            self.txtFieldFirstName.text = response.result?.firstName
            self.imgProfile.showProfilePic(url: response.result?.profilePictureUrl ?? "")
            UserDefaultsHelper.shared.setUserProfileImageUrl(url: response.result?.profilePictureUrl ?? "")
            
            if GetUserType.user.isUserAdvisor() {
                self.lblInviter.isHidden = true
                self.lblInviterTitle.isHidden = true
                self.txtFieldExtension.text = "\(response.result?.internalPhoneNumber ?? "")"
                
            } else { //client. employee doesn't have profile page
                self.lblExtensionTitle.isHidden = true
                self.extensionTopConstraint.constant = 0
                self.extensionHeightConstraint.constant = 0
                self.lblInviter.text = response.result?.inviter
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
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
    
    @IBAction func btnUpdateProfile(_ sender: Any) {
        enableProfileUpdate()
    }
    
    @IBAction func btnChangeProfilePicture(_ sender: Any) {
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
    
    @IBAction func btnSave(_ sender: Any) {
        user?.firstName = txtFieldFirstName.text
        user?.lastName = txtFieldLastName.text
        user?.phoneNumber = txtFieldPhone.text
        if GetUserType.user.isUserAdvisor() {
            user?.internalPhoneNumber = txtFieldExtension.text
        }
        if txtFieldPhone.text!.count > 12 {
            alert(title: "Phone number length cannot be more than 12 characters", message: "", actionButton: "OK")
        } else {
            SVProgressHUD.show()
            AppApi.shared.updateProfile(user: user!, profilePic: imgProfile.image ?? UIImage(), success: {
                self.disableProfileUpdate()
                self.getUserProfile()
                self.alert(title: "SUCCESS", message: "Your profile update has done", actionButton: "OK")
                SVProgressHUD.dismiss()
            }, failure: {
                self.alert(title: "ERROR", message: "Please make sure you entered information correctly", actionButton: "OK")
                SVProgressHUD.dismiss()
            })
        }
    }
}

extension ProfileOldVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imgProfile.image = img?.resize()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileOldVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
