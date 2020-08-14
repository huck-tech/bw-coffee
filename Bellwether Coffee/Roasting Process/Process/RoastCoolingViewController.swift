//
//  RoastCoolingViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/19/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastCoolingViewController: RoastingStepController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var coolTime: UILabel!
    
    override func setupAppearance() {
        super.setupAppearance()
        
        self.view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //initial population
        self.load()
        
        //up the view view each second
        self.updateEachSecond()
    }
    
    override func load() {
        guard let coolStartTime = RoastingProcess.roasting.coolStartTime else {return}
        
        var targetTime = coolStartTime.addingTimeInterval(60 * 4 + 30) // 4:30 minutes

        //support la
        if let version = Roaster.shared.firmwareVersion, version.contains("GLADYS")  {
            self.coolTime.text = targetTime.displayMinSec(since: Date())
            if version.contains("GLADYS"){
                targetTime = coolStartTime.addingTimeInterval(10) // 4:30 minut
            }
        } else {
            Roaster.shared.httpsServicesFactory.roastController?.coolTimeRemaining {[weak self] remaining in
                guard let remaining = remaining else {return print("no cooling time target")}
                let interval = remaining > 33.0 ? remaining - 33.0 : 0
                
                if interval == 0.0 {
                    self?.titleLbl.text = "Exiting"
                    self?.coolTime.isHidden = true
                } else {
                    self?.titleLbl.text = "Cooling"
                    self?.coolTime.isHidden = false
                }
                
                let targetTime = Date().addingTimeInterval(interval)
                self?.coolTime.text = targetTime.displayMinSec(since: Date())
            }
            
            //in the absence of further information, we assume we have this long
            
        }
    }

    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let graphView = childController as? BWRoastProfileGraphViewController {
            graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: RoastingProcess.roasting.roastProfile ?? Mujeres.roastProfile,isEditable: false, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
        }
    }
}

extension TimeInterval {
    func displayMinSec() -> String {
        let timeslice = self.asHoursMinutesSeconds
        let minutes = timeslice.1 < 10 ? "0\(timeslice.1)" : "\(timeslice.1)"
        let seconds = timeslice.2 < 10 ? "0\(timeslice.2)" : "\(timeslice.2)"
        
        return "\(minutes):\(seconds)"
    }
}

extension Date {
    func displayMinSec(since date: Date) -> String {
        let timeslice = self.secondsToHoursMinutesSeconds(since: date)
        let minutes = timeslice.1 < 10 ? "0\(timeslice.1)" : "\(timeslice.1)"
        let seconds = timeslice.2 < 10 ? "0\(timeslice.2)" : "\(timeslice.2)"
        
        return "\(minutes):\(seconds)"
    }
}
