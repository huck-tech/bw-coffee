//
//  SidebarMenuView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

struct SidebarProfileInfo {
    let title: String?
    let subtitle: String?
    let profilePhoto: String?
    let action: (() -> Void)?
}

protocol SidebarMenuViewDelegate: class {
    // MARK: Profile
    func sidebarProfileInfo() -> SidebarProfileInfo
    func sidebarDidSelectProfileInfo()
    
    // MARK: Sidebar
    func sidebarMenuItemForIndex(index: Int) -> SidebarItem
    func sidebarMenuItemsCount() -> Int
    func sidebarMenuDidSelectItem(index: Int)
}

class SidebarMenuView: ComponentView {
    
    weak var delegate: SidebarMenuViewDelegate?
    
    let headerHeight = CGFloat(320)
    let menuItemHeight = CGFloat(56)
    
    lazy var menu: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(SidebarItemCell.self, forCellWithReuseIdentifier: defaultCellId)
        collection.register(SidebarMenuHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: defaultHeaderId)
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: menuItemHeight, right: 0)
        collection.alwaysBounceVertical = true
        collection.backgroundColor = UIColor.brandBackground
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor.brandBackground
        
        layer.shadowColor = UIColor(white: 0.1, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 1, height: 0)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
    }
    
    func setupLayout() {
        addSubview(menu)
        
        menu.topAnchor.constraint(equalTo: topAnchor).isActive = true
        menu.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        menu.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        menu.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func reload() {
        menu.reloadData()
    }
    
}

// MARK: Collection View

extension SidebarMenuView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                     withReuseIdentifier: defaultHeaderId,
                                                                     for: indexPath) as! SidebarMenuHeader
        
        let profile = delegate?.sidebarProfileInfo()
        header.profileInfo.info = profile
        header.profileInfo.action = { [unowned self] in
            self.delegate?.sidebarDidSelectProfileInfo()
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! SidebarItemCell
        
        let item = delegate?.sidebarMenuItemForIndex(index: indexPath.row)
        cell.item = item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.sidebarMenuDidSelectItem(index: indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let itemsCount = delegate?.sidebarMenuItemsCount() else { return 0 }
        return itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: menuItemHeight)
    }
    
}

