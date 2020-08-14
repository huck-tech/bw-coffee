//
//  CheckoutProcessViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/23/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

// TODO: Integrate this with shipping service to pull actual prices
// we should have a database system of supported shipping options

enum ShippingOption: String {
    case BellwetherPickup = "Pick Up @ Bellwether: Free"
    case BellwetherDelivery = "Bellwether Delivery: $25.00"
    case UPSOption1 = "UPS Ground Shipping: $15.99 (3-7 Business Days)"
    case UPSOption2 = "UPS Shipping Option 2: $15.99 (5-8 Business Days)"
}

struct CheckoutProcessInfo {
    
    var customerName: String?
    var company: String?
    var address: String?
    var phone: String?
    var note: String?
    var shippingOption: ShippingOption?
    var discountCode: String?
    
    init() {
        // override
    }
    
}

enum CheckoutProcessCollectionType {
    case shipping
    case billing
    case payment
}

protocol CheckoutProcessViewControllerDelegate: class {
    func checkoutProcessShouldCollectInfo(collectionType: CheckoutProcessCollectionType)
    func checkoutProcessShouldCheckout()
    func checkoutProcessShouldUpdateShippingCost(cost: Double?)
}

class CheckoutProcessViewController: UIViewController {
    
    weak var delegate: CheckoutProcessViewControllerDelegate?
    
    var info = CheckoutProcessInfo() {
        didSet { updateInfo() }
    }
    
    lazy var checkoutProcess: CheckoutProcessScrollView = {
        let processScrollView = CheckoutProcessScrollView(frame: .zero)
        processScrollView.stepViews = [shipping, billing, paymentMethod, shippingOptions]
        processScrollView.translatesAutoresizingMaskIntoConstraints = false
        return processScrollView
    }()
    
    lazy var shipping: CheckoutProcessShippingInfoView = {
        let shippingInfoView = CheckoutProcessShippingInfoView(frame: .zero)
        shippingInfoView.delegate = self
        shippingInfoView.translatesAutoresizingMaskIntoConstraints = false
        return shippingInfoView
    }()
    
    lazy var billing: CheckoutProcessBillingInfoView = {
        let billingInfoView = CheckoutProcessBillingInfoView(frame: .zero)
        billingInfoView.delegate = self
        billingInfoView.translatesAutoresizingMaskIntoConstraints = false
        return billingInfoView
    }()
    
    lazy var paymentMethod: CheckoutProcessPaymentMethodView = {
        let paymentMethodView = CheckoutProcessPaymentMethodView(frame: .zero)
        paymentMethodView.delegate = self
        paymentMethodView.translatesAutoresizingMaskIntoConstraints = false
        return paymentMethodView
    }()
    
