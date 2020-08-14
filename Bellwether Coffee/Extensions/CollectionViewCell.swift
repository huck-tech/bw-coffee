//
//  CollectionViewCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

typealias CollectionViewCellAction = String

class CollectionViewCell: UICollectionViewCell {
    
    var cellIndex: Int = 0
    var cellSelected: Bool = false
    
    var cellData: Any? {
        didSet { updateCellData() }
    }
    
    var cellAction: ((Int, CollectionViewCellAction) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func setupViews() {
        // override for cell configuration
    }
    
    func updateCellData() {
        // override for cell data
    }
    
    func handle(action: CollectionViewCellAction) {
        cellAction?(cellIndex, action)
    }
    
}
