//
//  CheckoutViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import mailgun

class CheckoutViewController: UIViewController {
    
    var orderItems: [OrderItem]? {
        didSet { summary.listOrderItems = orderItems }
    }
    
    var navBar: NavigationBar = {
        let navigationBar = NavigationBar(frame: .zero)
        navigationBar.menu.isHidden = true
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    lazy var processNavigation: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: process)
        navigationController.isNavigationBarHidden = true
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        return navigationController
    }()
    
    lazy var process: CheckoutProcessViewController = {
        let processController = CheckoutProcessViewController()
        processController.delegate = self
        //        processController.view.translatesAutoresizingMaskIntoConstraints = false
        return processController
    }()
    
    lazy var summary: CheckoutSummaryView = {
        let summaryView = CheckoutSummaryView(frame: .zero)
        summaryView.delegate = self
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        return summaryView
    }()
    
    var shippingInfoId: String?
    var billingInfoId: String?
    var paymentMethodId: String?
    
    var shippingCost: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Checkout"
        navBar.titleText = title
        
        setupAppearance()
        setupLayout()
        setupNavBar()
        
        loadData()
    }
    
    func setupNavBar() {
        navBar.rightNavButton = NavigationButton(image: UIImage(named: "close")) { [unowned self] in
            self.dismiss(animated: true)
        }
    }
    
    func loadData() {
        //        summary.listOrderItems = orderItems
        
        var checkoutInfo = CheckoutProcessInfo()
        checkoutInfo.customerName = "Thom Yorke"
        checkoutInfo.company = "Bluebird Cafe"
        checkoutInfo.address = "4104 Hillsboro Pike, Nashville, TN 37215"
        checkoutInfo.phone = "1 (615) 383-1461"
        process.info = checkoutInfo
        
        calculateTotal()
    }
    
    func calculateTotal() {
        guard let cartItems = orderItems else { return }
        
        var totalPrice = 0.0
        
        cartItems.forEach { orderItem in
            totalPrice += orderItem.totalPrice ?? 0.0
        }
        
        summary.summaryTotal.cartSubtotal.price.text = totalPrice.formattedPrice()
        
        totalPrice += shippingCost ?? 0.0
        
        summary.summaryTotal.total.price.text = totalPrice.formattedPrice()
    }
    
}

extension CheckoutViewController: CheckoutProcessViewControllerDelegate, SelectPaymentCardViewControllerDelegate, SelectBillingInfoViewControllerDelegate, CheckoutSummaryViewDelegate {
    
    func checkoutSummaryViewTotal(totalView: CheckoutSummaryTotalView, didPlaceOrder items: [OrderItem]?) {
        guard let shipping = process.shipping.selectedShippingInfo?._id else {
            let alertController = UIAlertController(title: "Please Enter Shipping Info", message: "Oops, you need to enter your shipping info first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        guard let billing = process.billing.selectedBillingInfo?._id else {
            let alertController = UIAlertController(title: "Please Enter Billing Info", message: "Oops, you need to enter your billing info first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        guard let payment = process.paymentMethod.selectedPaymentMethod?._id else {
            let alertController = UIAlertController(title: "Please Enter Payment Method", message: "Oops, you need to enter your payment method first.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        BellwetherAPI.orders.checkout(
            paymentMethod: payment,
            shippingInfo: shipping,
            billingInfo: billing) { [weak self] success in
                totalView.confirmed = success
                
                guard success else {
                    self?.showNetworkError(message: "Could not checkout your cart.")
                    return
                }
                
                NotificationCenter.default.post(name:  .shouldUpdateCart, object: nil, userInfo: nil)

                //show confirmation screen
                let confirmation = CheckoutConfirmationViewController.bw_instantiateFromStoryboard()
                confirmation.modalTransitionStyle = .crossDissolve
                confirmation.modalPresentationStyle = .overCurrentContext
                self?.present(confirmation, animated: true)
                
                //send a notification to Bellwether; @fixme - revisit to generalize
                self?.sendOrderNotification()
        }

    }
    
    
    private func sendOrderNotification(){
        
        let from = BellwetherAPI.auth.currentProfileInfo?.subtitle ?? ORDERS_EMAIL
        //create an email
        
        let shippingInfo = self.process.shipping.selectedShippingInfo
        let orderItemInfo = orderItems?.map {$0.forEmail} . reduce("",+)
        let body = String.describe(shippingInfo?.forEmail) + "\n" + String.describe(orderItemInfo)
    
        let message = MGMessage.init(from: from, to: ORDERS_EMAIL,
                                     subject: "Order Placed", body: body)
        
        //send out the mail
        AppDelegate.shared?.mailgun?.send(message, success: {success in
            print("order confirmation email sent in \(#function) \(String(describing: success))")
            }, failure: {error in
                print("\(error?.localizedDescription ?? "<unknown>") in \(#function)")
        })
    }
    
    func checkoutProcessShouldCheckout() {
        
    }
    
    func checkoutProcessShouldUpdateShippingCost(cost: Double?) {
        shippingCost = cost
        summary.summaryTotal.shipping.price.text = "$\(cost ?? 0.0)"
        
        calculateTotal()
    }
    
    func checkoutProcessShouldCollectInfo(collectionType: CheckoutProcessCollectionType) {
        if collectionType == .shipping {
            
        }
        
        if collectionType == .billing {
            let selectBillingController = SelectBillingInfoViewController()
            selectBillingController.delegate = self
            selectBillingController.billingInfoId = billingInfoId
            selectBillingController.modalTransitionStyle = .crossDissolve
            selectBillingController.modalPresentationStyle = .overCurrentContext
            present(selectBillingController, animated: true)
        }
        
        if collectionType == .payment {
            guard billingInfoId != nil else {
                let alertController = UIAlertController(title: "Add Billing Info First", message: "Please make sure you have selected billing info before selecting your payment method.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Done", style: .default))
                present(alertController, animated: true)
                
                return
            }
            
            let selectCardController = SelectPaymentCardViewController()
            selectCardController.delegate = self
            selectCardController.billingInfoId = billingInfoId
            selectCardController.modalTransitionStyle = .crossDissolve
            selectCardController.modalPresentationStyle = .overCurrentContext
            present(selectCardController, animated: true)
        }
    }
    
    func selectPaymentCardDidSelect(method: PaymentMethod) {
        paymentMethodId = method._id
        process.paymentInfo.payment = method
    }
    
    func selectBillingInfoDidSelect(info: BillingInfo) {
        billingInfoId = info._id
        process.paymentInfo.billing = info
    }
    
}

extension CheckoutViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(summary)
        
        summary.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        summary.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        summary.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        summary.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        
        addViewController(processNavigation)
        processNavigation.view.backgroundColor = .red
        
        //        view.addSubview(process.view)
        
        processNavigation.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        processNavigation.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        processNavigation.view.rightAnchor.constraint(equalTo: summary.leftAnchor).isActive = true
        processNavigation.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(navBar)
        
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
}
