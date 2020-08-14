//
//  InventoryGreenViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/9/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryGreenViewController: UIViewController {
    
    var greenItems: [GreenItem]? {
        didSet { updateGreenItems() }
    }
    
    lazy var inventory: CollectionView<InventoryGreenCell> = {
        let collectionView = CollectionView<InventoryGreenCell>(frame: .zero)
        collectionView.actionDelegate = self
        collectionView.padding = CGSize(width: 22, height: 24)
        collectionView.handleSelection = { [unowned self] index in
            guard let greenItem = self.greenItems?[index] else {return print("no green item")}
            
            self.showGreenItemDetail(greenItem: greenItem)
            
        }
        
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
    
    func showGreenItemDetail(greenItem: GreenItem) {
        let detail = BeanDetailViewController()
        detail.greenItem = greenItem
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func loadInventory() {
        BellwetherAPI.orders.getGreen { green in
            guard let greenItems = green else { return self.showNetworkError(message: "Couldn't load green inventory.") }
            self.greenItems = greenItems
        }
    }
    
    func updateGreenQuantity(greenItem: GreenItem){
        let poundPicker = PoundPickerViewController.bw_instantiateFromStoryboard()
        poundPicker.delegate = self
        poundPicker.load(item: greenItem)
        poundPicker.modalTransitionStyle = .crossDissolve
        poundPicker.modalPresentationStyle = .overCurrentContext
        self.present(poundPicker, animated: true)
    }
    
    func updateGreenItems() {
        guard let updatedGreenItems = greenItems else { return }
        inventory.collectionItems = updatedGreenItems
    }
    
}


extension InventoryGreenViewController: ActionDelegate {
    func actionOn(target: AnyObject) {
        guard let cell = target as? InventoryGreenCell,
            let greenItem = cell.cellData as? GreenItem else {return print("guard.fail \(#function)")}
        self.updateGreenQuantity(greenItem: greenItem)
    }
}

extension InventoryGreenViewController: PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource) {
        
        guard let item = item as? GreenItem else {return print("guard.fail \(#function)")}
        
        BellwetherAPI.greens.updateGreenQuantity(green: item, quantity: units) {[weak self] success in
            guard success else {
                self?.showNetworkError(message: "Could not update green item quantity")
                return
            }
            
            //reload inventory
            self?.loadInventory()
        }
    }
}

// MARK: Layout

extension InventoryGreenViewController {
    
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
        inventory.cellSize = CGSize(width: (view.bounds.width - 44) / CGFloat(cardsPerRow), height: 170)
    }
    
}

