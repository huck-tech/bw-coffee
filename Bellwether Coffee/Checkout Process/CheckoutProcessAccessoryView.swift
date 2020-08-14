//
//  CheckoutProcessAccessoryView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/19/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum CheckoutProcessAccessoryViewType {
    case none
    case header
    case footer
}

class CheckoutProcessAccessoryView: View {
    
    var type: CheckoutProcessAccessoryViewType = .none
    
    override func setupViews() {
        // override
    }
    
    func alignBottom(toView view: UIView, offset: CGFloat = 0.0) {
        addAnchors(anchors: [.bottom: view.bottomAnchor], constant: offset)
    }
    
}
