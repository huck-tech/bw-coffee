//
//  DashboardEmissionsCalculatorViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardEmissionsCalculatorViewController: UIViewController {
    
    var titleBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Emissions Calculator"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var roastedLbsWeek: DashboardEmissionStatView = {
        let statView = DashboardEmissionStatView(frame: .zero)
        statView.statistic.text = "329"
        statView.name.text = "lbs roasted this week"
        statView.translatesAutoresizingMaskIntoConstraints = false
        return statView
    }()
    
    var roastedLbsMonth: DashboardEmissionStatView = {
        let statView = DashboardEmissionStatView(frame: .zero)
        statView.statistic.text = "1,000"
        statView.name.text = "lbs roasted this month"
        statView.translatesAutoresizingMaskIntoConstraints = false
        return statView
    }()
    
    var totalCo2: DashboardEmissionStatView = {
        let statView = DashboardEmissionStatView(frame: .zero)
        statView.statistic.text = "178"
        statView.name.text = "total lbs of C02 saved"
        statView.translatesAutoresizingMaskIntoConstraints = false
        return statView
    }()
    
    var totalTrees: DashboardEmissionStatView = {
        let statView = DashboardEmissionStatView(frame: .zero)
        statView.statistic.text = "4"
        statView.name.text = "total trees planted"
        statView.translatesAutoresizingMaskIntoConstraints = false
        return statView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
}

extension DashboardEmissionsCalculatorViewController: DashboardStatisticViewDelegate {
    
    func dashboardStatisticDidSelectItem(index: Int) {
        
    }
    
}

// MARK: Layout

extension DashboardEmissionsCalculatorViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        let statSize = CGSize(width: 144, height: 94)
        
        view.addSubview(roastedLbsWeek)
        
        roastedLbsWeek.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        roastedLbsWeek.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        roastedLbsWeek.widthAnchor.constraint(equalToConstant: statSize.width).isActive = true
        roastedLbsWeek.heightAnchor.constraint(equalToConstant: statSize.height).isActive = true
        
        view.addSubview(roastedLbsMonth)
        
        roastedLbsMonth.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        roastedLbsMonth.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        roastedLbsMonth.widthAnchor.constraint(equalToConstant: statSize.width).isActive = true
        roastedLbsMonth.heightAnchor.constraint(equalToConstant: statSize.height).isActive = true
        
        view.addSubview(totalCo2)
        
        totalCo2.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        totalCo2.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        totalCo2.widthAnchor.constraint(equalToConstant: statSize.width).isActive = true
        totalCo2.heightAnchor.constraint(equalToConstant: statSize.height).isActive = true
        
        view.addSubview(totalTrees)
        
        totalTrees.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        totalTrees.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        totalTrees.widthAnchor.constraint(equalToConstant: statSize.width).isActive = true
        totalTrees.heightAnchor.constraint(equalToConstant: statSize.height).isActive = true
    }
    
}
