//
//  InventoryAddToGreenViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol InventoryAddToGreenViewControllerDelegate: class {
    func inventoryAddedSuccessfully()
}

class InventoryAddToGreenViewController: UIViewController {
    
    weak var delegate: InventoryAddToGreenViewControllerDelegate?
    
    var orderItem: OnOrderItem? {
        didSet { updateOrderItem() }
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
    
    var orderNumber: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var info: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var date: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var quantity: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var add: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(addTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(order), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var addTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Add To Green Inventory")
        return renderer.renderedText
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
    
    func updateOrderItem() {
        guard let updatedOrderItem = orderItem else { return }
        
        name.text = updatedOrderItem._name
        orderNumber.text = "Order #\(updatedOrderItem.orderNumber ?? 0)"
        
        info.text = "Our records show this coffee has been delivered! If you haven’t received this shipment yet, send a note to orders@bellwethercoffee.com and we’ll investigate."
        
        date.statisticText = "Order Date"
        date.valueText = updatedOrderItem.createdDate?.defaultDateFormat
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        lbsFormatter.minimumFractionDigits = 0
        lbsFormatter.maximumFractionDigits = 0
        let quantityText = lbsFormatter.string(for: updatedOrderItem.quantity) ?? ""
        
        quantity.statisticText = "Quantity"
        quantity.valueText = quantityText + " lbs"
    }
    
    @objc func order() {
        guard let onOrderItem = orderItem else { return }
        
        BellwetherAPI.orders.importOrderToGreen(item: onOrderItem) { success in
            guard success else {
                self.showNetworkError(message: "We couldn't import this to your green inventory.")
                return
            }
            
            self.dismiss(animated: true, completion: {
                self.delegate?.inventoryAddedSuccessfully()
            })
        }
    }
    
    @objc func cancelCart() {
        dismiss(animated: true)
    }
    
}

// MARK: Layout

extension InventoryAddToGreenViewController {
    
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
        card.heightAnchor.constraint(equalToConstant: 340).isActive = true
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        card.addSubview(name)
        
        name.topAnchor.constraint(equalTo: card.topAnchor, constant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(orderNumber)
        
        orderNumber.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 14).isActive = true
        orderNumber.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(info)
        
        info.topAnchor.constraint(equalTo: orderNumber.bottomAnchor, constant: 8).isActive = true
        info.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        info.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -48).isActive = true
        
        card.addSubview(date)
        
        date.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 12).isActive = true
        date.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(quantity)
        
        quantity.topAnchor.constraint(equalTo: date.bottomAnchor, constant: 12).isActive = true
        quantity.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(add)
        
        add.topAnchor.constraint(equalTo: quantity.bottomAnchor, constant: 26).isActive = true
        add.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        add.widthAnchor.constraint(equalToConstant: 240).isActive = true
        add.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
}

// MARK: Animations

extension InventoryAddToGreenViewController {
    
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
