//
//  MarketAddToCartViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol MarketAddToCartViewControllerDelegate: class {
    func marketCartAddedSuccessfully()
}

class MarketAddToCartViewController: UIViewController {
    
    weak var delegate: MarketAddToCartViewControllerDelegate?
    
    var bean: Bean? {
        didSet { updateBean() }
    }
    
    var quantity = 22.0 {
        didSet { updateQuantity() }
    }
    
    lazy var dismiss: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(cancelCart), for: .touchUpInside)
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
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbsAvailable: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var pricePerLb: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbsPrice: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var roastProfiles: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tastingNotes: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var certification: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cart: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(cartTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(order), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var inventoryUnavailable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.red
        label.textAlignment = .left
        label.text = "Oops, we don't have this much coffee in stock."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var cartTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Add To Cart")
        return renderer.renderedText
    }()
    
    lazy var lbsPicker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    var selectLbs: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 12)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.text = "select lbs"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var totalLbsPrice: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateEntrance()
    }
    
    func updateBean() {
        guard let updatedBean = bean else { return }
        
        name.text = updatedBean._name
        
        let beanAmount = updatedBean.amount ?? 0.0
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        lbsFormatter.minimumFractionDigits = 0
        lbsFormatter.maximumFractionDigits = 0
        
        lbsAvailable.statisticText = "Lbs available"
        lbsAvailable.valueText = lbsFormatter.string(for: beanAmount)
        
        let lbPrice = updatedBean.price ?? 0.0
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        
        pricePerLb.statisticText = "Price Per Lb"
        pricePerLb.valueText = priceFormatter.string(for: lbPrice)
        
        roastProfiles.statisticText = "Available Roast Profiles"
        roastProfiles.valueText = updatedBean.roastProfiles?.readableSet()
        
        tastingNotes.statisticText = "Tasting Notes"
        tastingNotes.valueText = updatedBean.readableCuppingNotes
        
        certification.statisticText = "Certification"
        certification.valueText = updatedBean.certification?.readableSet()
        
        updateQuantity()
    }
    
    func updateQuantity() {
        guard let beanPrice = bean?.price else { return }
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        totalLbsPrice.text = priceFormatter.string(for: beanPrice * quantity)
        
        guard let beanQuantity = bean?.amount else { return }
        let inventoryAvailable = quantity < beanQuantity
        
        cart.isHidden = !inventoryAvailable
        inventoryUnavailable.isHidden = inventoryAvailable
    }
    
    @objc func order() {
        guard let orderedBean = bean else { return }
        
        BellwetherAPI.orders.addToCart(bean: orderedBean, quantity: quantity) { success in
            guard success else {
                self.showNetworkError(message: "We couldn't add this to your cart.")
                return
            }
            
            self.dismiss(animated: true)
            self.delegate?.marketCartAddedSuccessfully()
        }
    }
    
    @objc func cancelCart() {
        dismiss(animated: true)
    }
    
}

extension MarketAddToCartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\((row + 1) * 22)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLbs = (Double(row + 1) * 22.0)
        quantity = selectedLbs
    }
    
}

// MARK: Layout

extension MarketAddToCartViewController {
    
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
        card.heightAnchor.constraint(equalToConstant: 460).isActive = true
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        card.addSubview(name)
        
        name.topAnchor.constraint(equalTo: card.topAnchor, constant: 120).isActive = true
        name.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(lbsAvailable)
        
        lbsAvailable.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 32).isActive = true
        lbsAvailable.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(pricePerLb)
        
        pricePerLb.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 32).isActive = true
        pricePerLb.leftAnchor.constraint(equalTo: lbsAvailable.rightAnchor, constant: 80).isActive = true
        
        card.addSubview(roastProfiles)
        
        roastProfiles.topAnchor.constraint(equalTo: lbsAvailable.bottomAnchor, constant: 12).isActive = true
        roastProfiles.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(tastingNotes)
        
        tastingNotes.topAnchor.constraint(equalTo: roastProfiles.bottomAnchor, constant: 12).isActive = true
        tastingNotes.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(certification)
        
        certification.topAnchor.constraint(equalTo: tastingNotes.bottomAnchor, constant: 12).isActive = true
        certification.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(cart)
        
        cart.topAnchor.constraint(equalTo: certification.bottomAnchor, constant: 26).isActive = true
        cart.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        cart.widthAnchor.constraint(equalToConstant: 136).isActive = true
        cart.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        card.addSubview(inventoryUnavailable)
        
        inventoryUnavailable.topAnchor.constraint(equalTo: certification.bottomAnchor, constant: 26).isActive = true
        inventoryUnavailable.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        inventoryUnavailable.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        card.addSubview(lbsPicker)
        
        lbsPicker.centerYAnchor.constraint(equalTo: card.centerYAnchor).isActive = true
        lbsPicker.widthAnchor.constraint(equalToConstant: 64).isActive = true
        lbsPicker.heightAnchor.constraint(equalToConstant: 210).isActive = true
        lbsPicker.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -70).isActive = true
        
        card.addSubview(selectLbs)
        
        selectLbs.centerXAnchor.constraint(equalTo: lbsPicker.centerXAnchor).isActive = true
        selectLbs.topAnchor.constraint(equalTo: lbsPicker.topAnchor, constant: -8).isActive = true
        selectLbs.widthAnchor.constraint(equalToConstant: 52).isActive = true
        selectLbs.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        card.addSubview(totalLbsPrice)
        
        totalLbsPrice.centerXAnchor.constraint(equalTo: lbsPicker.centerXAnchor).isActive = true
        totalLbsPrice.topAnchor.constraint(equalTo: lbsPicker.bottomAnchor).isActive = true
    }
    
}

// MARK: Animations

extension MarketAddToCartViewController {
    
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
