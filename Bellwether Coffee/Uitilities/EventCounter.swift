//
//  EventCounter.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/1/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class EventCounter: NSObject {
    
    static let shared = EventCounter()
    
    var expirySeconds: Double = 600.0
    var expiryAction: (() -> Void)?
    
    private var timer: Timer!
    
    private var lastEvent: Double = 0.0
    private var recordingEvents: Bool = false
    
    override init() {
        super.init()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.recordingEvents else { return }
            
            self.lastEvent += 0.1
            
            if self.lastEvent > self.expirySeconds {
                self.recordingEvents = false
                self.expiryAction?()
                
            }
        }
    }
    
    func startRecordingEvents() {
        lastEvent = 0.0
        recordingEvents = true
    }
    
    func recordEvent() {
        lastEvent = 0.0
    }
    
}

extension EventCounter: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        recordEvent()
        return false
    }
    
}
