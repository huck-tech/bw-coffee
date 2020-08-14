//
//  Sounds.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import AVFoundation

class Sounds {
    
    static let shared = Sounds()
    
    var audioNames = [""]
    
    private var audioPlayers = [String: AVPlayer]()
    
    init() {
        audioNames.forEach { name in
            guard let audioUrl = Bundle.main.url(forResource: name, withExtension: "m4a") else { return }
            
            let player = AVPlayer(url: audioUrl)
            audioPlayers[name] = player
        }
    }
    
    func play(soundName: String) {
        guard let player = audioPlayers[soundName] else { return }
        
        player.seek(to: kCMTimeZero)
        player.play()
    }
    
}
