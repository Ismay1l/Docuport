//
//  PayrollCell.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 27.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import UIKit.UITableViewCell

class PayrollCell: UITableViewCell {
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var grossLabel: UILabel!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var collectionViewHeight: NSLayoutConstraint?
    
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteTap)))
        deleteIcon.isUserInteractionEnabled = true
        editIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editTap)))
        editIcon.isUserInteractionEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeight?.isActive = true
    }
    
    func configure(viewModel: PayrollInfo) {
        nameLabel.text = "\(viewModel.lastName ?? "") \(viewModel.firstName ?? "") \(viewModel.middleName ?? "")"
        grossLabel.text = "$ \(viewModel.grossPay ?? 0)"
        
        if !viewModel.isSubmitted {
            editIcon.image = UIImage(named: "payrollcell_edit_ic")
            editIcon.isUserInteractionEnabled = true
            deleteIcon.image = UIImage(named: "payrollcell_delete_ic")
            deleteIcon.isUserInteractionEnabled = true
        } else {
            editIcon.image = UIImage(named: "payrollcell_edit_dis_ic")
            editIcon.isUserInteractionEnabled = false
            deleteIcon.image = UIImage(named: "payrollcell_delete_dis_ic")
            deleteIcon.isUserInteractionEnabled = false
        }
    }
    
    func setCollectionViewDataSourceDelegate<Delegate: UICollectionViewDataSource & UICollectionViewDelegate>(_ delegate: Delegate,
                                                                                                              forRow row: Int) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated: false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    func setCollectionViewSize(size: Int) {
        if 0...3 ~= size {
            collectionViewHeight?.constant = 90
            return
        }
        if 3...6 ~= size {
            collectionViewHeight?.constant = 180
            return
        }

        collectionViewHeight?.constant = 270
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
    
    @objc private func deleteTap() {
        onDelete?()
    }
    
    @objc private func editTap() {
        onEdit?()
    }
}
