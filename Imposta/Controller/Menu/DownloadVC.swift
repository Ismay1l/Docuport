//
//  DownloadVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/5/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import QuickLook

class DownloadVC: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet var tableDownloads: UITableView!
    
    var urlPreviewItem: URL?
    var arrDownloads = [RetriveFiles]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchType = .downloads
        
        addMenuNavButton()
        //        addSearchNavButton()
        
        retriveFiles(type: DocumentType.inbox.rawValue)
    }
    
    func retriveFiles(type: String) {
        let appDelegate = AppDelegate()
        arrDownloads = appDelegate.retriveFiles()!.filter { $0.type == type && $0.user == UserDefaultsHelper.shared.getUserType() }
        tableDownloads.reloadData()
    }
    
    @IBAction func segmentSelection(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            retriveFiles(type: DocumentType.inbox.rawValue)
        } else {
            retriveFiles(type: DocumentType.outbox.rawValue)
        }
    }
}

extension DownloadVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDownloads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell") as! DownloadCell
        
        cell.lblDate.text = arrDownloads[indexPath.row].date
        cell.lblFileName.text = arrDownloads[indexPath.row].fileName
        cell.lblAccount.text = arrDownloads[indexPath.row].accountName
        cell.lblService.text = arrDownloads[indexPath.row].serviceName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = arrDownloads[indexPath.row].genFileName ?? ""
        let previewVC = QLPreviewController()
        urlPreviewItem = downloadedFileDestination(fileName: file)
        previewVC.dataSource = self
        self.present(previewVC, animated: true, completion: nil)
    }
}

extension DownloadVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urlPreviewItem! as QLPreviewItem
    }
}
