//
//  DashboardBrowseViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/16/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DashboardBrowseViewControllerDelegate: class {
    func dashboardBrowseDidSelectMarket()
}

class DashboardBrowseViewController: UIViewController {
    
    weak var delegate: DashboardBrowseViewControllerDelegate?
    
    var stats: [DashboardStatistic]? {
        didSet { updateStats() }
    }
    
    var titleBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Browse the Market"
        label.backgroundColor = .brandPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var statistics: DashboardStatisticView = {
        let statisticView = DashboardStatisticView(frame: .zero)
        statisticView.delegate = self
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        return statisticView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        self.titleBar.onTap(target: self, selector: #selector(goToMarket))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadBeans()
    }
    
    @objc func goToMarket(){
        AppDelegate.navController?.showMarket(index: 0)
    }
    
    func loadBeans() {
        BellwetherAPI.beans.getBeans { [unowned self] fetchedBeans in
            guard var marketBeans = fetchedBeans else { return }
            
            //filter out zero counts
            marketBeans = marketBeans.filter {$0.amount != 0}
            
            let beanStats = marketBeans.map { bean -> DashboardStatistic in
                let lbsDetail = bean.amount?.formattedLbs() ?? ""
                return DashboardStatistic(identifier: bean._id, name: bean._name, detail: lbsDetail + " lbs", active:true)
            }
            
            self.stats = beanStats
        }
    }
    
    func updateStats() {
        guard let updatedStats = stats else { return }
        statistics.stats = updatedStats
    }
    
}

extension DashboardBrowseViewController: DashboardStatisticViewDelegate {
    
    func dashboardStatisticDidSelectItem(index: Int) {
        guard let _ = stats?[index].identifier else { return }
        
        let navController = navigationController as? NavigationController
        navController?.showMarket(index: index)
    }
    
}

// MARK: Layout

extension DashboardBrowseViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(titleBar)
        
        titleBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        titleBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(statistics)
        
        statistics.topAnchor.constraint(equalTo: titleBar.bottomAnchor).isActive = true
        statistics.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statistics.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statistics.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}
