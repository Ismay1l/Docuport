//
//  LeftMenuVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/30/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import Presentr

protocol LeftMenuVCDelegate {
    func openVC(vc: UIViewController)
}

class LeftMenuVC: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonLogout: UIButton!
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var imgBlur: UIImageView!
    
    let user = "client"
    var blurImg = UIImage()
    
    let userType = GetUserType()
    var delegate: LeftMenuVCDelegate!
    
    var arrList = [String]()
    var arrAdvisor = ["Documents", "Clients", "Downloads"]
    var arrClient = ["Documents", "Invitations", "Downloads"]
    var arrEmployee = ["Documents", "Downloads"]
    
    let presenterSwitch: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.dismissOnSwipe = true
        presenter.blurBackground = true
        presenter.dismissAnimated = true
        presenter.presentationType = .fullScreen
        presenter.transitionType = .coverVertical
        presenter.dismissTransitionType = .crossDissolve
        return presenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        imgBlur.image = blurImg
        imgBlur.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
    }
    
    override func viewWillLayoutSubviews() {
        viewBackground.roundCorners(corners: [.bottomRight, .topRight], radius: 30.0)
    }
    
    func setup() {
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
        imgProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        lblFullname.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        
        lblFullname.text = UserDefaultsHelper.shared.getFullname()
        imgProfile.showProfilePic(url: UserDefaultsHelper.shared.getUserProfileImageUrl())
        
        if GetUserType.user.isUserAdvisor() {
            arrList = arrAdvisor
            buttonSwitch.isHidden = true
        } else if GetUserType.user.isUserClient() {
            arrList = arrClient
            buttonSwitch.isHidden = false
        } else {
            //
            buttonSwitch.isHidden = true
        }
    }
    
    @objc func closeMenu() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func openProfile() {
        dismiss(animated: true, completion: nil)
        delegate.openVC(vc: getVC(id: "ProfileOldVC"))
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        let appDelegate = AppDelegate()
        appDelegate.setRoot()
    }
    
    @IBAction func btnSwitch(_ sender: Any) {
        let switchVC = storyboard?.instantiateViewController(withIdentifier: "SwitchVC") as! SwitchVC
        customPresentViewController(presenterSwitch, viewController: switchVC, animated: true)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LeftMenuVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell") as! LeftMenuCell
        
        cell.lblTitle.text = arrList[indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaultsHelper.shared.setIndex(index: indexPath.item)
        
        let cell = tableView.cellForRow(at: indexPath) as! LeftMenuCell
        cell.viewLine.isHidden = false
        cell.lblTitle.textColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        cell.lblTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        
        if GetUserType.user.isUserClient() {
            if indexPath.row == 0 {
                delegate.openVC(vc: getVC(id: "DocumentsOldVC"))
            } else if indexPath.row == 1 {
                delegate.openVC(vc: getVC(id: "InvitationsVC"))
            } else {
                delegate.openVC(vc: getVC(id: "DownloadVC"))
            }
        } else if GetUserType.user.isUserAdvisor() { //advisor
            if indexPath.row == 0 {
                delegate.openVC(vc: getVC(id: "DocumentsOldVC"))
            } else if indexPath.row == 1 {
                delegate.openVC(vc: getVC(id: "ClientVC"))
            } else {
                delegate.openVC(vc: getVC(id: "DownloadVC"))
            }
        } else {
            if indexPath.row == 0 {
                delegate.openVC(vc: getVC(id: "DocumentsOldVC"))
            } else {
                delegate.openVC(vc: getVC(id: "DownloadVC"))
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
