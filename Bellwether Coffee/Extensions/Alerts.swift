//
//  Alerts.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showNetworkError(message: String) {
        let alertController = UIAlertController(title: "Uh Oh", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Done", style: .default))
        present(alertController, animated: true)
    }
    
}
