//
//  UIView+Tappable.swift
//  Bellwether-iOS
//
//  Created by Marcos Polanco on 11/22/17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation
import UIKit

/*  Convenience method to tie turn views into 'buttons' with a target/action selector
 */
extension UIView {
    func onTap(target: AnyObject, selector: Selector) {
        self.isUserInteractionEnabled = true
       let tap = UITapGestureRecognizer.init(target: target, action: selector)
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
}
