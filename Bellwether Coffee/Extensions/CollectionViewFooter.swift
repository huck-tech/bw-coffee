//
//  CollectionViewFooter.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CollectionViewFooter: UICollectionReusableView {
    
    var footerView: UIView? {
        didSet { updateFooterView() }
    }
    
    func updateFooterView() {
        guard let footer = footerView else { return }
        
        addSubview(footer)
        
        footer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        footer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        footer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        footer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
