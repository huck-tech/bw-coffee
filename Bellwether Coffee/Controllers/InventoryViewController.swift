//
//  InventoryViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryViewController: UIViewController {
    
    lazy var tabs: InventoryTabsView = {
        let tabsView = InventoryTabsView(frame: .zero)
        tabsView.delegate = self
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        return tabsView
    }()
    
    lazy var orders: InventoryOrdersViewController = {
        let ordersController = InventoryOrdersViewController()
        ordersController.view.translatesAutoresizingMaskIntoConstraints = false
        return ordersController
    }()
    
    lazy var green: InventoryGreenViewController = {
        let greenController = InventoryGreenViewController()
        greenController.view.translatesAutoresizingMaskIntoConstraints = false
        return greenController
    }()
    
    lazy var roasted: InventoryRoastedViewController = {
        let roastedController = InventoryRoastedViewController()
        roastedController.view.translatesAutoresizingMaskIntoConstraints = false
        return roastedController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
}

extension InventoryViewController: InventoryTabsViewDelegate {
    
    func inventoryTabsDidSelect(tab: InventoryTab) {
        if tab == .order {
            addTab(controller: orders)
            removeTab(controller: green)
            removeTab(controller: roasted)
        }
        
        if tab == .green {
            removeTab(controller: orders)
            addTab(controller: green)
            removeTab(controller: roasted)
        }
        
        if tab == .roasted {
            removeTab(controller: orders)
            removeTab(controller: green)
            addTab(controller: roasted)
        }
    }
    
}

// MARK: Layout

extension InventoryViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(tabs)
        
        tabs.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        tabs.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabs.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tabs.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        addTab(controller: orders)
    }
    
}

extension InventoryViewController {
    
    func addTab(controller: UIViewController) {
        addViewController(controller)
        
        controller.view.topAnchor.constraint(equalTo: tabs.bottomAnchor).isActive = true
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func removeTab(controller: UIViewController) {
        removeViewController(controller)
    }
    
}
