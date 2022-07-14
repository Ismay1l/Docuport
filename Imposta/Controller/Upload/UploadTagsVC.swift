//
//  UploadTags.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 20.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

protocol UploadTagsDelegate: AnyObject {
    func selectedTags(tags: [Int])
}

class UploadTagsVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isFinish = false
    var serviceId: Int?
    var tagsDelegate: UploadTagsDelegate?
    var selectedIndex: Int = 0
    
    var tagList: [Tag] = []
    var tagGroups: [TagGroup] = []
    var tagGroupsNew: [TagGroupElement] = []
    var selectedTags: [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTags()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tagList = []
        tagGroups = []
        tagGroupsNew = []
        selectedIndex = 0
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ClientList")
    }
    
    private func getTags() {
        guard let id = serviceId else { return }
        
        SVProgressHUD.show()
        DocumentApi.shared.getDocTypeTags(serviceId: id, success: { [weak self] result in
            self?.tagList = result
            self?.tableView.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    private func getTagGroups() {
        guard let serviceId = serviceId else { return }
        guard let tagId = tagList[selectedIndex].id else { return }
        
        SVProgressHUD.show()
        DocumentApi.shared.getDocTypeTagGroups(serviceId: serviceId, tagId: tagId, success: { [weak self] result in
            if result.isEmpty {
                self?.tagsGroupEmpty()
            } else {
                self?.tagGroups = result
                self?.tagList = self?.tagGroups[0].tags ?? []
                self?.tagGroups[0].isShown = true
                self?.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    private func tagsGroupEmpty() {
        tagsDelegate?.selectedTags(tags: selectedTags)
    }
}

extension UploadTagsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploadTagsCell", for: indexPath) as! UploadTagsCell
        
        if let listIcon = tagList[indexPath.row].listIcon {
            cell.icon?.image = convertBase64StringToImage(imageBase64String: listIcon, mode: .alwaysTemplate)
        } else {
            cell.icon?.image = nil
        }
        cell.titleLbl.text = tagList[indexPath.row].name
        
        if tagList[indexPath.item].isSelected == true {
            cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != indexPath.item && selectedIndex < tagList.count  {
            tagList[selectedIndex].isSelected = false
        }
        tagList[indexPath.item].isSelected = true
        selectedIndex = indexPath.item
        
        if let selectedId = tagList[selectedIndex].id {
            selectedTags.append(selectedId)
        }
        
        updateTable()
    }
    
    private func updateTable() {
        if tagGroups.isEmpty {
            getTagGroups()
        } else {
            let indexNotShown = tagGroups.firstIndex { $0.isShown == false }
            guard let index = indexNotShown else {
                tagsDelegate?.selectedTags(tags: selectedTags)
                return
            }
            
            tagList = tagGroups[index].tags ?? []
            tagGroups[index].isShown = true
            self.tableView.reloadData()
        }
    }
}
