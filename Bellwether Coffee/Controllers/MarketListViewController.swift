//
//  MarketListViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketListViewController: UIViewController {
    
    var nameFilter: String? {
        didSet { updateItems() }
    }
    
    var filters = [MarketFilter:String]() {
        didSet { updateItems() }
    }
    
    var items: [Bean]? {
        didSet { updateItems() }
    }
    
    var filtereredItems: [Bean]? {
        
        var results = items
        
        //filter by name filter
        if let nameFilter = nameFilter?.lowercased() {
            results = items?.filter{
                guard let name = $0._name else {return false}
                return name.lowercased().contains(nameFilter)
            }
        }
        
        results = results?.filter {
            var result = true
            for (filter, term) in filters {
                switch filter {
                case .origin:
                        result = result && $0.location?.contains(term) ?? true
                case .profile:
                        result = result && $0.roastProfiles?.contains(term) ?? true
                case .certification:
                        result = result && $0.certification?.contains(term) ?? true
                }
            }
            
            return result
        }
        //filter by market filters
        return results
    }
    
    var filterHeader: MarketListFilterView = {
        let filterHeader = MarketListFilterView(frame: .zero)
        filterHeader.translatesAutoresizingMaskIntoConstraints = false
        return filterHeader
    }()
    
    var infoHeader: MarketListInfoView = {
        let infoHeader = MarketListInfoView(frame: .zero)
        infoHeader.translatesAutoresizingMaskIntoConstraints = false
        return infoHeader
    }()
    
    lazy var list: CollectionView<MarketListCell> = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        
        let collectionView = CollectionView<MarketListCell>(frame: .zero)
        collectionView.layout = layout
        collectionView.handleSelection = selectListItem
        collectionView.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var marketFilter: MarketListFilterTableViewController = {
       return MarketListFilterTableViewController.bw_instantiateFromStoryboard()
    }()
    
    var handleSelection: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        filterHeader.delegate = self                // filter
        filterHeader.filterWheel.delegate = self    // wheel
        filterHeader.searchBar.delegate = self      // search
    }
    
    func updateItems() {
        guard let beanItems = filtereredItems else { return }
        list.collectionItems = beanItems
    }
    
    func selectFirstListItem() {
        guard list.collectionItems.count > 0 else { return }
        
        let indexPath = IndexPath(row: 0, section: 0)
        list.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        
        selectListItem(index: 0)
    }
    
    func selectIndexListItem(index: Int) {
        guard list.collectionItems.count > index else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        list.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        
        selectListItem(index: index)
    }
    
    func selectListItem(index: Int) {
        handleSelection?(index)
    }
    
    func highlightListItem(index: Int) {
        guard list.collectionItems.count > index else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        list.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
    }
    
}

// MARK: UISearchBarDelegate

extension MarketListViewController: UISearchBarDelegate {

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            return self.nameFilter = nil
        }
        self.nameFilter = searchBar.text
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
// MARK: MarketListFilterDelegate Implementation

extension MarketListViewController: MarketListFilterDelegate {
    func showCategoricalFilters() {
        guard !marketFilter.isOnScreen else {return self.dismiss(animated:true)}
        
        self.definesPresentationContext = true
        marketFilter.modalTransitionStyle = .crossDissolve
        marketFilter.modalPresentationStyle = .overCurrentContext
        marketFilter.delegate = self
        self.present(marketFilter, animated: true)
    }
    
    var beans: [Bean] {
        return self.items ?? []
    }
    
    func didSort(beans: [Bean]) {
        self.items = beans
    }
    
    func didFilter(filters: [MarketFilter:String]) {
        self.filters = filters
    }
    

}

// MARK: MarketListFilterDelegate Declaration

protocol MarketListFilterDelegate : class {
    var beans: [Bean] {get}
    func didSort(beans: [Bean])
    func didFilter(filters: [MarketFilter:String])
    func showCategoricalFilters()
}

enum MarketFilter: String {
    case origin         = "origin"
    case profile        = "profile"
    case certification  = "certification"
}

// MARK: Layout

extension MarketListViewController {
    
    func setupAppearance() {
        view.clipsToBounds = false
    }
    
    func setupLayout() {
        view.addSubview(filterHeader)
        
        filterHeader.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        filterHeader.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        filterHeader.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -22).isActive = true
        filterHeader.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.addSubview(infoHeader)
        
        infoHeader.topAnchor.constraint(equalTo: filterHeader.bottomAnchor).isActive = true
        infoHeader.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        infoHeader.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -22).isActive = true
        infoHeader.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(list)
        view.sendSubview(toBack: list)
        
        list.topAnchor.constraint(equalTo: infoHeader.bottomAnchor).isActive = true
        list.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        list.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        list.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        list.cellSize = CGSize(width: view.bounds.width, height: 44)
    }
    
}
