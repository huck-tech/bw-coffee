//
//  CheckoutEditShippingInfoViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/29/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutEditShippingInfoViewControllerDelegate: class {
    func checkoutEditShippingInfoShouldReload()
}

class CheckoutEditShippingInfoViewController: UIViewController {
    
    weak var delegate: CheckoutEditShippingInfoViewControllerDelegate?
    
    var shippingInfo: ShippingInfo? {
        didSet { updateShippingInfo() }
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
    
    lazy var name: CheckoutFieldView = checkoutField(name: "Customer Name", placeholder: "Thom Yorke")
    lazy var company: CheckoutFieldView = checkoutField(name: "Company", placeholder: "Bluebird Cafe")
    lazy var address: CheckoutFieldView = checkoutField(name: "Address", placeholder: "4104 Hillsboro Pike")
    lazy var city: CheckoutFieldView = checkoutField(name: "City", placeholder: "Nashville")
    lazy var state: CheckoutFieldView = checkoutField(name: "State", placeholder: "TN")
    lazy var postalCode: CheckoutFieldView = checkoutField(name: "Postal Code", placeholder: "37215")
    lazy var phone: CheckoutFieldView = checkoutField(name: "Phone", placeholder: "+1 (615) 383-1461")
    
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
        
        delete.isHidden = shippingInfo == nil
    }
    
    func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissEdit))
        swipeGesture.direction = .right
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc func dismissEdit() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateShippingInfo() {
        name.field.text = shippingInfo?.customerName
        company.field.text = shippingInfo?.company
        address.field.text = shippingInfo?.address
        city.field.text = shippingInfo?.city
        state.field.text = shippingInfo?.state
        postalCode.field.text = shippingInfo?.postalCode
        phone.field.text = shippingInfo?.phone
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
        guard name.hasPresence, company.hasPresence, address.hasPresence, phone.hasPresence else {
            let alertController = UIAlertController(title: "Please Enter All Fields", message: "Oops, you need to enter all the info first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        let editShippingInfo = ShippingInfo(_id: shippingInfo?._id,
                                            customerName: name.field.text,
                                            company: company.field.text,
                                            address: address.field.text,
                                            city: city.field.text,
                                            state: state.field.text,
                                            postalCode: postalCode.field.text,
                                            phone: phone.field.text)
        
        save.isEnabled = false
        
        if shippingInfo != nil {
            BellwetherAPI.shippingInfos.edit(shippingInfo: editShippingInfo) { [weak self] success in
                guard success else {
                    self?.showNetworkError(message: "Could not edit shipping info.")
                    self?.save.isEnabled = true
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.checkoutEditShippingInfoShouldReload()
            }
        } else {
            BellwetherAPI.shippingInfos.create(shippingInfo: editShippingInfo) { [weak self] success in
                guard success else {
                    self?.showNetworkError(message: "Could not create shipping info.")
                    self?.save.isEnabled = true
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.checkoutEditShippingInfoShouldReload()
            }
        }
    }
    
    @objc func selectDelete() {
        let alertController = UIAlertController(title: "Delete Shipping Info", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] action in
            self.deleteInfo()
        }))
        present(alertController, animated: true)
    }
    
    func deleteInfo() {
        guard let info = shippingInfo else { return }
        
        BellwetherAPI.shippingInfos.archive(shippingInfo: info) { [weak self] success in
            self?.navigationController?.popViewController(animated: true)
            self?.delegate?.checkoutEditShippingInfoShouldReload()
        }
    }
    
}

// MARK: Layout

extension CheckoutEditShippingInfoViewController {
    
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
        
        fields.fieldViews = [name, company, address, city, state, postalCode, phone]
        
        view.addSubview(delete)
        
        delete.addAnchors(anchors: [.left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor, .height: CGFloat(44)])
    }
    
}
