//
//  BeanDetailHeaderView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/30/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class BeanDetailHeaderView: View {
    
    var name: String? {
        didSet { updateInfo() }
    }
    
    var lbsAvailable: Double? {
        didSet { updateInfo() }
    }
    
    var coffeeDetails: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func updateInfo() {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        renderer.color = .white
        
        renderer.appendText(string: name ?? "", separateColor: .white)
        
        if let lbsText = lbsAvailable?.formattedLbs() {
            renderer.appendText(string: "\t\tAvailable To Roast: ", separateColor: .white)
            renderer.appendText(string: lbsText, separateColor: .brandPurple)
        }
        
        coffeeDetails.attributedText = renderer.renderedText
    }
    
}

// MARK: Layout

extension BeanDetailHeaderView {
    
    func setupAppearance() {
        backgroundColor = BellwetherColor.roast
    }
    
    func setupLayout() {
        addSubview(coffeeDetails)
        
        coffeeDetails.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        coffeeDetails.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        coffeeDetails.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    }
    
}
