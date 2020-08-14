//
//  MarketViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/12/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketViewController: UIViewController {
    
    var beans = [Bean]() { //list also holds a list of beans, so opportunity for 
        didSet { updateBeans() }
    }
    
    lazy var header: MarketFeaturedHeader = {
        let featuredHeader = MarketFeaturedHeader(frame: .zero)
        featuredHeader.actionHandler = showFeaturedCoffee
        featuredHeader.translatesAutoresizingMaskIntoConstraints = false
        return featuredHeader
    }()
    
    var content: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var list: MarketListViewController = {
        let listController = MarketListViewController()
        listController.handleSelection = selectListBean
        listController.view.translatesAutoresizingMaskIntoConstraints = false
        return listController
    }()
    
    var listSmallWidth: NSLayoutConstraint?
    var listNormalWidth: NSLayoutConstraint?
    var listLargeWidth: NSLayoutConstraint?
    
    lazy var detail: MarketDetailViewController = {
        let detailController = MarketDetailViewController()
        detailController.view.translatesAutoresizingMaskIntoConstraints = false
        return detailController
    }()
    
    var detailSmallLeft: NSLayoutConstraint?
    var detailNormalLeft: NSLayoutConstraint?
    
    var currentSelectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        loadFeatured()
        loadBeans()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calculateWidths()
    }
    
    func loadFeatured() {
        // TODO: create endpoint for this in API
        header.name = "Colombia Cafe de Mujeres"
    }
    
    func loadBeans() {
        BellwetherAPI.beans.getBeans { fetchedBeans in
            guard let marketBeans = fetchedBeans else { return self.showNetworkError() }
            
            self.beans = marketBeans
            self.list.selectIndexListItem(index: self.currentSelectedIndex)
        }
    }
    
    func showFeaturedCoffee(action: MarketFeaturedHeaderAction) {
        if action == .featuredCoffee {
            
        }
    }
    
    func updateBeans() {
        list.items = beans
        cacheMarketImages()
    }
    
    func selectListBean(index: Int) {
        currentSelectedIndex = index
        list.highlightListItem(index: index)

        guard beans.indices.contains(index) else { return }
        detail.bean = list.beans[index]
    }
    
}

// MARK: Network Helpers

extension MarketViewController {
    
    func cacheMarketImages() {
        beans.forEach { bean in
            guard let beanPhotos = bean.photos else { return }
            SpeedyImageCache.shared.prefetchURLStrings(urls: beanPhotos)
        }
    }
    
    func showNetworkError() {
        
    }
    
}

// MARK: Layout

extension MarketViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(header)
        
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: 0).isActive = true //56
        header.isHidden = true
        
        view.addSubview(content)
        
        content.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        content.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        addChildViewController(detail)
        content.addSubview(detail.view)
        
        detail.view.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        detail.view.rightAnchor.constraint(equalTo: content.rightAnchor).isActive = true
        detail.view.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        
        detailSmallLeft = detail.view.leftAnchor.constraint(equalTo: content.leftAnchor)
        detailNormalLeft = detail.view.leftAnchor.constraint(equalTo: list.view.rightAnchor)
        
        addChildViewController(list)
        content.addSubview(list.view)
        
        list.view.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        list.view.leftAnchor.constraint(equalTo: content.leftAnchor).isActive = true
        list.view.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        
        listLargeWidth = list.view.widthAnchor.constraint(equalToConstant: 480)
        listNormalWidth = list.view.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.5)
        listSmallWidth = list.view.widthAnchor.constraint(equalTo: content.widthAnchor)
    }
    
}

// MARK: Sizing Helpers

extension MarketViewController {
    
    func calculateWidths() {
        let width = view.bounds.width
        
        if width > 768 {
            listSmallWidth?.isActive = false
            listNormalWidth?.isActive = false
            listLargeWidth?.isActive = true
            
            detailSmallLeft?.isActive = false
            detailNormalLeft?.isActive = true
        } else if width > 500 {
            listSmallWidth?.isActive = false
            listLargeWidth?.isActive = false
            listNormalWidth?.isActive = true
            
            detailSmallLeft?.isActive = false
            detailNormalLeft?.isActive = true
        } else {
            listNormalWidth?.isActive = false
            listLargeWidth?.isActive = false
            listSmallWidth?.isActive = true
            
            detailNormalLeft?.isActive = false
            detailSmallLeft?.isActive = true
        }
    }
    
}

// MARK: Animations

extension MarketViewController {
    
    func animateEntrance() {
        UIView.animate(withDuration: 0.7,
                       delay: 0.5,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.list.view.transform = CGAffineTransform(translationX: 0, y: 200)
            self.list.view.alpha = 0.0
                        
            self.detail.view.transform = CGAffineTransform(translationX: 0, y: 200)
            self.detail.view.alpha = 0.0
        })
        
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
            self.list.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self.list.view.alpha = 1.0
                        
            self.detail.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self.detail.view.alpha = 1.0
        })
    }
    
}
