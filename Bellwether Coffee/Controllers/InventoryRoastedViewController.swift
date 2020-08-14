//
//  InventoryRoastedViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/9/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryRoastedViewController: UIViewController {
    
    lazy var inventory: CollectionView<InventoryRoastCell> = {
        let collectionView = CollectionView<InventoryRoastCell>(frame: .zero)
        collectionView.padding = CGSize(width: 22, height: 24)
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = BellwetherColor.roast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.handleSelection = updateRoastedQuantity
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
    
    func loadInventory() {
        BellwetherAPI.roasts.getRoasts { roastedItems in
            guard let roastItems = roastedItems else { return self.showNetworkError(message: "Couldn't load roasted inventory.") }
            self.inventory.collectionItems = roastItems
        }
    }
    
    
    func updateRoastedQuantity(index: Int){
        guard let roastItem = self.inventory.collectionItems[index] as? RoastItem else {return print("failed cast to RoastItem")}
        let poundPicker = PoundPickerViewController.bw_instantiateFromStoryboard()
        poundPicker.delegate = self
        poundPicker.load(item: roastItem)
        poundPicker.modalTransitionStyle = .crossDissolve
        poundPicker.modalPresentationStyle = .overCurrentContext
        self.present(poundPicker, animated: true)
    }
}

extension InventoryRoastedViewController: PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource) {
        
        guard let item = item as? RoastItem else {return print("guard.fail \(#function)")}
        
        BellwetherAPI.roasts.update(quantity: units, for: item) {[weak self] success in
            guard success else {
                self?.showNetworkError(message: "Could not update roast item quantity")
                return
            }
            
            //reload inventory
            self?.loadInventory()
        }
    }
}

// MARK: Layout

extension InventoryRoastedViewController {
    
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
        inventory.cellSize = CGSize(width: (view.bounds.width - 44) / CGFloat(cardsPerRow), height: 240)
    }
    
}
