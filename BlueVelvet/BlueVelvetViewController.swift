//
//  ViewController.swift
//  BlueVelvet
//
//  Created by Marcos Polanco on 10/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import Eureka


class BlueVelvetViewController: FormViewController {
    
    var preheatTemp: IntRow?
    var beanWeight: IntRow?
    var stateIndicator: ActionSheetRow<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Settings")
            <<< SwitchRow(){ row in
                row.title = "Hopper"
            }
            <<< IntRow(){ row in
                row.title = "Preheat Temp"
                row.placeholder = "Enter °F"
            }
            <<< IntRow(){ row in
                row.title = "Bean Weight"
                row.placeholder = "Enter Lbs"
            }
            +++ Section("Section2")
            <<< ActionSheetRow<String>() {
                self.stateIndicator = $0
                $0.title = "Roaster State"
                $0.selectorTitle = "Choose a State"
                $0.options = BWRoasterDeviceRoastState.all.map({$0.stringValue})
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stateIndicator?.title = "You win!"
        stateIndicator?.value = BWRoasterDeviceRoastState.ready.stringValue
    }
}
