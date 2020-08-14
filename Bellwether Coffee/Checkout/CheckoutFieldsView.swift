//
//  CheckoutFieldsView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/20/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutFieldView: View {
    
    var isEditable: Bool = false {
        didSet { updateEditable() }
    }
    
    var isExtendedField: Bool = false {
        didSet { updateExtended() }
    }
    
    var hasPresence: Bool {
        let value = field.text ?? ""
        return value.count > 0
    }
    
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var field: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = UIColor(white: 0.2, alpha: 1.0)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var text: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.backgroundColor = .lightGray
        return textView
    }()
    
    var compactBottom: NSLayoutConstraint?
    var extendedBottom: NSLayoutConstraint?
    
    override func setupViews() {
        addSubview(label)
        
        label.addAnchors(anchors: [.top: topAnchor, .left: leftAnchor, .height: CGFloat(44)])
        
        addSubview(field)
        
        field.addAnchors(anchors: [.top: topAnchor, .width: CGFloat(360), .height: CGFloat(44)])
        field.addAnchors(anchors: [.left: label.rightAnchor], constant: 8)
        
        addSubview(text)
        
        text.addAnchors(anchors: [.top: label.bottomAnchor], constant: 4)
        text.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor])
        
        compactBottom = bottomAnchor.constraint(equalTo: label.bottomAnchor)
        extendedBottom = bottomAnchor.constraint(equalTo: text.bottomAnchor)
        
        compactBottom?.isActive = true
    }
    
    func updateEditable() {
        field.isUserInteractionEnabled = isEditable
    }
    
    func updateExtended() {
        if isExtendedField {
            compactBottom?.isActive = false
            extendedBottom?.isActive = true
        } else {
            extendedBottom?.isActive  = false
            compactBottom?.isActive = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        field.becomeFirstResponder()
    }
    
}

class CheckoutFieldsView: View {
    
    var fieldViews = [CheckoutFieldView]() {
        didSet { setupFields() }
    }
    
    func setupFields() {
        var lastFieldAnchor: NSLayoutYAxisAnchor = topAnchor
        
        fieldViews.forEach { field in
            field.translatesAutoresizingMaskIntoConstraints = false
            addSubview(field)
            
            field.addAnchors(anchors: [
                .top: lastFieldAnchor,
                .left: leftAnchor,
                .right: rightAnchor,
                .height: CGFloat(44)
            ])
            
            lastFieldAnchor = field.bottomAnchor
        }
    }
    
}
