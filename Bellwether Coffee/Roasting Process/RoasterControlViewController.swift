//
//  RoasterControlViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/19/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class RoasterControlViewController: UIViewController {
    @IBOutlet weak var preheatButton: UIButton!
    @IBOutlet weak var bellwetherlogo: UIImageView!

    func setupAppearance() {
        self.preheatButton.roundCorners()
    }
    
    @objc private func load() {
        self.preheatButton.backgroundColor = Roaster.shared.isConnected ? UIColor.brandPurple : UIColor.lightGray
        self.preheatButton.isEnabled = Roaster.shared.isConnected
        
        let buttonTitle: String
        
        //change the button title according to the state...the 'preheat' command can only be accepted at some times
        switch Roaster.shared.state {
        case .reset, .initialize, .offline, .shutdown, .error:
            buttonTitle = "Waiting"
        case .ready:
            buttonTitle = "Preheat"
        case .preheat, .roast, .cool:
            //the button title should actually be the Roaster temperature
            buttonTitle  = NumberFormatter.bw_formattedTemperature(Roaster.shared.temperature)
        }
        
        self.preheatButton.setTitle(Roaster.shared.isConnected ? buttonTitle : "None", for: .normal)
        
        if Roaster.shared.state == .preheat || Roaster.shared.state == .roast {
            self.animate()
        }
    }
    
    @IBAction func preheatTapped(_ sender: Any) {
        guard RoastingProcess.roasting.state == .none else {
            (self.navigationController as? NavigationController)?.showRoast()
            return
        }
        
        //are we preheating? We can cancel that.
        if Roaster.shared.state == .preheat {
            self.confirm(title: "Are you sure you want to cancel preheat?") {confirmed in
                if confirmed {
                    Roaster.shared.shouldPreheat = false
                    Roaster.shared.shutdown()
                    
                    //get comments to explain the shutdown
                    RoastLogCommentsViewController.showComments(for: nil)
                }
            }
        } else if Roaster.shared.state == .roast || Roaster.shared.state == .cool {
            //if we are cooling, we just have to wait. But we should be able to send the user to the roasting screen
            (self.navigationController as? NavigationController)?.showRoast()
        } else {
            Roaster.shared.shouldPreheat = true
            if !AppDelegate.isProduction {Roaster.shared.preheat()} // deactivate preheat button in production
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get an inverted version of the bellwether logo
        self.bellwetherlogo.image = self.bellwetherlogo.image?.inverted()
        
        NotificationCenter.default.addObserver(forName: .roasterStateUpdated, object: nil, queue: nil, using: {[weak self] _ in
            self?.load()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
        
        //even when run after autolayout, the preheatButton bounds are not properly
        // in place, so run it one loop later with async.
        DispatchQueue.main.async{[weak self] in
            self?.setupAppearance()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roasterStateUpdated, object: nil)
    }
    
    //note that the animation relies on the call site (load()) to continue. We only animate
    //if the roaster is preheating or roasting
    @objc private func animate() {
        //go ahead only if the view is being presented
        guard self.viewIfLoaded?.window != nil else {return}
        
        UIView.animate(withDuration: 1.0) {[weak self ] in
            guard let _self = self else {return}
            
            //every second, either expand to ANIMATION_SCALE or contract back to 1
            let y = Date().timeIntervalSinceReferenceDate.asInt % 2 == 0 ? 1.02 : 1
            let x = CGFloat(y)
            _self.bellwetherlogo.transform = CGAffineTransform(scaleX: x, y: x)

            //only needed if we are running the animation without the benefit of roaster updates
//            _self.perform(#selector(_self.animate), with: nil, afterDelay: 1.0)
        }
    }
}

extension UIImage {
    func inverted() -> UIImage? {
        var image: UIImage?
        UIGraphicsBeginImageContext(self.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setBlendMode(.copy)
            let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            self.draw(in: imageRect)
            context.setBlendMode(.difference)
            // translate/flip the graphics context (for transforming from CG* coords to UI* coords
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            //mask the image
            context.clip(to: imageRect, mask: self.cgImage!)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y:0, width: self.size.width, height: self.size.height))
            
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}

