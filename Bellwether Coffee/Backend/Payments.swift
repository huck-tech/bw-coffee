//
//  Payments.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 6/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Braintree

class Payments {
    
    func addCard(creditCard: CreditCard, billingInfo: String, completion: @escaping (Bool) -> Void) {
        getClientToken { token in
            guard let clientToken = token else { return completion(false) }
            guard let braintreeClient = BTAPIClient(authorization: clientToken) else { return completion(false) }
            
            let cardClient = BTCardClient(apiClient: braintreeClient)
            let card = BTCard(number: creditCard.number, expirationMonth: creditCard.expirationMonth, expirationYear: creditCard.expirationYear, cvv: creditCard.cvc)
            
            cardClient.tokenizeCard(card) { tokenizedCard, error in
                guard error == nil else { return completion(false) }
                guard let nonce = tokenizedCard?.nonce else { return completion(false) }
                
                guard let cafe = BellwetherAPI.auth.cafe else { return completion(false) }
                
                BellwetherAPI.payments.addMethod(cafe: cafe, billingInfo: billingInfo, nonce: nonce) { success in
                    completion(success)
                }
            }
        }
    }
    
    func deleteMethod(paymentMethod: PaymentMethod, completion: @escaping (Bool) -> Void) {
        guard let paymentMethodId = paymentMethod._id else { return completion(false) }
        
        SpeedyNetworking.postData(route: "/payments/archive/\(paymentMethodId)", data: ["method": paymentMethodId]) { response in
            completion(response.success)
        }
    }
    
    func getClientToken(completion: @escaping (String?) -> Void) {
        SpeedyNetworking.get(route: "/payments/token") { response in
            guard response.success else { return completion(nil) }
            
            let client = response.jsonResults(model: [String: Any].self)
            
            guard let token = client?["token"] as? String else { return completion(nil) }
            completion(token)
        }
    }
    
    func getAvailableMethods(completion: @escaping ([PaymentMethod]?) -> Void) {
        SpeedyNetworking.get(route: "/payments/available") { response in
            guard response.success else { return completion(nil) }
            
            guard let methods = response.result(model: [PaymentMethod].self) else { return completion(nil) }
            completion(methods)
        }
    }
    
    func addMethod(cafe: String, billingInfo: String, nonce: String, completion: @escaping (Bool) -> Void) {
        let paramData: [String: Any] = ["cafe": cafe, "billingInfo": billingInfo, "nonce": nonce]
        
        SpeedyNetworking.postData(route: "/payments/add", data: paramData) { response in
            completion(response.success)
        }
    }
    
}
