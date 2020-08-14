////
////  MarketListView.swift
////  Bellwether Coffee
////
////  Created by Gabriel Pierannunzi on 12/26/17.
////  Copyright © 2017 Bellwether Coffee. All rights reserved.
////
//
//import UIKit
//
//protocol MarketListViewDelegate: class {
//    func listDidSelect(item: Bean)
//}
//
//class MarketListView: ComponentView {
//
//    weak var delegate: MarketListViewDelegate?
//
//    var items = [Bean]() {
//        didSet { listCollection.reloadData() }
//    }
//
//    var filterHeader: MarketListFilterView = {
//        let filterHeader = MarketListFilterView(frame: .zero)
//        filterHeader.translatesAutoresizingMaskIntoConstraints = false
//        return filterHeader
//    }()
//
//    var infoHeader: MarketListInfoView = {
//        let infoHeader = MarketListInfoView(frame: .zero)
//        infoHeader.translatesAutoresizingMaskIntoConstraints = false
//        return infoHeader
//    }()
//
//    lazy var listCollection: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 0.0
//        layout.minimumLineSpacing = 3.0
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
//        collectionView.alwaysBounceVertical = true
//        collectionView.register(MarketListCell.self, forCellWithReuseIdentifier: defaultCellId)
//        collectionView.delaysContentTouches = false
//        collectionView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        return collectionView
//    }()
//
//    override func setupViews() {
//        setupLayout()
//    }
//
//    func setupLayout() {
//        addSubview(filterHeader)
//
//        filterHeader.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        filterHeader.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        filterHeader.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        filterHeader.heightAnchor.constraint(equalToConstant: 60).isActive = true
//
//        addSubview(infoHeader)
//
//        infoHeader.topAnchor.constraint(equalTo: filterHeader.bottomAnchor).isActive = true
//        infoHeader.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        infoHeader.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        infoHeader.heightAnchor.constraint(equalToConstant: 44).isActive = true
//
//        addSubview(listCollection)
//
//        listCollection.topAnchor.constraint(equalTo: infoHeader.bottomAnchor).isActive = true
//        listCollection.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        listCollection.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        listCollection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//    }
//
//    func updateLayout() {
//        listCollection.layoutIfNeeded()
//        listCollection.collectionViewLayout.invalidateLayout()
//    }
//
//}
//
//extension MarketListView: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
//
//
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! MarketListCell
////        cell.bean = items[indexPath.row]
////        return cell
////    }
////
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return items.count
////    }
////
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        let bean = items[indexPath.row]
////        delegate?.listDidSelect(item: bean)
////    }
//
//}
//
//// MARK: Layout
//
//extension MarketListView: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 44)
//    }
//
//}
//
//// MARK: Animations
//
//extension MarketListView {
//
//    func animateCellVisibility(cell: UICollectionViewCell) {
//        cell.alpha = 0.0
//        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//
//        UIView.animate(withDuration: 0.5,
//                       delay: 0.0,
//                       usingSpringWithDamping: 1.0,
//                       initialSpringVelocity: 0.0,
//                       options: [.allowUserInteraction],
//                       animations: {
//            cell.alpha = 1.0
//            cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        })
//    }
//
//}
//
//
