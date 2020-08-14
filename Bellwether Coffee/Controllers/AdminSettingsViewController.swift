//
//  AdminSettingsViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 10/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

import UIKit

class AdminSettingsViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func selectChangePass() {
        let alertController = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "New Password"
        }
        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Confirm New Password"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Change Password", style: .destructive, handler: { [unowned self] alertAction in
            self.changePassword(newPassword: alertController.textFields![0].text!,
                                confirmNewPassword: alertController.textFields![1].text!)
        }))
        present(alertController, animated: true)
    }
    
    private func changePassword(newPassword: String, confirmNewPassword: String) {
        guard newPassword == confirmNewPassword else {
            let alertController = UIAlertController(title: "Passwords Don't Match", message: "Your password was not reset because the passwords you've entered do not match. Try again.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            present(alertController, animated: true)
            
            return
        }
        
        BellwetherAPI.users.changePassword(newPassword: newPassword) { [weak self] success in
            guard success else {
                self?.showNetworkError(message: "Could not change password.")
                return
            }
            
            let alertController = UIAlertController(title: "Password Changed", message: "Your password has been changed successfully. You can now use it to sign in.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Done", style: .default))
            self?.present(alertController, animated: true)
        }
    }
    
}
