//
//  CheckoutProcessBillingInfoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutProcessBillingInfoViewDelegate: class {
    func checkoutBillingInfoShouldAdd()
    func checkoutBillingInfoShouldEdit(billingInfo: BillingInfo)
    func checkoutBillingInfoShouldReload()
    func checkoutBillingInfoShouldProceed()
}

class CheckoutProcessBillingInfoView: CheckoutProcessStepView {
    
    weak var delegate: CheckoutProcessBillingInfoViewDelegate?
    
    var billingInfos = [BillingInfo]() {
        didSet { updateBillingInfos() }
    }
    
    var selectedBillingInfo: BillingInfo?
    
    lazy var billingInfoCollection: CollectionView<CheckoutBillingInfoCollectionCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = CGSize(width: 300, height: 60)
        
        let collectionView = CollectionView<CheckoutBillingInfoCollectionCell>(frame: .zero)
        collectionView.layout = layout
        
        collectionView.handleSelection { [unowned self] index in
            self.selectedBillingInfo = self.billingInfos[index]
            self.delegate?.checkoutBillingInfoShouldProceed()
        }
        
        collectionView.handleAction(CheckoutBillingInfoCellAction.edit.rawValue) { [unowned self] index in
            self.editInfo(index: index)
        }
        
        collectionView.footerView = footer
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var collectionHeight: NSLayoutConstraint?
    
    lazy var footer: CheckoutProcessAddNewFooterView = {
        let footerView = CheckoutProcessAddNewFooterView(frame: .zero)
        
        footerView.action = { [unowned self] in
            self.addInfo()
        }
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()
    
    var checkoutFields: CheckoutFieldsView = {
        let fieldsView = CheckoutFieldsView(frame: .zero)
        fieldsView.translatesAutoresizingMaskIntoConstraints = false
        return fieldsView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        stepTitle = "Billing Info"
        
        setupAppearance()
        setupLayout()
    }
    
    func updateBillingInfos() {
        billingInfoCollection.collectionItems = billingInfos
        
        collectionHeight?.constant = 144 * CGFloat(billingInfos.count) + 60
        alignBottom(toView: billingInfoCollection)
        
        selectedBillingInfo = billingInfos.first
        
        guard billingInfos.count > 0 else { return }
        billingInfoCollection.toggleSelection(index: 0)
    }
    
    func editInfo(index: Int) {
        let info = billingInfos[index]
        delegate?.checkoutBillingInfoShouldEdit(billingInfo: info)
    }
    
    func addInfo() {
        delegate?.checkoutBillingInfoShouldAdd()
    }
    
}

// MARK: Layout

extension CheckoutProcessBillingInfoView {
    
    func setupAppearance() {
        backgroundColor = .white
    }
    
    func setupLayout() {
        addSubview(billingInfoCollection)
        
        billingInfoCollection.addAnchors(anchors: [.top: topAnchor], constant: 60)
        billingInfoCollection.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor])
        
        collectionHeight = billingInfoCollection.addAnchor(anchor: .height, value: CGFloat(200))
    }
    
    override func layoutSubviews() {
        billingInfoCollection.cellSize = CGSize(width: bounds.width, height: 144)
    }
    
}
