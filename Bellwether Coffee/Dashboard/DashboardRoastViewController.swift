//
//  DashboardRoastViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/23/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import Parse

protocol DashboardRoastViewControllerDelegate: class {
    func dashboardRoastDidSelectRoast()
}

class DashboardRoastViewController: UIViewController {
    
    weak var delegate: DashboardRoastViewControllerDelegate?
    
    var roastStatusText: String? {
        didSet { currentlyRoastingBar.text = roastStatusText }
    }
    
    var titleBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.text = "Coffee Roasting Queue:"
        label.backgroundColor = UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scheduleRoast: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = .brandPurple
        label.textAlignment = .left
        label.text = "+ Schedule New Roast"
        label.backgroundColor = UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    var currentlyRoastingBar: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = "Roast"
        label.backgroundColor = .brandPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var statistics: DashboardRoastStatisticView = {
        let statisticView = DashboardRoastStatisticView(frame: .zero)
        statisticView.delegate = self
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        return statisticView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        scheduleRoast.onTap(target: self, selector: #selector(scheduleNewRoast))
        currentlyRoastingBar.onTap(target: self, selector: #selector(roastButtonTapped))
    }
    
    @objc func scheduleNewRoast() {
        guard !Roaster.shared.firmwareUpdating else {
            return RoastingProcessViewController.showRoasterUpdating()
        }
        guard RoastingProcess.roasting.state == .none else {
            return RoastingProcessViewController.showRoasterBusy()
        }
        
        guard Roaster.shared.isReadyForNewRoast else {
            return RoastingProcessViewController.showRoasterNotReady()
        }
        
        let navigator = self.navigationController as? NavigationController
        navigator?.showRoast()
    }
    
    @objc func roastButtonTapped() {
        let navigator = self.navigationController as? NavigationController
        navigator?.showRoast()
    }
    
    @objc func updateRoastingBar() {
        let title = Roasting.roasting.state == .none ? "Roast" : "Roasting: \(Roasting.roasting.description)"
        currentlyRoastingBar.text = title
    }
    
    func loadRoastSchedule() {
        guard let query = ScheduledRoast.query(), let cafe = BellwetherAPI.auth.cafe else {return}
        
        //we just wants future ones for our cafe that have not been prepared
        query.whereKey(ScheduledRoast.Fields.cafe.rawValue, equalTo: cafe)
        query.whereKey(ScheduledRoast.Fields.prepared.rawValue, equalTo: false)
        query.whereKey(ScheduledRoast.Fields.date.rawValue, greaterThan: Date())
        query.order(byAscending: ScheduledRoast.Fields.date.rawValue)
        
        query.findObjectsInBackground {[weak self] results, error in
            guard let scheduled = results as? [ScheduledRoast] else {return print("\(#function).\(error?.localizedDescription)")}
            

            BellwetherAPI.orders.getGreen {greenItems in
                guard let items = greenItems else {return print("failed to getch greenItems")}
                
                //build a green item lookup table by _id
                var greens = [String:GreenItem]()
                items.forEach {if let greenId = $0._id {greens[greenId] = $0}}
                
                self?.statistics.stats = scheduled.map {
                    guard let greenId = $0.green, let green = greens[greenId] else {return nil}
                    guard let profileId = $0.profile, let profile = RoastLogDatabase.shared.profiles[profileId] else {return nil}
                    
                    return DashboardRoastStatistic(roast:$0, greenItem: green, profile: profile,
                                                   amount: $0.quantity?.doubleValue ?? 0.0, date:$0.date)
                    } .compactMap{$0}
            }
        }
    }
    
    // MARK: View Controller Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRoastingBar), name: .roastingChanged, object: nil)
        self.updateRoastingBar()
        self.loadRoastSchedule()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roastingChanged, object: nil)
    }
}

extension DashboardRoastViewController: DashboardRoastStatisticViewDelegate {
    
    func dashboardRoastStatisticDidSelectItem(index: Int) {
    }
    
}

// MARK: Layout

extension DashboardRoastViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(titleBar)
        
        titleBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        titleBar.widthAnchor.constraint(equalToConstant: 220).isActive = true
        titleBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(currentlyRoastingBar)
        
        currentlyRoastingBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        currentlyRoastingBar.leftAnchor.constraint(equalTo: titleBar.rightAnchor).isActive = true
        currentlyRoastingBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        currentlyRoastingBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(statistics)
        view.addSubview(scheduleRoast)
        
        statistics.topAnchor.constraint(equalTo: titleBar.bottomAnchor).isActive = true
        statistics.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statistics.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statistics.bottomAnchor.constraint(equalTo: scheduleRoast.topAnchor).isActive = true
        
        
        scheduleRoast.heightAnchor.constraint(equalToConstant: 50).isActive = true
        scheduleRoast.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        scheduleRoast.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scheduleRoast.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //disable until further notice
        scheduleRoast.isUserInteractionEnabled = false
        scheduleRoast.textColor = .brandDisabled
//        statistics.isHidden = true
        
    }
    
}
