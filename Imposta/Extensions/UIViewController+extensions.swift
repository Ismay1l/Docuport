//
//  UIApplication+extensions.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 05.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import QuickLook

extension UIViewController {
    func tryUrl(with url: String) {
        let validUrl = URL(string: url)!
        
        if UIApplication.shared.canOpenURL(validUrl) {
            UIApplication.shared.open(validUrl)
        }
    }
    
    func convertBase64StringToImage (imageBase64String: String, mode: UIImage.RenderingMode = .alwaysOriginal) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)?.withRenderingMode(mode)
        if image != nil {
            return image!
        } else {
            return R.image.emptyIcon()!
        }
    }
    
    func initController(with name: String, withIdentifier identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        return controller
    }
    
    func onDocuments(service: HomePageService, tagId: Int = -1) {
            if let VC = R.storyboard.main.documentsVC() {
                if service.isMyUploads ?? false {
                    documentType = .outbox
                } else {
                    documentType = .inbox
                    VC.serviceId = service.id
                    VC.tagId = tagId
                }
                VC.pageTitle = service.displayName
                
                if let navController = self.navigationController {
                    navController.pushViewController(VC, animated: true)
                } else {
                    VC.modalPresentationStyle = .fullScreen
                    self.present(VC, animated: true)
                }
            }
        }
    
//    func onDocuments(service: HomePageService, tagId: Int = -1) {
//        if let VC = R.storyboard.main.documentsVC() {
//            if service.isMyUploads ?? false {
//                documentType = .outbox
//            } else {
//                documentType = .inbox
//                VC.serviceId = service.id
//                VC.tagId = tagId
//            }
//            VC.pageTitle = service.displayName
//            
//            if let navController = self.navigationController {
//                navController.pushViewController(VC, animated: true)
//            } else {
//                VC.modalPresentationStyle = .fullScreen
//                self.present(VC, animated: true)
//            }
//        }
//    }
    
    func myUploads() {
        if let VC = R.storyboard.main.documentsVC() {
            var uploads: MyUploadsResponse?
            documentType = .inbox
            ProfileApi.shared.getMyUploads { response in
                print(response)
                uploads = response
            } failure: { string in
                print(string)
            }
            VC.pageTitle = "My Uploads"
            VC.myUploads = uploads
            if let navController = self.navigationController {
            navigationController?.pushViewController(VC, animated: true)
            } else {
                VC.modalPresentationStyle = .fullScreen
                self.present(VC, animated: true)
            }
        }
    }

    
    func onBack() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setRoot() {
        if let window = UIApplication.shared.keyWindow {
            let controller = UINavigationController(rootViewController: self)
            controller.setNavigationBarHidden(true, animated: false)
            window.rootViewController = controller
            window.makeKeyAndVisible()
        }
    }
    
    func clearAllFile() {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("Directory: \(paths)")
        do {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            for file in fileName {
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func shareFile(_ file: ResultDocument) {
        if let fileName = file.attachment?.genFileName {
            let path = self.downloadedFileDestination(fileName: fileName)
            if FileManager.default.fileExists(atPath: path.path) {
                self.alert(title: "WARNING", message: "The file already exists at path", actionButton: "OK")
            } else {
                SVProgressHUD.show()
                AppApi.shared.downloadImage(fileName, success: { data in
                    SVProgressHUD.dismiss()
                    
                    try! data.write(to: path, options: .atomic)
                    
                    let appDelegate = AppDelegate()
                    if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
                        appDelegate.saveFile(type: .outbox, document: file, path: path.path)
                    } else {
                        appDelegate.saveFile(type: .inbox, document: file, path: path.path)
                    }
                    
                    let fm = FileManager.default
                    
                    var pdfURL = (fm.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                    pdfURL = pdfURL.appendingPathComponent(fileName) as URL
                    do {
                        let data = try Data(contentsOf: pdfURL)
                        
                        try data.write(to: pdfURL as URL)
                        
                        let activitycontroller = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
                        if activitycontroller.responds(to: #selector(getter: activitycontroller.completionWithItemsHandler)) {
                            activitycontroller.completionWithItemsHandler = {(type, isCompleted, items, error) in
                                if isCompleted {
                                    self.clearAllFile()
                                }
                            }
                        }
                        
                        activitycontroller.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
                        activitycontroller.popoverPresentationController?.sourceView = self.view
                        self.present(activitycontroller, animated: true, completion: nil)
                        
                    }
                    catch {
                        //ERROR
                    }
                    
                }, failure: {
                    SVProgressHUD.dismiss()
                    self.alert(title: "ERROR", message: "File can't be displayed", actionButton: "OK")
                })
            }
        }
    }
    
    func previewFile(_ file: Item1, completion: @escaping ((URL, Data) -> Void)) {
        print("ttt \(file.attachment?.genFileName)")
        if let fileName = file.attachment?.genFileName {
           
            if let type = file.attachment?.contentType?.components(separatedBy: "/")[1] {
                if type == "jpg" || type == "jpeg" || type == "gif" || type == "png" {
                    
                    let vc = initController(with: "Main", withIdentifier: "ImagePreviewVC") as! ImagePreviewVC
                    let encodedURLString = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    vc.imagePath = "\(ApiRequirements.apiUrl.rawValue)/api/v1/document/documents/\(file.id)/preview"
                    vc.navTitle = fileName
                    vc.modalPresentationStyle = .fullScreen
                    
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    return
                }
            }
            
            let previewItem = temporaryFileDestination(fileName: fileName)
            SVProgressHUD.show()
            AppApi.shared.downloadImage(fileName, success: { data in
                SVProgressHUD.dismiss()
                completion(previewItem, data)
            }, failure: {
                SVProgressHUD.dismiss()
                self.alert(title: "ERROR", message: "File can't be displayed", actionButton: "OK")
            })
        }
    }
}

// MARK: - Progress Bar
extension UIViewController {
    var horizontalProgressBar: HorizontalProgressBar {
        return HorizontalProgressBar()
    }
    
    func showProgressBar() {
        var safeArea = view.safeAreaLayoutGuide
        horizontalProgressBar.translatesAutoresizingMaskIntoConstraints = false
        
        if let view = view {
            view.addSubview(horizontalProgressBar)
            safeArea = view.safeAreaLayoutGuide
        } else {
            guard let window = UIApplication.shared.keyWindow,
                  let controller = window.rootViewController,
                  let view = controller.view else { return }
            view.addSubview(horizontalProgressBar)
            safeArea = view.safeAreaLayoutGuide
        }
        
        NSLayoutConstraint.activate([
            horizontalProgressBar.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            horizontalProgressBar.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    func moveToRootController() {
        if GetUserType.user.isUserClient() {
            if let clientTabBarController = R.storyboard.client.clientTabBarController() {
                clientTabBarController.setRoot()
            }
        } else {
            if let advisorTabBarController = R.storyboard.advisor.advisorTabBarController() {
                advisorTabBarController.setRoot()
            }
        }
    }
    
    func hideProgressBar() {
        horizontalProgressBar.removeFromSuperview()
    }
    
    func setLogout(view: UIView) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
    }
    
    @objc func logout() {
        let appDelegate = AppDelegate()
        appDelegate.setRoot()
    }
}
