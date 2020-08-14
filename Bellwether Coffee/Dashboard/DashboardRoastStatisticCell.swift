//
//  DashboardRoastStatisticCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

struct DashboardRoastStatistic {
    let roast: ScheduledRoast?
    let greenItem: GreenItem?
    let profile: RoastProfile
    let amount: Double?
    let date: Date?
}

class DashboardRoastStatisticCell: CollectionViewCell {
    
    var date: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    var green: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var profile: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbs: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var prepare: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        button.setTitleColor(.brandPurple, for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Prepare", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        return button
    }()

    override func setupViews() {
        
        addSubview(date)
        
        date.topAnchor.constraint(equalTo: topAnchor).isActive = true
        date.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        date.widthAnchor.constraint(equalToConstant: 80).isActive = true
        date.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(green)
        
        green.topAnchor.constraint(equalTo: topAnchor).isActive = true
        green.leftAnchor.constraint(equalTo: date.rightAnchor, constant: 8).isActive = true
        green.widthAnchor.constraint(equalToConstant: 215).isActive = true
        green.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(profile)
        
        profile.topAnchor.constraint(equalTo: topAnchor).isActive = true
        profile.leftAnchor.constraint(equalTo: green.rightAnchor, constant: 8).isActive = true
        profile.widthAnchor.constraint(equalToConstant: 140).isActive = true
        profile.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lbs.leftAnchor.constraint(equalTo: profile.rightAnchor, constant: 8).isActive = true
        lbs.widthAnchor.constraint(equalToConstant: 40).isActive = true
        lbs.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(prepare)
        
        //self not accessible inside the button constructor? Move this code to where it belongs, please.
        prepare.onTap(target: self, selector: #selector(prepareRoast))

        prepare.topAnchor.constraint(equalTo: topAnchor).isActive = true
        prepare.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        prepare.leftAnchor.constraint(equalTo: lbs.rightAnchor, constant: 8).isActive = true
        prepare.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    @objc func prepareRoast() {
        guard let stat = cellData as? DashboardRoastStatistic else { return }
        
        guard !Roaster.shared.firmwareUpdating else {
            return RoastingProcessViewController.showRoasterUpdating()
        }

        guard RoastingProcess.roasting.state == .none else {
            return RoastingProcessViewController.showRoasterBusy()
        }
        guard Roaster.shared.isReadyForNewRoast else {
            return RoastingProcessViewController.showRoasterNotReady()
        }
        
        guard let quantity = stat.roast?.quantity?.doubleValue, let green = stat.greenItem?.name, let profile = stat.profile.name else {return}

        AppDelegate.visibleViewController?.confirm(title: "Prepare Scheduled Roast",
                                                   message: "Roasting \(quantity.formattedLbs(fractionDigits: 1)) lbs of \(green) with the \(profile) profile.")
            {confirmed in
            guard confirmed else {return}
            
            //flip the flag that this has already been prepared
            stat.roast?.prepared = NSNumber(value: true)
            stat.roast?.saveInBackground()
            
            AppDelegate.navController?.showRoast(greenItem: stat.greenItem, profile: stat.profile)
        }
    }
    
    override func updateCellData() {
        guard let dashboardStatistic = cellData as? DashboardRoastStatistic else { return }
        
        date.text = dashboardStatistic.date?.bw_formattedDate
        green.text = dashboardStatistic.greenItem?.name
        profile.text = dashboardStatistic.profile.name
        
        let lbsString = dashboardStatistic.amount?.formattedLbs() ?? ""
        lbs.text = lbsString + " lbs"
    }
    
}
