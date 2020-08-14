//
//  SelectPaymentCardViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 6/27/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol SelectPaymentCardViewControllerDelegate: class {
    func selectPaymentCardDidSelect(method: PaymentMethod)
}

class SelectPaymentCardViewController: UIViewController {
    
    weak var delegate: SelectPaymentCardViewControllerDelegate?
    
    lazy var dismiss: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(cancelPayment), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var card: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .brandIce
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var navigationView: NavigationView = {
        let navigationView = NavigationView(frame: .zero)
        navigationView.delegate = self
        navigationView.pageViews = [selectPayment, creditCard]
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        return navigationView
    }()
    
    lazy var selectPayment: SelectPaymentMethodView = {
        let paymentMethodView = SelectPaymentMethodView(frame: .zero)
        paymentMethodView.delegate = self
        paymentMethodView.translatesAutoresizingMaskIntoConstraints = false
        return paymentMethodView
    }()
    
    lazy var creditCard: AddPaymentCreditCardView = {
        let creditCardView = AddPaymentCreditCardView(frame: .zero)
        creditCardView.delegate = self
        creditCardView.translatesAutoresizingMaskIntoConstraints = false
        return creditCardView
    }()
    
    var billingInfoId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        loadPayments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateEntrance()
    }
    
    func loadPayments() {
        BellwetherAPI.payments.getAvailableMethods { [weak self] paymentMethods in
            guard let payments = paymentMethods else { return }
            self?.selectPayment.paymentMethods = payments
        }
    }
    
    func resetPayments() {
        
    }
    
    @objc func cancelPayment() {
        dismiss(animated: true)
    }
    
}

// MARK: NavigationView Delegate

extension SelectPaymentCardViewController: NavigationViewDelegate {
    
    func navigationDidSegue(_ navigation: NavigationView, direction: NavigationDirection) {
        creditCard.cardNumber.resignFirstResponder()
    }
    
}

// MARK: SelectPaymentMethodView Delegate

extension SelectPaymentCardViewController: SelectPaymentMethodViewDelegate, AddPaymentCreditCardViewDelegate {
    
    func selectPaymentMethodDidSelect(paymentMethod: PaymentMethod) {
        delegate?.selectPaymentCardDidSelect(method: paymentMethod)
    }
    
    func selectPaymentMethodDidAdd() {
        navigationView.navigateForwardst()
    }
    
    func selectPaymentMethodShouldDismiss() {
        dismiss(animated: true)
    }
    
    func addPaymentShouldSaveCard(creditCard: CreditCard) {
        guard let billingInfo = billingInfoId else { return }
        
        BellwetherAPI.payments.addCard(creditCard: creditCard, billingInfo: billingInfo) { [weak self] success in
            guard success else {
                let alertController = UIAlertController(title: "Payment Method Invalid", message: "This payment method is invalid. Please check the fields and try again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Done", style: .default))
                self?.present(alertController, animated: true)
                
                return
            }
            
            self?.navigationView.navigateBackwardst()
            self?.loadPayments()
        }
    }
    
}

// MARK: Layout

extension SelectPaymentCardViewController {
    
    func setupAppearance() {
        view.isOpaque = false
        view.backgroundColor = BellwetherColor.roastOverlay
    }
    
    func setupLayout() {
        view.addSubview(dismiss)
        
        dismiss.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dismiss.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dismiss.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dismiss.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(card)
        
        card.widthAnchor.constraint(equalToConstant: 730).isActive = true
        card.heightAnchor.constraint(equalToConstant: 420).isActive = true
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        card.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        card.topAnchor.constraint(equalTo: view.topAnchor, constant: 84).isActive = true
        
        view.addSubview(navigationView)
        
        navigationView.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
        navigationView.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        navigationView.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        navigationView.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
    }
    
}

// MARK: Animations

extension SelectPaymentCardViewController {
    
    func animateEntrance() {
        card.alpha = 0.0
        card.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
                        self.card.alpha = 1.0
                        self.card.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
