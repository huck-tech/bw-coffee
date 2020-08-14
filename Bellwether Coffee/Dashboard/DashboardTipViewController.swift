//
//  DashboardTipViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol DashboardTipViewControllerDelegate: class {
    func dashboardTipDidSelectTip()
}

class DashboardTipViewController: UIViewController {
    
    weak var delegate: DashboardTipViewControllerDelegate?
    
    var titleBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Tip The Farmer"
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
        
        self.titleBar.onTap(target: self, selector: #selector(goToTipTheFarmer))
    }
    
    @objc func goToTipTheFarmer() {
        delegate?.dashboardTipDidSelectTip()
    }
}

extension DashboardTipViewController: DashboardStatisticViewDelegate {
    
    func dashboardStatisticDidSelectItem(index: Int) {
        delegate?.dashboardTipDidSelectTip()
    }
    
}

// MARK: Layout

extension DashboardTipViewController {
    
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
        
        statistics.stats = [
            DashboardStatistic(identifier: "", name: "Colombia Cafe de Mujeres", detail: "$35", active: false),
//            DashboardStatistic(identifier: "", name: "Rwanda Maraba", detail: "$42", active: false),
//            DashboardStatistic(identifier: "", name: "Ethiopia Desto Gola", detail: "$23", active: false)
        ]
    }
    
}


