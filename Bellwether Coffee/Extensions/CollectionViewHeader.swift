//
//  CollectionViewHeader.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    
    var headerView: UIView? {
        didSet { updateHeaderView() }
    }
    
    func updateHeaderView() {
        guard let header = headerView else { return }
        
        addSubview(header)
        
        header.topAnchor.constraint(equalTo: topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        header.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
