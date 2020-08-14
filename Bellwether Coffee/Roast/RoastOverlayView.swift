//
//  RoastOverlayView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol RoastOverlayViewDelegate: class {
    func roastOverlayDidSelectBeanAmount(amount: Double)
    func roastOverlayDidLoadBeans()
}

class RoastOverlayView: View {
    
    weak var delegate: RoastOverlayViewDelegate?
    
    var prompt: RoastPromptNavigationView = {
        let promptNavigation = RoastPromptNavigationView(frame: .zero)
        promptNavigation.translatesAutoresizingMaskIntoConstraints = false
        return promptNavigation
    }()
    
    lazy var desiredBeans: RoastDesiredBeansView = {
        let desiredBeans = RoastDesiredBeansView(frame: .zero)
        desiredBeans.delegate = self
        desiredBeans.translatesAutoresizingMaskIntoConstraints = true
        return desiredBeans
    }()
    
    lazy var loadBeans: RoastLoadBeansView = {
        let loadBeans = RoastLoadBeansView(frame: .zero)
        loadBeans.delegate = self
        loadBeans.translatesAutoresizingMaskIntoConstraints = true
        return loadBeans
    }()
    
    lazy var returnHopper: RoastReturnHopperView = {
        let returnHopper = RoastReturnHopperView(frame: .zero)
        returnHopper.translatesAutoresizingMaskIntoConstraints = true
        return returnHopper
    }()
    
    var hud: RoastHudNavigationView = {
        let view = RoastHudNavigationView(frame: .zero)
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var roastInfo: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "6.2 lbs of Brazil Santa Luzia is ready to be roasted in a light roast profile."
        label.alpha = 0.0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
        
        setupPages()
    }
    
    func setupPages() {
        prompt.pageViews = [desiredBeans, loadBeans, returnHopper]
    }
    
    func navigateToPrompt(state: RoastControlState) {
        prompt.navigateToPage(index: state.hashValue)
        showPrompt()
    }
    
    func navigateToHud() {
        
        showHud()
    }
    
    func showPrompt() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.prompt.alpha = 1.0
            self.hud.alpha = 0.0
        }
    }
    
    func showHud() {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.prompt.alpha = 0.0
            self.hud.alpha = 1.0
        }
    }
    
}

extension RoastOverlayView: RoastDesiredBeansViewDelegate, RoastLoadBeansViewDelegate {
    
    func roastDesiredBeansDidSelect(amount: Double) {
        delegate?.roastOverlayDidSelectBeanAmount(amount: amount)
        
        loadBeans.loadBeansAmount = amount
        RoastStateManager.shared.controlState = .loadBeans
    }
    
    func roastLoadBeansDidFinish() {
        prompt.navigateForwardst()
    }
    
}

// MARK: Layout

extension RoastOverlayView {
    
    func setupAppearance() {
        backgroundColor = BellwetherColor.roastOverlay
    }
    
    func setupLayout() {
        addSubview(prompt)
        
        prompt.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        prompt.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        prompt.widthAnchor.constraint(equalToConstant: 420).isActive = true
        prompt.heightAnchor.constraint(equalToConstant: 420).isActive = true
        
        addSubview(hud)
        
        hud.topAnchor.constraint(equalTo: topAnchor).isActive = true
        hud.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        hud.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        hud.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        hud.addSubview(roastInfo)
        
        roastInfo.widthAnchor.constraint(equalToConstant: 420).isActive = true
        roastInfo.heightAnchor.constraint(equalToConstant: 420).isActive = true
        roastInfo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        roastInfo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
