//
//  CheckoutSummaryView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutSummaryViewDelegate: class {
    func checkoutSummaryViewTotal(totalView: CheckoutSummaryTotalView, didPlaceOrder items: [OrderItem]?)
}

class CheckoutSummaryView: ComponentView {
    
    weak var delegate: CheckoutSummaryViewDelegate?
    
    var listOrderItems: [OrderItem]? {
        didSet { updateListOrderItems() }
    }
    
    var navBar: NavigationBar = {
        let navigationBar = NavigationBar(frame: .zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    var title: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 19)
        label.formatColor = BellwetherColor.roast
        label.formattedText = "Order Summary"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var summaryList: CheckoutSummaryListView = {
        let summaryListView = CheckoutSummaryListView(frame: .zero)
        summaryListView.clipsToBounds = true
        summaryListView.translatesAutoresizingMaskIntoConstraints = false
        return summaryListView
    }()
    
    var summaryTotal: CheckoutSummaryTotalView = {
        let summaryTotalView = CheckoutSummaryTotalView(frame: .zero)
        summaryTotalView.placeOrder.addTarget(self, action: #selector(selectPlaceOrder), for: .touchUpInside)
        summaryTotalView.translatesAutoresizingMaskIntoConstraints = false
        return summaryTotalView
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func updateListOrderItems() {
        guard let updatedCartItems = listOrderItems else { return }
        summaryList.orderItems = updatedCartItems
    }
    
    @objc func selectPlaceOrder() {
        summaryTotal.placeOrder.isUserInteractionEnabled = false
        summaryTotal.placeOrder.alpha = 0.3
        
        delegate?.checkoutSummaryViewTotal(totalView: summaryTotal, didPlaceOrder: listOrderItems)
    }
    
}

// MARK: Layout

extension CheckoutSummaryView {
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 0.988, alpha: 1.0)
    }
    
    func setupLayout() {
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 84).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(summaryTotal)
        
        summaryTotal.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        summaryTotal.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        summaryTotal.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(summaryList)
        
        summaryList.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        summaryList.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        summaryList.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        summaryList.bottomAnchor.constraint(equalTo: summaryTotal.topAnchor).isActive = true
    }
    
}
