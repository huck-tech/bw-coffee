//
//  DashboardRoastStatisticView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DashboardRoastStatisticViewDelegate: class {
    func dashboardRoastStatisticDidSelectItem(index: Int)
}

class DashboardRoastStatisticView: View {
    
    weak var delegate: DashboardRoastStatisticViewDelegate?
    
    var stats: [DashboardRoastStatistic]? {
        didSet { updateStats() }
    }
    
    var statName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var contents: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var statCollection: CollectionView<DashboardRoastStatisticCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = CollectionView<DashboardRoastStatisticCell>(frame: .zero)
        collectionView.layout = layout
        collectionView.contentInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        
        collectionView.handleSelection = { [unowned self] index in
            self.delegate?.dashboardRoastStatisticDidSelectItem(index: index)
        }

        collectionView.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func setupViews() {
        addSubview(statName)
        
        statName.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        statName.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        statName.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        
        addSubview(contents)
        
        contents.topAnchor.constraint(equalTo: statName.bottomAnchor).isActive = true
        contents.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contents.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contents.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(statCollection)
        
        statCollection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        statCollection.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        statCollection.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        statCollection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func updateStats() {
        guard let updatedStats = stats else { return }
        statCollection.collectionItems = updatedStats
    }
    
    override func layoutSubviews() {
        statCollection.cellSize = CGSize(width: bounds.width, height: 32)
    }
    
}

