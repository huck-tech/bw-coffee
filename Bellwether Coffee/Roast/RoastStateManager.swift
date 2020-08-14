//
//  RoastStateManager.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

enum RoastState {
    case off
    case preheat
    case beansDrop
    case roasting
    case cooling
}

enum RoastControlState {
    case selectBeanAmount
    case loadBeans
    case returnHopper
    case readyToRoast
    case preheat
    case roasting
    case cooling
    case finished
}

class RoastStateManager {
    
    static let shared = RoastStateManager()
    
    var roastState: RoastState = .off
    
    var controlState: RoastControlState = .selectBeanAmount {
        didSet { updateControlState() }
    }
    
    var desiredLbs: Double = 0.5
    
    var estimatedLbs: Double = 0.5
    
    var loadedLbs: Double = 0.0
    
    var preheatTemp: Double = 0.0 // when this goes up to starting temp beans drop
    
    var weighBeansAction: ((Double) -> Void)?
    
    var updateControlStateAction: ((RoastControlState) -> Void)?
    
    func updateControlState() {
        updateControlStateAction?(controlState)
    }
    
}
