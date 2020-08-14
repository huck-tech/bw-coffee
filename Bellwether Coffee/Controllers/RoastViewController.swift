//
//  RoastViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class RoastViewController: UIViewController {
    
    lazy var overlay: RoastOverlayView = {
        let roastOverlayView = RoastOverlayView(frame: .zero)
        roastOverlayView.delegate = self
        roastOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return roastOverlayView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        /*
         
         case selectBeanAmount
         case loadBeans
         case returnHopper
         case readyToRoast
         case preheat
         case roasting
         case cooling
         case finished
         
        */
        
        RoastStateManager.shared.updateControlStateAction = { [weak self] controlState in
            if controlState == .selectBeanAmount {
                self?.overlay.navigateToPrompt(state: controlState)
            }
            
            if controlState == .loadBeans {
                self?.overlay.navigateToPrompt(state: controlState)
            }
            
            if controlState == .returnHopper {
                
            }
            
            if controlState == .readyToRoast {
                
            }
            
            if controlState == .preheat {
                
            }
            
            if controlState == .roasting {
                
            }
            
            if controlState == .cooling {
                
            }
            
            if controlState == .finished {
                
            }
        }
    }
    
    func returnHopper() {
        // somehow listen for this event when hardware supports it
        RoastStateManager.shared.controlState = .readyToRoast
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        returnHopper()
    }
    
}

extension RoastViewController: RoastOverlayViewDelegate {
    
    func roastOverlayDidSelectBeanAmount(amount: Double) {
        overlay.loadBeans.loadBeansAmount = amount
        
        RoastStateManager.shared.desiredLbs = amount
        RoastStateManager.shared.controlState = .loadBeans
    }
    
    func roastOverlayDidLoadBeans() {
        RoastStateManager.shared.controlState = .returnHopper
    }
    
}

// MARK: Layout

extension RoastViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(overlay)
        
        overlay.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        overlay.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        overlay.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}
