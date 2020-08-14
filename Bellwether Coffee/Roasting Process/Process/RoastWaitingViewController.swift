//
//  RoastWaitingViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/16/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastWaitingViewController: RoastingStepController {
    @IBOutlet weak var message: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
    }
    
    override func load() {
//        Roaster.shared.shutdown()
        
        RoastingProcess.reset()
        
        self.confirm(title: "Roast Aborted", message: "It seems like the roaster reset, so could not continue with the roast.",  cancellable: false) {_ in
            self.roastingStepDelegate?.stepDidComplete()
        }
        
    }
}
