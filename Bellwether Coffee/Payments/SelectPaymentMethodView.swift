//
//  SelectPaymentMethodView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol SelectPaymentMethodViewDelegate: class {
    func selectPaymentMethodShouldDismiss()
    func selectPaymentMethodDidSelect(paymentMethod: PaymentMethod)
    func selectPaymentMethodDidAdd()
}

class SelectPaymentMethodView: View {
    
    weak var delegate: SelectPaymentMethodViewDelegate?
    
    var paymentMethods = [PaymentMethod]() {
        didSet { updatePaymentMethods() }
    }
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.text = "Payment Method"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cardsCollection: CollectionView<SelectPaymentCardCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.footerReferenceSize = CGSize(width: bounds.width, height: 56)
        
        let collection = CollectionView<SelectPaymentCardCell>(frame: .zero)
        collection.layout = layout
        collection.cellSize = CGSize(width: 0, height: 56)
        collection.collectionView.showsHorizontalScrollIndicator = false
        collection.footerView = addPaymentFooter
        collection.clipsToBounds = true
        collection.handleSelection = { [unowned self] index in
            let method = self.paymentMethods[index]
            self.delegate?.selectPaymentMethodDidSelect(paymentMethod: method)
        }
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var addPaymentFooter: AddPaymentFooter = {
        let footer = AddPaymentFooter(frame: .zero)
        footer.action = { [unowned self] in self.delegate?.selectPaymentMethodDidAdd() }
        footer.translatesAutoresizingMaskIntoConstraints = false
        return footer
    }()
    
    private var saveTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Done")
        return renderer.renderedText
    }()
    
    lazy var save: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(saveTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor =  .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func updatePaymentMethods() {
        cardsCollection.collectionItems = paymentMethods
    }
    
    @objc func dismiss() {
        delegate?.selectPaymentMethodShouldDismiss()
    }
    
}

// MARK: Layout

extension SelectPaymentMethodView {
    
    func setupAppearance() {
        
    }
    
    func setupLayout() {
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        
        addSubview(cardsCollection)
        
        cardsCollection.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
        cardsCollection.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        cardsCollection.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        cardsCollection.heightAnchor.constraint(equalToConstant: 260).isActive = true
        
        addSubview(save)
        
        save.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        save.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        
        save.widthAnchor.constraint(equalToConstant: 120).isActive = true
        save.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
}
