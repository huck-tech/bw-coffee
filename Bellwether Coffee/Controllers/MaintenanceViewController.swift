//
//  MaintenanceViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 11/26/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class MaintenanceViewController: UIViewController {
    @IBOutlet weak var roasterNameLabel: UILabel!
    @IBOutlet weak var chaffChanStats: UILabel!
    @IBOutlet weak var cleanGlassStats: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.load()
    }

    private func load(){
        guard let roasterName =  Roaster.shared.device?.roasterID,
            let serialNumber = Roaster.shared.serialNumber else {
                //we are not connected to a roaster, so get out of here.
                return
        }
        
        roasterNameLabel.text = "\(roasterName)(\(serialNumber))"
        
        update(action: .cleanGlass, configuration: .cleanGlassPoundLimit, label: self.cleanGlassStats)
        update(action: .emptyChaff, configuration: .emptyChaffPoundsLimit, label: self.chaffChanStats)
    }
    
    private func update(action: MaintenanceAction, configuration: AppConfiguration.Keys, label: UILabel){
        MaintenanceEvent.poundsSinceLast(action, cached:true) {pounds, error in
            guard error == nil,
                let pounds = pounds else {
                    label.text = "<N/A>"
                    return
            }
            
            AppConfiguration.value(for: configuration, completion: {limit in
                guard let limit = limit else {return} // should never happen, because limit is never nil
                label.text = "\(pounds.formattedLbs(fractionDigits: 1))/\(limit)"
            })
        }
    }
    
    @IBAction func cleanGlass(_ sender: Any){
        MaintenanceEvent.take(.cleanGlass) {[weak self] _ in
            self?.load()
        }
    }
    @IBAction func emptyChaffCan(_ sender: Any){
        MaintenanceEvent.take(.emptyChaff) {[weak self] _ in
            self?.load()
        }
    }

}
