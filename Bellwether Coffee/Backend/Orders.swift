//
//  Orders.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Orders {
    
    func getCart(completion: @escaping ([OrderItem]?) -> Void) {
        SpeedyNetworking.get(route: "/orders/cart") { response in
            guard response.success else { return completion(nil) }
            
            let cart = response.result(model: [OrderItem].self)
            completion(cart)
        }
    }
    
    func addToCart(bean: Bean, quantity: Double, completion: @escaping (Bool) -> Void) {
        guard let beanId = bean._id else { return completion(false) }
        
        let cartData: [String: Any] = [
            "bean": beanId,
            "quantity": quantity
        ]
        
        SpeedyNetworking.postData(route: "/orders/addToCart", data: cartData) { response in
            completion(response.success)
        }
    }
    
    func deleteItem(item: OrderItem, completion: @escaping (Bool) -> Void) {
        guard let itemId = item._id else { return completion(false) }
        
        let orderData: [String: Any] = [
            "orderItem": itemId
        ]
        
        SpeedyNetworking.postData(route: "/orders/archiveItem/\(itemId)", data: orderData) { response in
            completion(response.success)
        }
    }
    
    func updateItemQuantity(item: OrderItem, quantity: Double, completion: @escaping (Bool) -> Void) {
        guard let itemId = item._id else { return completion(false) }
        
        let updateData: [String: Any] = [
            "quantity": quantity
        ]
        
        SpeedyNetworking.postData(route: "/orders/updateItemQuantity/\(itemId)", data: updateData) { response in
            completion(response.success)
        }
    }
    
    func checkout(paymentMethod: String, shippingInfo: String, billingInfo: String, completion: @escaping (Bool) -> Void) {
        let checkoutData: [String: Any] = [
            "paymentMethod": paymentMethod,
            "shippingInfo": shippingInfo,
            "billingInfo": billingInfo
        ]
        
        SpeedyNetworking.postData(route: "/orders/checkout", data: checkoutData) { response in
            completion(response.success)
        }
    }
    
    func importOrderToGreen(item: OnOrderItem, completion: @escaping (Bool) -> Void) {
        guard let orderId = item.order, let orderItemId = item.orderItem else { return completion(false) }
        
        let importData: [String: Any] = [
            "order": orderId,
            "orderItem": orderItemId
        ]
        
        SpeedyNetworking.postData(route: "/orders/import", data: importData) { response in
            completion(response.success)
        }
    }
    
    func getOnOrder(completion: @escaping ([OnOrderItem]?) -> Void) {
        SpeedyNetworking.get(route: "/orders/onOrder") { response in
            guard response.success else { return completion(nil) }
            
            let inventory = response.result(model: [OnOrderItem].self)
            completion(inventory)
        }
    }
    
    func getGreen(completion: @escaping ([GreenItem]?) -> Void) {
        SpeedyNetworking.get(route: "/orders/green") { response in
            guard response.success else { return completion(nil) }
            
            let inventory = response.result(model: [GreenItem].self)
            completion(inventory)
        }
    }
    
}
