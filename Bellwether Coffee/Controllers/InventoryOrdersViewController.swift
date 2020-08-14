//
//  InventoryOrdersViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/9/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryOrdersViewController: UIViewController {
    
    var inventoryItems: [OnOrderItem]? {
        didSet { updateInventoryItems() }
    }
    
    lazy var inventory: CollectionView<InventoryOrderCell> = {
        let collectionView = CollectionView<InventoryOrderCell>(frame: .zero)
        collectionView.padding = CGSize(width: 22, height: 24)
        collectionView.handleSelection = selectInventoryItem
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = BellwetherColor.roast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadInventory()
    }
    
    func updateInventoryItems() {
        guard let updatedItems = inventoryItems else { return }
        inventory.collectionItems = updatedItems
    }
    
    func loadInventory() {
        BellwetherAPI.orders.getOnOrder { onOrder in
            guard let onOrderItems = onOrder else { return self.showNetworkError(message: "Couldn't load green inventory.") }
            self.inventoryItems = onOrderItems
        }
    }
    
    func selectInventoryItem(index: Int) {
        guard let inventoryItem = inventoryItems?[index] else { return }
        guard inventoryItem.status == "delivered" else { return deliver(item: inventoryItem)}
        
        let addToGreenController = InventoryAddToGreenViewController()
        addToGreenController.delegate = self
        addToGreenController.orderItem = inventoryItem
        addToGreenController.modalTransitionStyle = .crossDissolve
        addToGreenController.modalPresentationStyle = .overCurrentContext
        present(addToGreenController, animated: true)
    }

    func deliver(item: OnOrderItem) {
        guard let order = item.order else {return print("\(#function).order==nil")}
        
        SpeedyNetworking.postData(route: "/orders/deliver/\(order)", data: ["order": order]) {[weak self] _ in
            self?.loadInventory()
        }
    }

}

extension InventoryOrdersViewController: InventoryAddToGreenViewControllerDelegate {
    
    func inventoryAddedSuccessfully() {
        loadInventory()
    }
    
}

// MARK: Layout

extension InventoryOrdersViewController {
    
    func setupAppearance() {
        view.backgroundColor = BellwetherColor.roast
    }
    
    func setupLayout() {
        view.addSubview(inventory)
        
        inventory.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        inventory.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inventory.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        inventory.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cardsPerRow = UIDevice.current.orientation.isLandscape ? 4 : 3
        inventory.cellSize = CGSize(width: (view.bounds.width - 44) / CGFloat(cardsPerRow), height: 224)
    }
    
}
