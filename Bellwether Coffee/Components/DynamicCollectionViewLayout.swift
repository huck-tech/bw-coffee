//
//  DynamicCollectionViewLayout.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DynamicCollectionViewLayoutDelegate: class {
    func layoutItemSize(indexPath: IndexPath) -> CGSize
}

enum DynamicCollectionViewLayoutDistribution {
    case center
}

class DynamicCollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: DynamicCollectionViewLayoutDelegate?
    
    var distribution: DynamicCollectionViewLayoutDistribution = .center
    
    var maxColumns: Int = 2
    
    var columnItemSpacing: CGFloat = 20
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private var columnOffsets = [CGFloat]()
    private var columnOffsetIndex = 0
    
    override func prepare() {
        guard let dynamicCollectionView = collectionView else { return }
        guard dynamicCollectionView.numberOfItems(inSection: 0) > 0 else { return }
        
        populateOffsets()
        calculateLayout(collectionView: dynamicCollectionView)
    }
    
    func populateOffsets() {
        guard maxColumns > 0 else { return }
        
        for _ in 0...maxColumns - 1 {
            columnOffsets.append(0)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in layoutAttributes {
            if rect.contains(attributes.frame) {
                visibleAttributes.append(attributes)
            }
        }
        
        return visibleAttributes
    }
    
}

// MARK: Caching Functions

extension DynamicCollectionViewLayout {
    
    func calculateLayout(collectionView: UICollectionView) {
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        
        for index in 0...itemsCount {
            let indexPath = IndexPath(row: index, section: 0)
            
            let itemSize = delegate?.layoutItemSize(indexPath: indexPath) ?? .zero
            let itemOffset = columnOffsets[columnOffsetIndex]
            
            let columnWidth = collectionView.bounds.width / CGFloat(maxColumns)
            let itemOrigin = (columnWidth / 2) - (itemSize.width / 2)
            
            let itemFrame = CGRect(x: itemOrigin, y: itemOffset, width: itemSize.width, height: itemSize.height)
            addItemAttribute(frame: itemFrame, indexPath: indexPath)
        }
    }
    
    func addItemAttribute(frame: CGRect, indexPath: IndexPath) {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frame
        layoutAttributes.append(attributes)
        
        updateColumn(frame: frame)
    }
    
    func updateColumn(frame: CGRect) {
        columnOffsets[columnOffsetIndex] += frame.maxY
        
        if columnOffsetIndex < maxColumns - 1 {
            columnOffsetIndex += 1
        } else {
            columnOffsetIndex = 0
        }
    }
    
}
