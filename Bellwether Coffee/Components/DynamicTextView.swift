//
//  DynamicTextView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DynamicTextViewDelegate: class {
    func textViewDidResize(newSize: CGSize)
}

class DynamicTextView: ComponentView {
    
    weak var delegate: DynamicTextViewDelegate?
    
    var attributedText: NSAttributedString! {
        didSet {
            textView.attributedText = attributedText
            resizeHeight()
        }
    }
    
    var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    var textWidth: NSLayoutConstraint?
    var textHeight: NSLayoutConstraint?
    
    override func setupViews() {
        addSubview(textView)
        
        textHeight = heightAnchor.constraint(equalToConstant: 44)
        textHeight?.isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textView.frame = bounds
        resizeHeight()
    }
    
    func resizeHeight() {
        let fit = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        
        let size = textView.sizeThatFits(fit)
        textHeight?.constant = size.height
        
        delegate?.textViewDidResize(newSize: size)
    }
    
}
