//
//  CartViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    
    var cart: [OrderItem]? {
        didSet { updateCart() }
    }
    
    var cartInfo: CartListInfoView = {
        let listInfo = CartListInfoView(frame: .zero)
        listInfo.translatesAutoresizingMaskIntoConstraints = false
        return listInfo
    }()
    
    lazy var cartFooter: CartFooterView = {
        let footerView = CartFooterView(frame: .zero)
        footerView.delegate = self
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()
    
    lazy var cartCollection: CollectionView<CartCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.footerReferenceSize = CGSize(width: 300, height: 140)
        
        let collectionView = CollectionView<CartCell>(frame: .zero)
        collectionView.layout = layout
        collectionView.footerView = cartFooter
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionView.dataSource = self // necessary for swipecellkit intercept
        collectionView.handleSelection = editOrderItem
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BellwetherAPI.orders.getCart { orderItems in
            self.cart = orderItems
        }
    }
    
    func updateCart() {
        guard let cartItems = cart else { return }
        cartCollection.collectionItems = cartItems
        
        calculateCartTotal()
    }
    
    func editOrderItem(index: Int){
        guard let orderItem = cartCollection.collectionItems[index] as? OrderItem else {return print("guard.fail \(#function)")}
        let poundPicker = PoundPickerViewController.bw_instantiateFromStoryboard()
        poundPicker.delegate = self
        poundPicker.load(item: orderItem)
        poundPicker.modalTransitionStyle = .crossDissolve
        poundPicker.modalPresentationStyle = .overCurrentContext
        self.present(poundPicker, animated: true)
    }
    
    func calculateCartTotal() {
        guard let cartItems = cart else { return }
        
        var totalPrice = 0.0
        
        cartItems.forEach { orderItem in
            totalPrice += orderItem.totalPrice ?? 0.0
        }
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        
        cartFooter.price.text = priceFormatter.string(for: totalPrice)
        cartFooter.checkoutEnabled = cartItems.count > 0
    }
    
}

extension CartViewController: PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource) {
        guard let orderItem = item as? OrderItem else {return print("guard.fail \(#function)")}
        BellwetherAPI.orders.updateItemQuantity(item: orderItem, quantity: units) {[weak self] success in
            guard success else {
                self?.showNetworkError(message: "Could not update order item quantity")
                return
            }
            
            NotificationCenter.default.post(name: .shouldUpdateCart, object: nil, userInfo: nil)
        }
    }
}

extension Notification.Name {
    static let shouldUpdateCart = Notification.Name("ShouldUpdateCart")
}

extension CartViewController: CartFooterViewDelegate {
    
    func cartFooterDidSelectCheckout() {
        cartFooter.checkoutEnabled = false
        
        let checkoutController = CheckoutViewController()
        checkoutController.orderItems = cart
        checkoutController.modalTransitionStyle = .crossDissolve
        
        present(checkoutController, animated: true) { [unowned self] in
            let navigation = self.navigationController as? NavigationController
            navigation?.showDashboard()
        }
    }
    
}

// MARK: Layout

extension CartViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(cartInfo)
        
        cartInfo.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        cartInfo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cartInfo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cartInfo.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(cartCollection)
        
        cartCollection.topAnchor.constraint(equalTo: cartInfo.bottomAnchor).isActive = true
        cartCollection.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cartCollection.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cartCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.bringSubview(toFront: cartInfo)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cartCollection.cellSize = CGSize(width: view.bounds.width, height: 74)
    }
    
}

// MARK: UICollectionView Data Source

extension CartViewController: UICollectionViewDataSource {
    /*  In order to support swipeable cells, we need to intercept certain data source methods
     */
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cartCollection.collectionView(collectionView, cellForItemAt: indexPath) as! CartCell
        cell.delegate = self //here; we need to set the cell's delegate
        return cell
    }
    
    //just proxy
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return cartCollection.collectionView(collectionView, viewForSupplementaryElementOfKind:kind, at:indexPath)
    }
    
    //just proxy
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartCollection.collectionView(collectionView, numberOfItemsInSection: section)
    }
}

extension CartViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {action, indexPath in
            let deleteIndex = indexPath.row
            
            guard let orderItem = self.cart?[deleteIndex] else { return print("\(#function) cart item nil") }
            let orderName = orderItem.name ?? "Order"
            
            self.confirm(title: "Delete \(orderName)?") {[weak self] confirmed in
                guard confirmed else { return }
                
                BellwetherAPI.orders.deleteItem(item: orderItem) {success in
                    self?.cart?.remove(at: deleteIndex)
                    
                    NotificationCenter.default.post(name: .shouldUpdateCart, object: nil, userInfo: nil)
                }
            }
        }
        
        return [deleteAction]
    }
}

