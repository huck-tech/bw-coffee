//
//  RoastRoasterSelectionViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoasterSelectionViewController: RoastingStepController {
    @IBOutlet weak var nextStepBtn: UIButton!

    weak var discoveryViewController: DiscoveryViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupAppearance()
        
        NotificationCenter.default.addObserver(forName: .roasterStateUpdated, object: nil, queue: nil, using: {[weak self] _ in
            self?.load()
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roasterStateUpdated, object: nil)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        self.nextStepBtn.roundCorners()
    }

    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let discoveryViewController = childController as? DiscoveryViewController {
            self.discoveryViewController = discoveryViewController
            self.discoveryViewController?.delegate = self
        }
    }
}

typealias IntHandler = (Int?) -> Void
typealias DoubleHandler = (Double?) -> Void
typealias BoolHandler = (Bool) -> Void
typealias UIntHandler = (UInt) -> Void
typealias DateHandler = (Date?) -> Void

extension RoasterSelectionViewController: DiscoveryDelegate {
    func didSelect(device: RoasterBLEDevice) {
        
        if Defaults.shared.defaultRoaster == device.roasterID || Defaults.shared.defaultRoaster == nil{
            //go ahead and select it...this is what we usually do
            self.select(device: device)
        } else {
            self.confirm(title: "Changing Default Roaster", message: "You are connecting to \(device.roasterID ?? "<New Roaster>") instead of your usual \(Defaults.shared.defaultRoaster ?? "<Default Roaster>"). Are you sure?") {
                [weak self] confirmed in
                if confirmed {
                    self?.select(device: device)
                }
            }
        }
    }
    
    func select(device: RoasterBLEDevice){
        if (!device.select()){
            self.confirm(title: "Connection Failure", message: "Could not connect to the roaster. Are you sure you are both on the same WiFi network?", cancellable: false)
        }
    }
    
    func devicesDidChange() {
        if let _ = Roaster.shared.device {
            self.roastingStepDelegate?.stepDidComplete()
        }
    }
}


func resetDefaultRoaster(_ sender: Any) {
    Roaster.shared.httpsServicesFactory.roastController?.stopPolling()
    Roaster.shared.device?.disconnect()
    Roaster.shared.device = nil
    Defaults.shared.clearDefaultRoaster()
}

class BuildUILabel: UILabel {
    override func awakeFromNib() {
        let build = Bundle.main.buildVersionNumber ?? "<unknown>"
        self.text = "App Build: \(build)"
    }
}

class StatusUILabel: UILabel {
    static var shared: StatusUILabel?
}

var lastStatus: String? {
    didSet {
        StatusUILabel.shared?.text = lastStatus
    }
}
