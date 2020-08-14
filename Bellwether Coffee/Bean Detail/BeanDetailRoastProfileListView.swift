//
//  BeanDetailRoastProfileList.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 4/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol BeanDetailRoastProfileListViewDelegate: class {
    func beanDetailDidSelectProfile(index: Int)
}

class BeanDetailRoastProfileListView: View {
    
    weak var delegate: BeanDetailRoastProfileListViewDelegate?
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 20)
        label.textColor = BellwetherColor.roast
        label.text = "Roast Profiles"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var profileList: CollectionView<BeanDetailRoastProfileListCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        
        let collectionView = CollectionView<BeanDetailRoastProfileListCell>(frame: .zero)
        collectionView.layout = layout
        collectionView.contentInset = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)
        collectionView.collectionView.showsVerticalScrollIndicator = false
        
        collectionView.handleSelection = { [unowned self] index in
            self.delegate?.beanDetailDidSelectProfile(index: index)
        }
        
        collectionView.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        addSubview(profileList)
        
        profileList.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
        profileList.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        profileList.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        profileList.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        profileList.cellSize = CGSize(width: bounds.width, height: 44)
    }
    
    func selectIndexListItem(index: Int) {
        guard profileList.collectionItems.count > index else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        profileList.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
    }
    
}