    lazy var shippingInfo: CheckoutShippingInfoView = {
        let shippingInfoView = CheckoutShippingInfoView(frame: .zero)
        shippingInfoView.confirm.addTarget(self, action: #selector(confirmShippingInfo), for: .touchUpInside)
        shippingInfoView.alpha = 1.0
        shippingInfoView.translatesAutoresizingMaskIntoConstraints = false
        return shippingInfoView
    }()
    
    var shippingOptions: CheckoutShippingOptionView = {
        let optionView = CheckoutShippingOptionView(frame: .zero)
        optionView.confirm.addTarget(self, action: #selector(confirmShippingOption), for: .touchUpInside)
        optionView.alpha = 1.0
        optionView.translatesAutoresizingMaskIntoConstraints = false
        return optionView
    }()
    
    lazy var paymentInfo: CheckoutPaymentInfoView = {
        let paymentInfoView = CheckoutPaymentInfoView(frame: .zero)
        paymentInfoView.delegate = self
        paymentInfoView.placeOrder.addTarget(self, action: #selector(confirmPaymentInfo), for: .touchUpInside)
        paymentInfoView.alpha = 1.0
        paymentInfoView.translatesAutoresizingMaskIntoConstraints = false
        return paymentInfoView
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        loadStepsInfo()
    }
    
    func loadStepsInfo() {
        BellwetherAPI.shippingInfos.getAvailable { [weak self] shippings in
            guard let shippingInfos = shippings else { return }
            
            self?.shipping.shippingInfos = shippingInfos
            self?.checkoutProcess.performUIUpdates()
            
            guard let shippingId = shippingInfos.first?._id else { return }
            
            BellwetherAPI.rates.calculate(shippingInfo: shippingId) { calculatedRate in
                self?.delegate?.checkoutProcessShouldUpdateShippingCost(cost: calculatedRate)
                
                let price = calculatedRate?.formattedPrice() ?? ""
                self?.shippingOptions.stepTitle = "Delivery Option: UPS Ground (\(price))"
            }
        }
        
        BellwetherAPI.billingInfos.getAvailable { billings in
            guard let billingInfos = billings else { return }
            
            self.billing.billingInfos = billingInfos
            self.checkoutProcess.performUIUpdates()
        }
        
        BellwetherAPI.payments.getAvailableMethods { methods in
            guard let paymentMethods = methods else { return }
            
            self.paymentMethod.paymentMethods = paymentMethods
            self.checkoutProcess.performUIUpdates()
        }
    }
    
    func updateInfo() {
        shippingInfo.customerName.valueText = info.customerName
        shippingInfo.company.valueText = info.company
        shippingInfo.address.valueText = info.address
        shippingInfo.phone.valueText = info.phone
        
        shippingOptions.choices.choices = [
            //.BellwetherPickup,
//            .BellwetherDelivery,
            .UPSOption1,
//            .UPSOption2
        ]
        
        //        paymentInfo.billingInfo.valueText = info.address
    }
    
    @objc func confirmShippingInfo() {
        shippingInfo.confirmSection()
    }
    
    @objc func confirmShippingOption() {
        guard shippingOptions.selectedOptionIndex != nil else {
            let alert = UIAlertController(title: "Select Shipping Option", message: "Oops, you have to select one of the available shipping options.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default))
            present(alert, animated: true)
            
            return
        }
        
        shippingOptions.confirmSection()
    }
    
    @objc func confirmPaymentInfo() {
        paymentInfo.confirmSection()
        delegate?.checkoutProcessShouldCheckout()
    }
    
}

extension CheckoutProcessViewController: CheckoutProcessShippingInfoViewDelegate, CheckoutProcessBillingInfoViewDelegate, CheckoutProcessPaymentMethodViewDelegate, CheckoutEditShippingInfoViewControllerDelegate, CheckoutEditBillingInfoViewControllerDelegate, CheckoutEditPaymentMethodViewControllerDelegate {
    
    func checkoutShippingInfoShouldAdd() {
        let editShippingController = CheckoutEditShippingInfoViewController()
        editShippingController.delegate = self
        navigationController?.pushViewController(editShippingController, animated: true)
    }
    
    func checkoutEditShippingInfoShouldReload() {
        loadStepsInfo()
    }
    
    func checkoutEditBillingInfoShouldReload() {
        loadStepsInfo()
    }
    
    func checkoutEditPaymentMethodShouldReload() {
        loadStepsInfo()
    }
    
    func checkoutShippingInfoShouldProceed() {
        checkoutProcess.proceed(animated: true)
        
        BellwetherAPI.rates.calculate(shippingInfo: shipping.selectedShippingInfo?._id ?? "null") { [weak self] calculatedRate in
            self?.delegate?.checkoutProcessShouldUpdateShippingCost(cost: calculatedRate)
            
            let price = calculatedRate?.formattedPrice() ?? ""
            self?.shippingOptions.stepTitle = "Delivery Option: UPS Ground (\(price))"
        }
    }
    
    func checkoutBillingInfoShouldProceed() {
        checkoutProcess.proceed(animated: true)
    }
    
    func checkoutPaymentMethodShouldProceed() {
        checkoutProcess.proceed(animated: true)
    }
    
    func checkoutShippingInfoShouldEdit(shippingInfo: ShippingInfo) {
        let editShippingController = CheckoutEditShippingInfoViewController()
        editShippingController.delegate = self
        editShippingController.shippingInfo = shippingInfo
        navigationController?.pushViewController(editShippingController, animated: true)
    }
    
    func checkoutShippingInfoShouldReload() {
        loadStepsInfo()
    }
    
    // Billing Info
    
    func checkoutBillingInfoShouldAdd() {
        let editBillingController = CheckoutEditBillingInfoViewController()
        editBillingController.delegate = self
        navigationController?.pushViewController(editBillingController, animated: true)
    }
    
    func checkoutBillingInfoShouldEdit(billingInfo: BillingInfo) {
        let editBillingController = CheckoutEditBillingInfoViewController()
        editBillingController.delegate = self
        editBillingController.billingInfo = billingInfo
        navigationController?.pushViewController(editBillingController, animated: true)
    }
    
    func checkoutBillingInfoShouldReload() {
        loadStepsInfo()
    }
    
    // Payment Methods
    
    func checkoutPaymentMethodShouldAdd() {
        let editPaymentMethodController = CheckoutEditPaymentMethodViewController()
        editPaymentMethodController.delegate = self
        editPaymentMethodController.billingInfoId = billing.selectedBillingInfo?._id
        navigationController?.pushViewController(editPaymentMethodController, animated: true)
    }
    
    func checkoutPaymentMethodShouldDelete(paymentMethod: PaymentMethod) {
        let alertController = UIAlertController(title: "Delete \(paymentMethod.type ?? "") \(paymentMethod.description ?? "")", message: "Are you sure you want to delete this payment method?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] action in
            BellwetherAPI.payments.deleteMethod(paymentMethod: paymentMethod) { success in
print("\(#function).\(success)")
                self?.loadStepsInfo()
            }
        }))
        present(alertController, animated: true)
    }
    
    func checkoutPaymentMethodShouldReload() {
        loadStepsInfo()
    }
    
}

extension CheckoutProcessViewController: CheckoutPaymentInfoViewDelegate, SelectPaymentCardViewControllerDelegate {
    
    func checkoutPaymentInfoDidSelectMethods(currentMethod: PaymentMethod?) {
        delegate?.checkoutProcessShouldCollectInfo(collectionType: .payment)
    }
    
    func selectPaymentCardDidSelect(method: PaymentMethod) {
        
    }
    
    func checkoutPaymentInfoDidSelectBilling(currentBilling: BillingInfo?) {
        delegate?.checkoutProcessShouldCollectInfo(collectionType: .billing)
    }
    
}

// MARK: Layout

extension CheckoutProcessViewController {
    
    func setupAppearance() {
        
    }
    
    func setupLayout() {
        view.addSubview(checkoutProcess)
        
        checkoutProcess.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        checkoutProcess.addAnchors(anchors: [.top: view.topAnchor], constant: 64)
        checkoutProcess.addAnchors(anchors: [.left: view.leftAnchor, .right: view.rightAnchor])
        checkoutProcess.addAnchors(anchors: [.bottom: view.bottomAnchor])
    }
    
}
