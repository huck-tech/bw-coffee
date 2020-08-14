//
//  RoastReturnHopperView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class RoastReturnHopperView: View {
    
    var prompt: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Place the hopper back into it's home."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var hopper: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "hopper_return")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func setupViews() {
        addSubview(prompt)
        
        prompt.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        prompt.widthAnchor.constraint(equalToConstant: 248).isActive = true
        prompt.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(hopper)
        
        hopper.topAnchor.constraint(equalTo: prompt.bottomAnchor, constant: 34).isActive = true
        hopper.widthAnchor.constraint(equalToConstant: 230).isActive = true
        hopper.heightAnchor.constraint(equalToConstant: 230).isActive = true
        hopper.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
}
