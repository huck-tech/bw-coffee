//
//  CheckoutProcessPaymentMethodView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutProcessPaymentMethodViewDelegate: class {
    func checkoutPaymentMethodShouldAdd()
    func checkoutPaymentMethodShouldDelete(paymentMethod: PaymentMethod)
    func checkoutPaymentMethodShouldReload()
    func checkoutPaymentMethodShouldProceed()
}

class CheckoutProcessPaymentMethodView: CheckoutProcessStepView {
    
    weak var delegate: CheckoutProcessPaymentMethodViewDelegate?
    
    var paymentMethods = [PaymentMethod]() {
        didSet { updatePaymentMethods() }
    }
    
    var selectedPaymentMethod: PaymentMethod?
    
    lazy var paymentMethodCollection: CollectionView<CheckoutPaymentMethodCollectionCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = CGSize(width: 300, height: 60)
        
        let collectionView = CollectionView<CheckoutPaymentMethodCollectionCell>(frame: .zero)
        collectionView.layout = layout
        
        collectionView.handleSelection { [unowned self] index in
            self.selectedPaymentMethod = self.paymentMethods[index]
            self.delegate?.checkoutPaymentMethodShouldProceed()
        }
        
        collectionView.handleAction(CheckoutPaymentMethodCellAction.delete.rawValue) { [unowned self] index in
            self.deleteMethod(index: index)
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
        
        stepTitle = "Payment Method"
        
        setupAppearance()
        setupLayout()
    }
    
    func updatePaymentMethods() {
        paymentMethodCollection.collectionItems = paymentMethods
        
        collectionHeight?.constant = 144 * CGFloat(paymentMethods.count) + 60
        alignBottom(toView: paymentMethodCollection)
        
        selectedPaymentMethod = paymentMethods.first
        
        guard paymentMethods.count > 0 else { return }
        paymentMethodCollection.toggleSelection(index: 0)
    }
    
    func deleteMethod(index: Int) {
        let method = paymentMethods[index]
        delegate?.checkoutPaymentMethodShouldDelete(paymentMethod: method)
    }
    
    func addInfo() {
        delegate?.checkoutPaymentMethodShouldAdd()
    }
    
}

// MARK: Layout

extension CheckoutProcessPaymentMethodView {
    
    func setupAppearance() {
        backgroundColor = .white
    }
    
    func setupLayout() {
        addSubview(paymentMethodCollection)
        
        paymentMethodCollection.addAnchors(anchors: [.top: topAnchor], constant: 60)
        paymentMethodCollection.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor])
        
        collectionHeight = paymentMethodCollection.addAnchor(anchor: .height, value: CGFloat(200))
    }
    
    override func layoutSubviews() {
        paymentMethodCollection.cellSize = CGSize(width: bounds.width, height: 144)
    }
    
}
