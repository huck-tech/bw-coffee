//
//  RoastHopperHomingViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class RoastHopperHomingViewController: RoastingStepController, BeanExitActionHandler {
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var confirmation: UILabel!
    @IBOutlet weak var startRoastBtn: UIButton!
    @IBOutlet weak var hopperSwitch: UISwitch!
    @IBOutlet weak var hopperImage: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
        
        //workaround...if you want to skip hopper detection, just tap the image
        self.hopperImage.onTap(target: self, selector: #selector(insertHopper))
        
        startRoastBtn.enable(true)
    }
    
    @objc func insertHopper() {
        Roaster.shared.hopperInserted = true
    }
        
    override internal func load() {
        
        instructions.isHidden = Roaster.shared.hopperInserted
        hopperImage.isHidden = Roaster.shared.hopperInserted
        confirmation.isHidden = !Roaster.shared.hopperInserted
        startRoastBtn.isHidden = !Roaster.shared.hopperInserted
        
        startRoastBtn.setTitle(Roaster.shared.hopperInserted ? "Start Roast" : "Start Again", for: .normal)
        startRoastBtn.backgroundColor = Roaster.shared.hopperInserted ? UIColor.brandPurple : UIColor.brandDisabled
        
        //ensure we have an input weight to work with
        guard let inputWeight = RoastingProcess.roasting.inputWeight,
            let roastProfileName = RoastingProcess.roasting.roastProfile?.metadata?.name else {return}
        
        let weight: Double = round(inputWeight * 10)/10
        confirmation.text = "\(weight.asComparable.display) of \(Roasting.roasting.coffeeName ?? "?") is ready to be roasted with the \(roastProfileName) roast profile."
        
//        checkMaintenanceActions()
    }
    
    func checkMaintenanceActions(){
        MaintenanceEvent.actionRequired {[weak self] action in
            
            //we always enable roasting upon returning from the closure
            self?.startRoastBtn.enable(true)
            guard let action = action else {
                self?.confirm(title: "Maintenance Warning", message: "Could not immediately verify when last chaff and glass maintenance was performed. Proceed with care.")
                return
            }
            
            //if nothing to do, get out of here
            guard action != .none else {return}
            
            let message: String
            switch (action){
            case .none: return
            case .cleanGlass: message = "Please clean glass.\n"
            case .emptyChaff: message = "Please empty chaff.\n"
            }

            self?.confirm(title: "Maintenance Required", message: message, ok: action.stringValue){confirmed in
                if confirmed {MaintenanceEvent.take(action, completion: {success in
                    self?.confirm(title: "Network Error", message:"Could not record your action. Please try again later.")
                })}
            }
        }
    }
    
    func didCompleteBeanExitAction(){
        self.requestRoast()
    }
    
    private func requestRoast(){
        RoasterCommander.shared.beanExitState {[weak self] bxs in
            guard bxs == .closed else {
                if let _self = self {
                    //if the bean exit door is not closed, we are in trouble
                    BeanExitViewController.clearBeanExit(bxs: bxs, handler: _self)
                }
                return
            }
            
            RoastingProcess.roasting.state = .requested
            self?.roastingStepDelegate?.stepDidComplete()

        }
    }
    
    @IBAction func takeAction(_ sender: Any) {
        if Roaster.shared.hopperInserted {
            self.requestRoast()
        } else {
            self.startAgain(self)
        }

    }
    
    override func hopperChanged(inserted: Bool) {
        //has the request already been made? In this case, exit.
        if RoastingProcess.roasting.state == .requested || RoastingProcess.roasting.state == .started || RoastingProcess.roasting.state == .roasting {
            self.roastingStepDelegate?.stepDidComplete()
        } else {
            //we are getting going, so we reload to let the user start the roast
            self.load()
        }
    }
 }

