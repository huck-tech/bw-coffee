//
//  DashboardCardView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardCardView: ComponentView {
    
    var componentName: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "OpenSans-Semibold", size: 15)
        label.formatColor = BellwetherColor.gold
        label.formatSpacing = 5
        label.formatCase = .uppercase
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var highlightInfo: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "OpenSans-Light", size: 48)
        label.formatColor = UIColor(white: 0.4, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var descriptionInfo: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "OpenSans-Semibold", size: 15)
        label.formatColor = UIColor(white: 0.4, alpha: 1.0)
        label.formatLineSpacing = 3
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var additionalInfo: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "OpenSans-Semibold", size: 15)
        label.formatColor = UIColor(white: 0.6, alpha: 1.0)
        label.formatLineSpacing = 3
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var learnMore: UIButton = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "OpenSans-Semibold", size: 13)
        renderer.color = UIColor(white: 0.8, alpha: 1.0)
        renderer.spacing = 2
        renderer.appendText(string: "Learn More".uppercased())
        
        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .left
        button.setAttributedTitle(renderer.renderedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
        layer.masksToBounds = true
        layer.cornerRadius = 6
        
        layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
        layer.shadowRadius = 36
        layer.shadowOpacity = 0.05
    }
    
    func setupLayout() {
        addSubview(componentName)
        
        componentName.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        componentName.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        componentName.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        componentName.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(highlightInfo)
        
        highlightInfo.topAnchor.constraint(equalTo: componentName.bottomAnchor, constant: 4).isActive = true
        highlightInfo.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        highlightInfo.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        addSubview(descriptionInfo)
        
        descriptionInfo.centerYAnchor.constraint(equalTo: highlightInfo.centerYAnchor).isActive = true
        descriptionInfo.leftAnchor.constraint(equalTo: highlightInfo.rightAnchor, constant: 12).isActive = true
        descriptionInfo.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(additionalInfo)
        
        additionalInfo.topAnchor.constraint(equalTo: highlightInfo.bottomAnchor, constant: 6).isActive = true
        additionalInfo.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        additionalInfo.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(learnMore)
        
        learnMore.topAnchor.constraint(equalTo: additionalInfo.bottomAnchor, constant: 6).isActive = true
        learnMore.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        learnMore.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bottomAnchor.constraint(equalTo: learnMore.bottomAnchor, constant: 16).isActive = true
    }
    
}
