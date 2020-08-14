//
//  CheckoutShippingInfoViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/27/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutProcessShippingInfoViewDelegate: class {
    func checkoutShippingInfoShouldAdd()
    func checkoutShippingInfoShouldEdit(shippingInfo: ShippingInfo)
    func checkoutShippingInfoShouldReload()
    func checkoutShippingInfoShouldProceed()
}

class CheckoutProcessShippingInfoView: CheckoutProcessStepView {
    
    weak var delegate: CheckoutProcessShippingInfoViewDelegate?
    
    var shippingInfos = [ShippingInfo]() {
        didSet { updateShippingInfos() }
    }
    
    var selectedShippingInfo: ShippingInfo?
    
    lazy var shippingInfoCollection: CollectionView<CheckoutShippingInfoCollectionCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = CGSize(width: 300, height: 60)
        
        let collectionView = CollectionView<CheckoutShippingInfoCollectionCell>(frame: .zero)
        collectionView.layout = layout
        
        collectionView.handleSelection { [unowned self] index in
            self.selectedShippingInfo = self.shippingInfos[index]
            self.delegate?.checkoutShippingInfoShouldProceed()
        }
        
        collectionView.handleAction(CheckoutShippingInfoCellAction.edit.rawValue) { [unowned self] index in
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
        
        stepTitle = "Shipping Info"
        
        setupAppearance()
        setupLayout()
    }
    
    func updateShippingInfos() {
        shippingInfoCollection.collectionItems = shippingInfos
        
        collectionHeight?.constant = 144 * CGFloat(shippingInfos.count) + 60
        alignBottom(toView: shippingInfoCollection)
        
        selectedShippingInfo = shippingInfos.first
        
        guard shippingInfos.count > 0 else { return }
        shippingInfoCollection.toggleSelection(index: 0)
    }
    
    func editInfo(index: Int) {
        let info = shippingInfos[index]
        delegate?.checkoutShippingInfoShouldEdit(shippingInfo: info)
    }
    
    func addInfo() {
        delegate?.checkoutShippingInfoShouldAdd()
    }
    
}

// MARK: Layout

extension CheckoutProcessShippingInfoView {
    
    func setupAppearance() {
        backgroundColor = .white
    }
    
    func setupLayout() {
        addSubview(shippingInfoCollection)
        
        shippingInfoCollection.addAnchors(anchors: [.top: topAnchor], constant: 60)
        shippingInfoCollection.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor])
        
        collectionHeight = shippingInfoCollection.addAnchor(anchor: .height, value: CGFloat(200))
    }
    
    override func layoutSubviews() {
        shippingInfoCollection.cellSize = CGSize(width: bounds.width, height: 144)
    }
    
}
