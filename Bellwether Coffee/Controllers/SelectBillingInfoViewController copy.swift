//
//  SelectBillingInfoViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol SelectBillingInfoViewControllerDelegate: class {
    func selectBillingInfoDidSelect(info: BillingInfo)
}

class SelectBillingInfoViewController: UIViewController {
    
    weak var delegate: SelectBillingInfoViewControllerDelegate?
    
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
        navigationView.pageViews = [selectBillingInfo, addBillingInfo]
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        return navigationView
    }()
    
    lazy var selectBillingInfo: SelectBillingInfoView = {
        let billingInfoView = SelectBillingInfoView(frame: .zero)
        billingInfoView.delegate = self
        billingInfoView.translatesAutoresizingMaskIntoConstraints = false
        return billingInfoView
    }()
    
    lazy var addBillingInfo: AddBillingInfoView = {
        let billingInfoView = AddBillingInfoView(frame: .zero)
        billingInfoView.delegate = self
        billingInfoView.translatesAutoresizingMaskIntoConstraints = false
        return billingInfoView
    }()
    
    var billingInfoId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        loadBillings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateEntrance()
    }
    
    func loadBillings() {
        BellwetherAPI.billings.fetchOptions { [weak self] billingInfos in
            guard let billings = billingInfos else { return }
            self?.selectBillingInfo.billingInfos = billings
        }
    }
    
    func resetBillings() {
        
    }
    
    @objc func cancelPayment() {
        dismiss(animated: true)
    }
    
}

// MARK: NavigationView Delegate

extension SelectBillingInfoViewController: NavigationViewDelegate {
    
    func navigationDidSegue(_ navigation: NavigationView, direction: NavigationDirection) {
        
    }
    
}

// MARK: SelectPaymentMethodView Delegate

extension SelectBillingInfoViewController: SelectBillingInfoViewDelegate, AddBillingInfoViewDelegate {
    
    func selectBillingInfoDidSelect(billingInfo: BillingInfo) {
        delegate?.selectBillingInfoDidSelect(info: billingInfo)
    }
    
    func selectBillingInfoDidAdd() {
        navigationView.navigateForwardst()
    }
    
    func selectBillingInfoShouldDismiss() {
        dismiss(animated: true)
    }
    
    func addBillingInfoShouldSaveInfo(billingInfo: BillingInfo) {
        BellwetherAPI.billings.create(info: billingInfo) { [weak self] success in
            guard success else {
                let alertController = UIAlertController(title: "Could Not Save", message: "This billing info could not be saved. Please check the fields and try again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Done", style: .default))
                self?.present(alertController, animated: true)
                
                return
            }
            
            self?.navigationView.navigateBackwardst()
            self?.loadBillings()
        }
    }
    
}

// MARK: Layout

extension SelectBillingInfoViewController {
    
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

extension SelectBillingInfoViewController {
    
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

