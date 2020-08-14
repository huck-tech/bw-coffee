//
//  RoastingStepController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/16/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastingStepController: UIViewController, RoasterDelegate {
    @IBOutlet weak var backBtn: UIImageView?
    
    var roastingStepDelegate: RoastingStepDelegate?
    var updateEachSecondFlag: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.acceptInvalidSSLCerts() //temporarily, until we make system more secure
        self.setupAppearance()
        
        if let _ = self.backBtn {
//            self.backBtn?.image = UIImage(named: "chevron")?.inverted()
//            self.backBtn?.onTap(target: self, selector: #selector(back))
            self.backBtn?.isHidden = true
        }
    }
    
    @IBAction func startAgain(_ sender: Any) {
        //        self.roastingStepDelegate?.goBack()
    }
    
    func setupAppearance() {
        self.view.backgroundColor = UIColor.grayBg
    }
    
    @objc func back() {
        self.undo()
        self.roastingStepDelegate?.goBack()
    }
    
    func undo() {
    }
    
    @objc internal func updateEachSecond() {
        
        //go ahead only if the virew is being presentes
        guard updateEachSecondFlag, isOnScreen else {return}
        
        self.load()
        
        self.perform(#selector(updateEachSecond), with: nil, afterDelay: 1)
    }
    
    internal func load() {
        
    }
    
    var storyboardID: String {
        return type(of: self).storyboardID
    }
    
    //extension RoastingStepController: RoasterDelegate {
    func roasterUpdated(status: BWRoasterDeviceRoastStatus?){
        self.load()
    }
    
    func hopperChanged(inserted: Bool) {
        self.load()
    }
    func roaster(available: Bool){}
    func roasterIsReadyToRoast() {}
    func roastDidStart() {}
    func roast(didAppend newMeasurement: BWRoastLogMeasurement) {}
    func roast(didChange summary: BWRoastLogSummaryBlank) {}
    func roastDidChangeState(from oldState: BWRoasterDeviceRoastState,
                             to newState: BWRoasterDeviceRoastState) {}
    func roastCooling() {}
    func roastDidFinish() {}
    func roastDidFail(with error: NSError) {}
}

