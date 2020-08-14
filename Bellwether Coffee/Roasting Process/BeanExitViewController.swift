//
//  BeanExitViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 8/21/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class BeanExitViewController: UIViewController {
    static func clearBeanExit(bxs: BeanExitState?, handler: BeanExitActionHandler){
        var message = "Please clear the bean exit door."

        RoasterCommander.shared.setBeanExit(state: .open){success in
            if let bxs = bxs {
                switch bxs {
                case .open, .closed:
                    //there is no error...try to request the roast again
                    RoasterCommander.shared.setBeanExit(state: .closed) {success in
                        sleep(3)
                        return handler.didCompleteBeanExitAction()
                    }
                    return
                case .error:
                    break
                }
            } else {
                message = "Could not establish the state of the bean exit door. Please try again."
            }
            
            
            let alert = ConfirmActionAlert.build(title: "Bean Exit", message: message){_ in
                RoasterCommander.shared.setBeanExit(state: .closed) {success in
                    sleep(3)
                    return handler.didCompleteBeanExitAction()
                }
            }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 72, height: 54))
            imageView.image = UIImage.init(named: "BeanClear.jpg")
            alert.view.addSubview(imageView)
            AppDelegate.visibleViewController?.present(alert, animated: true)
        }
    }
}

protocol BeanExitActionHandler {
    func didCompleteBeanExitAction()
}
