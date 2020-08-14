//
//  DashboardViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    lazy var browse: DashboardBrowseViewController = {
        let browseController = DashboardBrowseViewController()
        browseController.delegate = self
        browseController.view.translatesAutoresizingMaskIntoConstraints = false
        return browseController
    }()
    
    lazy var inventory: DashboardInventoryViewController = {
        let inventoryController = DashboardInventoryViewController()
        inventoryController.delegate = self
        inventoryController.view.translatesAutoresizingMaskIntoConstraints = false
        return inventoryController
    }()
    
    lazy var tip: DashboardTipViewController = {
        let tipController = DashboardTipViewController()
        tipController.delegate = self
        tipController.view.translatesAutoresizingMaskIntoConstraints = false
        return tipController
    }()
    
    var roasterTitle: DashboardTitleView = {
        let titleView = DashboardTitleView(frame: .zero)
        titleView.text = "Roaster: Unknown"
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()
    
    var emissionTitle: DashboardTitleView = {
        let titleView = DashboardTitleView(frame: .zero)
        titleView.text = "Emissions Calculator"
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()
    
    lazy var emissionsCalculator: DashboardEmissionsCalculatorViewController = {
        let emissionsController = DashboardEmissionsCalculatorViewController()
        emissionsController.view.translatesAutoresizingMaskIntoConstraints = false
        return emissionsController
    }()
    
    lazy var roast: DashboardRoastViewController = {
        let roastController = DashboardRoastViewController()
        roastController.view.translatesAutoresizingMaskIntoConstraints = false
        return roastController
    }()
    
    lazy var roasterControl: RoasterControlViewController = {
        let roasterControlController = RoasterControlViewController.bw_instantiateFromStoryboard()
        roasterControlController.view.translatesAutoresizingMaskIntoConstraints = false
        return roasterControlController
    }()
    
    var roastGraph: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "placeholder_roast_graph")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        //show roaster device control panel
        roasterTitle.onTap(target: self, selector: #selector(showDeviceControl))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //update the roast state
        updateRoastState()

        //monitor the value over time
        NotificationCenter.default.addObserver(self, selector: #selector(updateRoastState), name: .roasterStateUpdated, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roasterStateUpdated, object: nil)
    }
    
    @objc func updateRoastState() {
        let roasterState = Roaster.shared.isConnected ? Roaster.shared.state.stringValue : "Unknown"
        roasterTitle.text = "Roaster: \(roasterState)"
    }
    
}

extension DashboardViewController: DashboardBrowseViewControllerDelegate, DashboardInventoryViewControllerDelegate, DashboardTipViewControllerDelegate {
    
    func dashboardBrowseDidSelectMarket() {
        print("didSelectMarket")
    }
    
    func dashboardInventoryDidSelectInventory() {
        print("didSelectInventory")
    }
    
    func dashboardTipDidSelectTip() {

    }
    
}

// MARK: Roaster Device Control

extension DashboardViewController {
    @objc func showDeviceControl() {
        guard DeviceControlViewController.shouldAppear, BellwetherAPI.auth.isBellwetherUser else {return}
        let deviceControl = DeviceControlViewController.bw_instantiateFromStoryboard()
        self.navigationController?.pushViewController(deviceControl, animated: true)
    }
}

// MARK: Layout

extension DashboardViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
    func setupLayout() {
        addViewController(browse)
        
        browse.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        browse.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        browse.view.widthAnchor.constraint(equalToConstant: 390).isActive = true
        browse.view.heightAnchor.constraint(equalToConstant: 310).isActive = true
        
        addViewController(inventory)
        
        inventory.view.topAnchor.constraint(equalTo: browse.view.bottomAnchor, constant: 40).isActive = true
        inventory.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inventory.view.widthAnchor.constraint(equalToConstant: 390).isActive = true
        inventory.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        addViewController(tip)
        
        tip.view.topAnchor.constraint(equalTo: inventory.view.bottomAnchor, constant: 40).isActive = true
        tip.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tip.view.widthAnchor.constraint(equalToConstant: 0).isActive = true
        tip.view.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        view.addSubview(roasterTitle)
        
        roasterTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 84).isActive = true
        roasterTitle.leftAnchor.constraint(equalTo: browse.view.rightAnchor, constant: 24).isActive = true
        roasterTitle.widthAnchor.constraint(equalToConstant: 196).isActive = true
        roasterTitle.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        addViewController(roasterControl)
        
        roasterControl.view.topAnchor.constraint(equalTo: roasterTitle.bottomAnchor, constant: 16).isActive = true
        roasterControl.view.centerXAnchor.constraint(equalTo: roasterTitle.centerXAnchor).isActive = true
        roasterControl.view.widthAnchor.constraint(equalToConstant: 180).isActive = true
        roasterControl.view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        view.addSubview(emissionTitle)
        
        emissionTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 84).isActive = true
        emissionTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        emissionTitle.widthAnchor.constraint(equalToConstant: 330).isActive = true
        emissionTitle.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        addViewController(emissionsCalculator)
        
        emissionsCalculator.view.topAnchor.constraint(equalTo: emissionTitle.bottomAnchor, constant: 16).isActive = true
        emissionsCalculator.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -44).isActive = true
        emissionsCalculator.view.widthAnchor.constraint(equalToConstant: 330).isActive = true
        emissionsCalculator.view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(roastGraph)
        
        roastGraph.topAnchor.constraint(equalTo: emissionsCalculator.view.bottomAnchor, constant: 8).isActive = true
        roastGraph.leftAnchor.constraint(equalTo: browse.view.rightAnchor, constant: 24).isActive = true
        roastGraph.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -44).isActive = true
        roastGraph.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        addViewController(roast)
        
        roast.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        roast.view.leftAnchor.constraint(equalTo: browse.view.rightAnchor, constant: 24).isActive = true
        roast.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        roast.view.heightAnchor.constraint(equalTo: inventory.view.heightAnchor).isActive = true
        
        //disable until further notice
        roastGraph.isHidden = true
        emissionTitle.isHidden = true
        emissionsCalculator.view.isHidden = true
    }
    
}
