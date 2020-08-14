//
//  MarketListFilterView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/27/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit


class MarketListFilterView: ComponentView {
    
    weak var delegate: MarketListFilterDelegate?
    
    var filter: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "toolbar_filter"), for: .normal)
        button.addTarget(self, action: #selector(selectFilter), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var wheel: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "toolbar_wheel"), for: .normal)
        button.addTarget(self, action: #selector(selectWheel), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.autocapitalizationType = .none
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    var filterWheel: FlavorWheelFilterController = {
        let controller = BeanFlavorWheelViewController.bw_instantiateFromStoryboard()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        controller.view.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        controller.backgroundImage.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        controller.foregroundImage.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        return controller
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = .white
    }
    
    func setupLayout() {
        addSubview(filter)
        
        filter.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        filter.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        filter.widthAnchor.constraint(equalToConstant: 36).isActive = true
        filter.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(wheel)
        
        wheel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        wheel.leftAnchor.constraint(equalTo: filter.rightAnchor, constant: 4).isActive = true
        wheel.widthAnchor.constraint(equalToConstant: 36).isActive = true
        wheel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(searchBar)
        
        searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        searchBar.leftAnchor.constraint(equalTo: wheel.rightAnchor, constant: 4).isActive = true
        searchBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    @objc func selectFilter() {
        self.delegate?.showCategoricalFilters()
    }
    
    @objc func selectWheel() {
        AppDelegate.visibleViewController?.definesPresentationContext = true
        AppDelegate.visibleViewController?.present(filterWheel, animated: true)
    }
}
