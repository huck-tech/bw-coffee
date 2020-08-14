//
//  PinKeyView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/23/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class PinKeyView: ComponentView {
    
    var delegate: PinKeyViewDelegate?
    
    var number: Int? {
        didSet { updateNumber() }
    }
    
    var key: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Regular", size: 32)
        label.textColor = UIColor(red: 0.933, green: 0.929, blue: 0.909, alpha: 1.0)
        label.textAlignment = .center
        label.layer.borderColor = UIColor.brandPurple.cgColor
        label.layer.borderWidth = 2
        return label
    }()
    
    override func setupViews() {
        addSubview(key)
    }
    
    override func layoutSubviews() {
        key.frame = bounds.insetBy(dx: 10, dy: 10)
        key.layer.cornerRadius = key.bounds.width / 2
    }
    
    func updateNumber() {
        guard let keyNumber = number else { return alpha = 0.0 }
        key.text = "\(keyNumber)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateContract()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.tapped(pin: self.number)
        animateExpand()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateExpand()
    }
    
}

// MARK: Animations

extension PinKeyView {
    
    func animateContract() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func animateExpand() {
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
