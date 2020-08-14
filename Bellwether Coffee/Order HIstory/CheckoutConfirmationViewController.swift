//
//  CheckoutConfirmationViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 6/29/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class CheckoutConfirmationViewController: UIViewController {

    override func viewDidLoad(){
        super.viewDidLoad()
        self.view.onTap(target: self, selector: #selector(close))
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    @objc func close() {
        //hold on to the presenter, which we also need to dismiss.
        let presenter = self.presentingViewController
        self.dismiss(animated: true){              //dismiss the confirmation screen
            presenter?.dismiss(animated: true) {   //dismiss the CheckoutViewController, which is the presenter
                //show on order
                AppDelegate.navController?.showInventory(.order)
            }
        }
    }
}
