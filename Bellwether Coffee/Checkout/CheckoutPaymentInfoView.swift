//
//  CheckoutPaymentInfoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutPaymentInfoViewDelegate: class {
    func checkoutPaymentInfoDidSelectBilling(currentBilling: BillingInfo?)
    func checkoutPaymentInfoDidSelectMethods(currentMethod: PaymentMethod?)
}

class CheckoutPaymentInfoView: CheckoutProcessStepView {
    
    weak var delegate: CheckoutPaymentInfoViewDelegate?
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 19)
        label.textColor = BellwetherColor.roast
        label.text = "Payment Info"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var billing: BillingInfo? {
        didSet { updateBilling() }
    }
    
    var payment: PaymentMethod? {
        didSet { updatePayment() }
    }
    
    lazy var billingInfo: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = .brandPurple
        label.statisticText = "Billing Info"
        label.valueText = "Select Billing Info"
        label.action = { [unowned self] in
            self.delegate?.checkoutPaymentInfoDidSelectBilling(currentBilling: self.billing)
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paymentInfo: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = .brandPurple // UIColor(white: 0.6, alpha: 1.0)
        label.statisticText = "Payment Info"
        label.valueText = "Select Payment Method"
        label.action = { [unowned self] in
            self.delegate?.checkoutPaymentInfoDidSelectMethods(currentMethod: self.payment)
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var placeOrder: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .brandPurple
        button.setAttributedTitle(confirmTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var confirmTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Place Order")
        return renderer.renderedText
    }()
    
    private var confirmedTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = .brandPurple
        renderer.appendText(string: "Placing Order")
        return renderer.renderedText
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(billingInfo)
        
        billingInfo.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        billingInfo.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        billingInfo.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(paymentInfo)
        
        paymentInfo.topAnchor.constraint(equalTo: billingInfo.bottomAnchor, constant: 14).isActive = true
        paymentInfo.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        paymentInfo.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(placeOrder)
        
        placeOrder.topAnchor.constraint(equalTo: paymentInfo.bottomAnchor, constant: 16).isActive = true
        placeOrder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        placeOrder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        placeOrder.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        alignBottom(toView: placeOrder)
    }
    
    func updatePayment() {
        paymentInfo.valueText = "\(payment?.type ?? "") \(payment?.description ?? "")"
    }
    
    func updateBilling() {
        billingInfo.valueText = "\(billing?.address ?? "") - \(billing?.firstName ?? "") \(billing?.lastName ?? "")"
    }
    
    func confirmSection() {
        placeOrder.backgroundColor = .clear
        placeOrder.setAttributedTitle(confirmedTitle, for: .normal)
    }
    
}
