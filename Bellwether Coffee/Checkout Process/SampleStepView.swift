//
//  SampleStepView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class SampleStepView: CheckoutProcessStepView {
    
    override func setupViews() {
        super.setupViews()
        
        // do ur shit here
        
        let view = UIView(frame: .zero)
        view.backgroundColor = .darkGray
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.addAnchors(anchors: [.top: topAnchor], constant: 60)
        view.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor, .height: CGFloat(200)])
        
        // you have to call this on whatever view you want to align the bottom of the step
        alignBottom(toView: view)
    }
    
}

class SampleFooterView: CheckoutProcessAccessoryView {
    
    override func setupViews() {
        super.setupViews()
        
        type = .footer
        
        let view = UIView(frame: .zero)
                view.backgroundColor = .red
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.addAnchors(anchors: [.top: topAnchor, .left: leftAnchor, .right: rightAnchor, .height: CGFloat(200)])
        
        alignBottom(toView: view)
    }
    
}
