//
//  BeanDetailRoastProfileActionView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 4/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

struct BeanDetailRoastProfileAction {
    let name: String?
    let action: (() -> Void)?
}

class BeanDetailRoastProfileActionView: View {
    
    //for each of the buttons, establish whether you must be a bw user in order to activate
    let enabled_buttons = [true, true, false, false, false, false]
    
    var actions = [BeanDetailRoastProfileAction]() {
        didSet { updateActions() }
    }
    
    func updateActions() {
        var actionButtons = [UIButton]()
        
        actions.enumerated().forEach { index, action in
            let button = UIButton(frame: .zero)
            button.tag = index
            button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
            button.setTitleColor(.white, for: .normal)
            button.setTitle(action.name, for: .normal)
            button.backgroundColor = .brandPurple
            button.addTarget(self, action: #selector(selectButton(sender:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.enable(enabled_buttons[index] || BellwetherAPI.auth.isBellwetherUser)
            actionButtons.append(button)
        }
        
        let stack = UIStackView(arrangedSubviews: actionButtons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(stack)
        
        //we use special knowledge to add the last button outside the stack view
        if let delete = actionButtons.popLast() {
            delete.backgroundColor = UIColor.brandJolt
            delete.enable(BellwetherAPI.auth.isBellwetherUser)
            delete.addConstraint(NSLayoutConstraint(item: delete,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: delete,
                                                    attribute: .width,
                                                    multiplier: 1.0,
                                                    constant: 0))
            addSubview(delete)
            
            delete.topAnchor.constraint(equalTo: topAnchor).isActive = true
            delete.leftAnchor.constraint(equalTo: stack.rightAnchor, constant: 2).isActive = true
            delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            delete.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        } else {/* this should never happen */}
    }
    
    @objc func selectButton(sender: UIButton) {
        let profileAction = actions[sender.tag]
        profileAction.action?()
    }
    
}
