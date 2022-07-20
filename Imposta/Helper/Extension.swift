//
//  Extension.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import Presentr
import Foundation
import SDWebImage
import SystemConfiguration


let presenter: Presentr = {
    let presenter = Presentr(presentationType: .alert)
    presenter.dismissOnSwipe = true
    presenter.blurBackground = true
    presenter.dismissAnimated = true
    presenter.presentationType = .fullScreen
    presenter.transitionType = .crossDissolve
    presenter.dismissTransitionType = .crossDissolve
    return presenter
}()

let presentrLeftMenu: Presentr = {
    let presenter = Presentr(presentationType: .fullScreen)
    presenter.blurStyle = .dark
    presenter.dismissOnSwipe = true
    presenter.blurBackground = true
    presenter.dismissAnimated = true
    presenter.transitionType = .coverHorizontalFromLeft
    presenter.dismissTransitionType = .coverHorizontalFromLeft
    return presenter
}()

extension UIViewController {
    func getVC(id: String, storyboard: String = "Main") -> UIViewController {
        let s = UIStoryboard.init(name: storyboard, bundle: nil)
        return s.instantiateViewController(withIdentifier: id)
    }
    
    func getNav(id: String, storyboard: String = "Main") -> UINavigationController {
        let s = UIStoryboard.init(name: storyboard, bundle: nil)
        return s.instantiateViewController(withIdentifier: id) as! UINavigationController
    }
    
    func presentVC(id: String, storyboard: String = "Main", animate: Bool = true) {
        present(getVC(id: id, storyboard: storyboard), animated: animate, completion: nil)
    }
    
    func showVC(id: String) {
        show(getVC(id: id, storyboard: "Main"), sender: nil)
    }
    
    func showNav(id: String) {
        show(getNav(id: id, storyboard: "Main"), sender: nil)
    }
    
    func presentNavFullScreen(id: String) {
        let nav = getNav(id: id, storyboard: "Main")
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func presentNavFullScreen1(id: String) {
        let nav = getNav(id: id, storyboard: "Advisor")
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func showVCStoryboardId(id: String, storyboard: String = "Main") {
        show(self.getVC(id: id, storyboard: storyboard), sender: nil)
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func makePartOfStringBold(withString string: String, boldString: String, font: UIFont, boldFont: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: boldFont]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        
        return attributedString
    }
    
    func changeColorOfPartOfString(text: String, colorText: String, colorCode: String) -> NSAttributedString {
        let range = (text as NSString).range(of: colorText)
        
        let attributeString = NSMutableAttributedString.init(string: text)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexStr: colorCode, colorAlpha: 1) , range: range)
        
        return attributeString
    }
    
