//
//  CheckoutSummaryListView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutSummaryListView: View {
    
    var orderItems = [OrderItem]() {
        didSet { listCollection.collectionItems = orderItems }
    }
    
    lazy var listCollection: CollectionView<CheckoutSummaryListCell> = {
        let collectionView = CollectionView<CheckoutSummaryListCell>(frame: .zero)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func setupViews() {
        setupLayout()
    }
    
}

// MARK: Layout

extension CheckoutSummaryListView {
    
    func setupLayout() {
        addSubview(listCollection)
        
        listCollection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        listCollection.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        listCollection.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        listCollection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        updateLayout()
    }
    
    func updateLayout() {
        listCollection.cellSize = CGSize(width: bounds.width, height: 60)
    }
    
}
