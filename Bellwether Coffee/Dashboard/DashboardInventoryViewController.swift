//
//  DashboardInventoryViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DashboardInventoryViewControllerDelegate: class {
    func dashboardInventoryDidSelectInventory()
}

class DashboardInventoryViewController: UIViewController {
    
    weak var delegate: DashboardBrowseViewControllerDelegate?
    
    var stats: [DashboardStatistic]? {
        didSet { updateStats() }
    }
    
    var titleBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Manage Inventory"
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
        
        self.titleBar.onTap(target: self, selector: #selector(goToInventory))
    }
    
    @objc func goToInventory(){
        AppDelegate.navController?.showInventory(.green)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadGreen()
    }
    
    func loadGreen() {
        BellwetherAPI.orders.getGreen { [unowned self] green in
            guard let greenItems = green else { return self.showNetworkError(message: "Couldn't load green inventory.") }
            
            let greenStats = greenItems.map { greenItem -> DashboardStatistic in
                let lbsDetail = greenItem.quantity?.formattedLbs() ?? ""
                return DashboardStatistic(identifier: greenItem._id, name: greenItem._name, detail: lbsDetail + " lbs", active:true)
            }
            
            // pre-fetch the roast profiles before they are needed, because these calls are time consuming 
            for green in greenItems {
                BellwetherAPI.roastProfiles.getRoastProfiles(bean: green.bean!) { greenItem in
                    if green.bean != nil {
                        RoastLogDatabase.shared.beanProfiles[green.bean!] = greenItem
                    }
                }
            }
            
            self.stats = greenStats
        }
    }
    
    func updateStats() {
        guard let updatedStats = stats else { return }
        statistics.stats = updatedStats
    }
    
}

extension DashboardInventoryViewController: DashboardStatisticViewDelegate {
    
    func dashboardStatisticDidSelectItem(index: Int) {
        let navController = navigationController as? NavigationController
        navController?.showInventory(.green)
    }
    
}

// MARK: Layout

extension DashboardInventoryViewController {
    
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