    func setViewShadow(view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        view.layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: shadowColorAlpha).cgColor
    }
    
    func alert(title: String, message: String, actionButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
        alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithCustomSize(title: String, message: String, actionButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
        alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithHandler(title: String, message: String, actionButton: String, handler:@escaping ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
        alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: { (action) in
            handler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithHandlerAction(title: String, message: String, acceptButton: String, cancelButton: String, accept:@escaping ()->Void, cancel:@escaping ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptButton, style: .default, handler: { (action) in
            accept()
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .default, handler: { (action) in
            cancel()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertTitleFontAndSpaceSize(message: String) -> NSMutableAttributedString {
        let msgAttr = NSMutableAttributedString(string: message)
        msgAttr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium),
                             range: NSMakeRange(0, msgAttr.length))
        
        return msgAttr
    }
    
    func alertMessageFontAndSpaceSize(message: String) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        paragraph.alignment = NSTextAlignment.center
        
        let msgAttr = NSMutableAttributedString(string: message)
        msgAttr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
                             range: NSMakeRange(0, msgAttr.length))
        
        msgAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, msgAttr.length))
        
        return msgAttr
    }
    
    func currencyFormatSetup() -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 3
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.locale = Locale(identifier: "tr_TR")
        
        return currencyFormatter
    }
    
    func dateSetup(dayCount: Int) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let tomorrow = Calendar.current.date(byAdding: .day, value: dayCount, to: date)
        
        return dateFormatter.string(from: tomorrow!)
    }
    
    func getLastDayCountdown(lastDate: String) -> Int {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "tr_TR")
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let today = Date()
        let date = calendar.startOfDay(for: dateFormatter.date(from: lastDate)!)
        let components = calendar.dateComponents([.day], from: today, to: date)
        
        return components.day! //calendar.component(.day, from: dateStart!)
    }
    
    func addMenuNavButton() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "hamburgerMenu"), style: .plain, target: self, action: #selector(openLeftMenu))
        menuButton.tintColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func addSearchNavButton() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(openSearch))
        menuButton.tintColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc func openSearch() {
        var vc: UIViewController?
        switch searchType {
        case .clients:
            vc = getVC(id: "ClientSearchVC")
        case .documents:
            vc = getVC(id: "DocumentSearchVC")
        case .downloads:
            vc = getVC(id: "")
        case .invitations:
            vc = getVC(id: "InvitationsVC")
        case .accounts:
            vc = getVC(id: "AccountsOldVC")
        }
        
        customPresentViewController(presenter, viewController: vc!, animated: true)
    }
    
    @objc func openLeftMenu() {
        let leftMenuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuVC") as! LeftMenuVC
        leftMenuVC.delegate = self
        //leftMenuVC.blurImg = addBlurTo(takeScreenshot())!
//        leftMenuVC.modalPresentationStyle = .custom
//        leftMenuVC.transitioningDelegate = self
//        present(leftMenuVC, animated: true, completion: nil)
        customPresentViewController(presentrLeftMenu, viewController: leftMenuVC, animated: true)
    }
    
    func addBlur() {
        view.addSubview(setBlur())
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.addSubview(setBlur())
        navigationController?.navigationBar.sendSubviewToBack(setBlur())
    }
    
    func setBlur() -> UIView {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }
    
    func takeScreenshot() -> UIImage {
        if let layer = UIApplication.shared.keyWindow?.layer {
            UIGraphicsBeginImageContext(layer.frame.size)
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    func addBlurTo(_ image: UIImage) -> UIImage? {
        if let ciImg = CIImage(image: image) {
            ciImg.applyingFilter("CIGaussianBlur")
            return UIImage(ciImage: ciImg)
        }
        return nil
    }
    
    func addTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeKeyboard)))
    }
    
    @objc func removeKeyboard() {
        for vw in view.subviews {
            if vw.isKind(of: UITextField.self) {
                vw.resignFirstResponder()
            }
        }
    }
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func temporaryFileDestination(fileName: String) -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
    }
    
    func downloadedFileDestination(fileName: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName)")
    }
    
    @objc func onHome() {
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

extension UIViewController: LeftMenuVCDelegate, UIViewControllerTransitioningDelegate {
    func openVC(vc: UIViewController) {
        navigationController?.show(vc, sender: nil)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftMenuPresentAnimationController(originFrame: CGRect(x: 0-view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LeftMenuDismissAnimationController(destinationFrame: CGRect(x: 0-view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height))
    }
}

extension UICollectionViewCell {
    func setCellShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: shadowColorAlpha).cgColor
    }
}

extension UITableViewCell {
    func setCellShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: shadowColorAlpha).cgColor
    }
}

extension UIView {
    func setViewShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.35
        self.layer.shadowOffset = CGSize(width: 3, height: shadowHeight)
        self.layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: shadowColorAlpha).cgColor
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension String {
    
    func removeSpaceInString() -> String {
        return self.lowercased().replacingOccurrences(of: " ", with: "")
    }
    
    func removePercentageInString() -> String {
        return self.lowercased().replacingOccurrences(of: "%", with: "")
    }
    
    func removeCharacterInString() -> String {
        return self.lowercased().replacingOccurrences(of: "-", with: "")
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
    
    var myFloatConverter: Float {
        let converter = NumberFormatter()
        
        converter.decimalSeparator = "."
        if let result = converter.number(from: self) {
            return result.floatValue
        }
        
        return 0
    }
    
    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        return formatter.string(from: date)
    }
}

extension UIImageView {
    func showProfilePic(url: String) {
        if !url.isEmpty {
            let manager = SDWebImageDownloader()
            manager.setValue("Bearer \(UserDefaultsHelper.shared.getToken())", forHTTPHeaderField: "Authorization")
            manager.downloadImage(with: URL(string: url)!) { (image, data, error, bool) in
                if let img = image {
                    self.image = img
                }
            }
        }
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resize() -> UIImage {
        var actualHeight = Float(self.size.height)
        var actualWidth = Float(self.size.width)
        let maxHeight: Float = 1920
        let maxWidth: Float = 1080
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        var compressionQuality: Float = 0.1
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
}


extension Notification.Name {
    static let changeAccount = Notification.Name("changeAccount")
    static let closePopup = Notification.Name("closePopup")
    static let editClient = Notification.Name("editClient")
    static let documentSaved = Notification.Name("documentSaved")
}
