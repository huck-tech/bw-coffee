//
//  CheckoutEditPaymentMethodViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutEditPaymentMethodViewControllerDelegate: class {
    func checkoutEditPaymentMethodShouldReload()
}

class CheckoutEditPaymentMethodViewController: UIViewController {
    
    weak var delegate: CheckoutEditPaymentMethodViewControllerDelegate?
    
    var billingInfoId: String?
    
    var infoTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 19)
        label.textColor = BellwetherColor.roast
        label.text = "Edit Info"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var save: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        button.setTitleColor(.brandPurple, for: .normal)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(selectSave), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var number: CheckoutFieldView = checkoutField(name: "Card Number", placeholder: "2848 9234 3247 3402")
    lazy var expirationMonth: CheckoutFieldView = checkoutField(name: "Expiration Month", placeholder: "02")
    lazy var expirationYear: CheckoutFieldView = checkoutField(name: "Expiration Year", placeholder: "20")
    lazy var cvc: CheckoutFieldView = checkoutField(name: "CVC", placeholder: "123")
    
    var fields: CheckoutFieldsView = {
        let fieldsView = CheckoutFieldsView(frame: .zero)
        fieldsView.translatesAutoresizingMaskIntoConstraints = false
        return fieldsView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        setupGestures()
    }
    
    func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissEdit))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func dismissEdit() {
        navigationController?.popViewController(animated: true)
    }
    
    func checkoutField(name: String, placeholder: String) -> CheckoutFieldView {
        let field = CheckoutFieldView(frame: .zero)
        field.label.text = "\(name):"
        field.field.text = ""
        field.field.placeholder = placeholder
        field.isEditable = true
        return field
    }
    
    @objc func selectSave() {
        // save to db
        
        guard number.hasPresence, expirationMonth.hasPresence, expirationYear.hasPresence, cvc.hasPresence else {
            let alertController = UIAlertController(title: "Please Enter All Fields", message: "Oops, you need to enter all the info first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        guard let billingInfo = billingInfoId else {
            let alert = UIAlertController(title: "No Billing Info", message: "Please go back to billing info and select something.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            present(alert, animated: true)
            
            return
        }
        
        let card = CreditCard(number: number.field.text ?? "",
                              cvc: cvc.field.text ?? "",
                              expirationMonth: expirationMonth.field.text ?? "",
                              expirationYear: expirationYear.field.text ?? "",
                              billingInfo: [:])
        
        
        save.isEnabled = false
        
        BellwetherAPI.payments.addCard(creditCard: card, billingInfo: billingInfo) { [weak self] success in
            guard success else {
                self?.showNetworkError(message: "Could not add payment card.")
                self?.save.isEnabled = true
                return
            }
            
            self?.navigationController?.popViewController(animated: true)
            self?.delegate?.checkoutEditPaymentMethodShouldReload()
        }
    }
    
}

// MARK: Layout

extension CheckoutEditPaymentMethodViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(infoTitle)
        
        infoTitle.addAnchors(anchors: [.top: view.topAnchor], constant: 84)
        infoTitle.addAnchors(anchors: [.left: view.leftAnchor, .right: view.rightAnchor], insetConstant: 24)
        
        view.addSubview(save)
        
        save.addAnchors(anchors: [.right: view.rightAnchor], constant: -24)
        save.addAnchors(anchors: [.centerY: infoTitle.centerYAnchor])
        
        view.addSubview(fields)
        
        fields.addAnchors(anchors: [.top: infoTitle.bottomAnchor], constant: 8)
        fields.addAnchors(anchors: [.left: view.leftAnchor, .right: view.rightAnchor], insetConstant: 24)
        fields.addAnchors(anchors: [.bottom: view.bottomAnchor])
        
        fields.fieldViews = [number, expirationMonth, expirationYear, cvc]
    }
    
}
