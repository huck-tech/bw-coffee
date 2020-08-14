//
//  BouncyButton.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class BouncyButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        animatePress()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        animateRelease()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        animateRelease()
    }
    
}

// MARK: Animations

extension BouncyButton {
    
    func animatePress() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func animateRelease() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
