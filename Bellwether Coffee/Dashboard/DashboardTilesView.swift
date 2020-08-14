//
//  DashboardTilesView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DashboardTilesViewDelegate: class {
    func tilesDidSelect(item: DashboardInstrument)
}

class DashboardTilesView: ComponentView {
    
    weak var delegate: DashboardTilesViewDelegate?
    
    var instruments = [DashboardInstrument]() {
        didSet { tilesCollection.reloadData() }
    }
    
    let sidePadding: CGFloat = 24
    
    lazy var tilesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(DashboardTileCell.self, forCellWithReuseIdentifier: defaultCellId)
        collectionView.delaysContentTouches = false
        collectionView.contentInset = UIEdgeInsets(top: 72, left: sidePadding, bottom: 28, right: sidePadding)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var loadedInitalCells: Bool = false
    
    override func setupViews() {
        addSubview(tilesCollection)
        
        tilesCollection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tilesCollection.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tilesCollection.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tilesCollection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func updateLayout() {
        tilesCollection.collectionViewLayout.invalidateLayout()
    }
    
}

extension DashboardTilesView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! DashboardTileCell
        cell.instrument = instruments[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instruments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedInstrument = instruments[indexPath.row]
        delegate?.tilesDidSelect(item: selectedInstrument)
    }
    
}

// MARK: Layout

extension DashboardTilesView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth = bounds.width / 2
        
        if bounds.width < 400 {
            cellWidth = bounds.width
        }
        
        return CGSize(width: cellWidth - sidePadding, height: 280)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let splashDuration = 2.5
        let cellDelay = Double(indexPath.row) * 0.1
        
        let delay = loadedInitalCells ? 0.0 : cellDelay + splashDuration
        animateCellVisibility(cell: cell, delay: delay)
    }
    
}

// MARK: Animations

extension DashboardTilesView {
    
    func animateCellVisibility(cell: UICollectionViewCell, delay: TimeInterval) {
        cell.alpha = 0.0
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.7,
                       delay: delay,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: {
            cell.alpha = 1.0
            cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
