//
//  DocumentsTVCell.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit

class DocumentsTVCell: UITableViewCell {
    
    @IBOutlet weak var bgView: CardView!
    @IBOutlet weak var documentsPhoto: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var tagsLbl: UILabel!
    var checkCell : Bool = false
    var name : String? = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkCell = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadData(document: ResultDocument, documentType: DocumentType) {
        shareButton.tintColor = UIColor.init(hexString: document.service?.color ?? "")
        self.checkCell = false
//        name = document.name
        shareButton.tag = document.id ?? 0
        titleLbl.text = document.name ?? ""
        var tags = ""
        
        for tag in document.tags ?? [] {
            tags.append(tag.name ?? "")
            tags.append("    ")
        }
        tagsLbl.text = tags
//        print("tagsLbl.text \(document.name)");
        switch document.attachment?.fileName?.fileExtension().lowercased() {
        case "jpg", "jpeg":
            documentsPhoto.image = R.image.jpg()
        case "png":
            documentsPhoto.image = R.image.png()
        case "pdf":
            documentsPhoto.image = R.image.pdf()
        case "docx", "doc":
            documentsPhoto.image = R.image.word()
        case "xlsx", "xls":
            documentsPhoto.image = R.image.excel()
        default:
            documentsPhoto.image = nil
        }
    }
    
    func getUploads(uploads: Item1) {
        self.titleLbl.text = uploads.displayName
    }
    
    
    override func prepareForReuse() {
           // invoke superclass implementation
           super.prepareForReuse()
        print("prepareForReuse \(titleLbl?.text)")
        self.checkCell = true
//        name = (titleLbl?.text)
//        do { bgView.removeFromSuperview() } catch let err {
//
//        }
//        if(bgView != nil) {
//            bgView?.removeFromSuperview()
//            shareButton?.removeFromSuperview()
//            titleLbl?.removeFromSuperview()
//            documentsPhoto?.removeFromSuperview()
//        }
        
       }

}

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
