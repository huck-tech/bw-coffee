//
//  CheckoutEditBillingInfoViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//


import UIKit

protocol CheckoutEditBillingInfoViewControllerDelegate: class {
    func checkoutEditBillingInfoShouldReload()
}

class CheckoutEditBillingInfoViewController: UIViewController {
    
    weak var delegate: CheckoutEditBillingInfoViewControllerDelegate?
    
    var billingInfo: BillingInfo? {
        didSet { updateBillingInfo() }
    }
    
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
    
    var delete: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = BellwetherColor.red
        button.isHidden = true
        button.addTarget(self, action: #selector(selectDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var firstName: CheckoutFieldView = checkoutField(name: "First Name", placeholder: "Thom")
    lazy var lastName: CheckoutFieldView = checkoutField(name: "Last Name", placeholder: "Yorke")
    lazy var company: CheckoutFieldView = checkoutField(name: "Company", placeholder: "Bluebird Cafe")
    lazy var email: CheckoutFieldView = checkoutField(name: "Email", placeholder: "customer@bellwethercoffee.com")
    lazy var phone: CheckoutFieldView = checkoutField(name: "Phone", placeholder: "+1 (615) 383-1461")
    lazy var address: CheckoutFieldView = checkoutField(name: "Street Address", placeholder: "4104 Hillsboro Pike")
    lazy var city: CheckoutFieldView = checkoutField(name: "City", placeholder: "Nashville")
    lazy var state: CheckoutFieldView = checkoutField(name: "State", placeholder: "TN")
    lazy var country: CheckoutFieldView = checkoutField(name: "Country", placeholder: "USA")
    lazy var postalCode: CheckoutFieldView = checkoutField(name: "Postal Code", placeholder: "37215")
    
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
        
        delete.isHidden = billingInfo == nil
    }
    
    func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissEdit))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func dismissEdit() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateBillingInfo() {
        firstName.field.text = billingInfo?.firstName
        lastName.field.text = billingInfo?.lastName
        company.field.text = billingInfo?.company
        email.field.text = billingInfo?.email
        phone.field.text = billingInfo?.phone
        address.field.text = billingInfo?.address
        city.field.text = billingInfo?.city
        state.field.text = billingInfo?.state
        country.field.text = billingInfo?.country
        postalCode.field.text = billingInfo?.postalCode
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
        guard firstName.hasPresence, lastName.hasPresence, company.hasPresence, email.hasPresence, phone.hasPresence, address.hasPresence, city.hasPresence, country.hasPresence, postalCode.hasPresence else {
            let alertController = UIAlertController(title: "Please Enter All Fields", message: "Oops, you need to enter all the info first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        let editBillingInfo = BillingInfo(_id: billingInfo?._id,
                                      firstName: firstName.field.text,
                                      lastName: lastName.field.text,
                                      company: company.field.text,
                                      email: email.field.text,
                                      phone: phone.field.text,
                                      address: address.field.text,
                                      city: city.field.text,
                                      state: state.field.text,
                                      country: country.field.text,
                                      postalCode: postalCode.field.text,
                                      isDefault: false)
        
        save.isEnabled = false
        
        if billingInfo != nil {
            BellwetherAPI.billingInfos.edit(billingInfo: editBillingInfo) { [weak self] success in
                guard success else {
                    self?.showNetworkError(message: "Could not edit shipping info.")
                    self?.save.isEnabled = true
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.checkoutEditBillingInfoShouldReload()
            }
        } else {
            BellwetherAPI.billingInfos.create(billingInfo: editBillingInfo) { [weak self] success in
                guard success else {
                    self?.showNetworkError(message: "Could not create billing info.")
                    self?.save.isEnabled = true
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.checkoutEditBillingInfoShouldReload()
            }
        }
    }
    
    @objc func selectDelete() {
        let alertController = UIAlertController(title: "Delete Billing Info", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] action in
            self.deleteInfo()
        }))
        present(alertController, animated: true)
    }
    
    func deleteInfo() {
        guard let info = billingInfo else { return }
        
        BellwetherAPI.billingInfos.archive(billingInfo: info) { [weak self] success in
            self?.navigationController?.popViewController(animated: true)
            self?.delegate?.checkoutEditBillingInfoShouldReload()
        }
    }
    
}

// MARK: Layout

extension CheckoutEditBillingInfoViewController {
    
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
        
        fields.fieldViews = [firstName, lastName, company, email, phone, address, city, state, country, postalCode]
        
        view.addSubview(delete)
        
        delete.addAnchors(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .height: CGFloat(44)])
    }
    
}
