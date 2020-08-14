//
//  RoastLoadBeans.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol RoastLoadBeansViewDelegate: class {
    func roastLoadBeansDidFinish()
}

class RoastLoadBeansView: View {
    
    weak var delegate: RoastLoadBeansViewDelegate?
    
    var loadBeansAmount: Double = 0.5 {
        didSet { updateLoadBeansAmount() }
    }
    
    var loadedBeansAmount: Double = 0.0 {
        didSet { updateLoadedBeansAmount() }
    }
    
    var prompt: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var loadedBeans: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 36)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nextStep: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(nextTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(selectNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var nextTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Next Step")
        return renderer.renderedText
    }()
    
    var pulsing = false
    
    var nextEnabled = false {
        didSet { updateNextEnabled() }
    }
    
    override func setupViews() {
        addSubview(prompt)
        
        prompt.topAnchor.constraint(equalTo: topAnchor, constant: 80).isActive = true
        prompt.widthAnchor.constraint(equalToConstant: 248).isActive = true
        prompt.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(loadedBeans)
        
        loadedBeans.topAnchor.constraint(equalTo: prompt.bottomAnchor, constant: 32).isActive = true
        loadedBeans.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadedBeans.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loadedBeans.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(nextStep)
        
        nextStep.topAnchor.constraint(equalTo: loadedBeans.bottomAnchor, constant: 28).isActive = true
        nextStep.widthAnchor.constraint(equalToConstant: 140).isActive = true
        nextStep.heightAnchor.constraint(equalToConstant: 32).isActive = true
        nextStep.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        loadedBeansAmount = 0.7
    }
    
    func updateLoadBeansAmount() {
        prompt.text = "Load \(loadBeansAmount) lbs of beans into the hopper."
        updateLoadedBeansAmount()
    }
    
    func updateLoadedBeansAmount() {
        nextEnabled = loadedBeansAmount >= loadBeansAmount
        
        loadedBeans.text = "\(loadedBeansAmount) lbs."
        
        if loadedBeansAmount > loadBeansAmount + 0.1 {
            guard !pulsing else { return }
            startPulsing()
        } else {
            guard pulsing else { return }
            stopPulsing()
        }
    }
    
    func updateNextEnabled() {
        if nextEnabled {
            nextStep.isEnabled = true
            nextStep.backgroundColor = .brandPurple
        } else {
            nextStep.isEnabled = false
            nextStep.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        }
    }
    
    @objc func selectNext() {
        delegate?.roastLoadBeansDidFinish()
    }
    
    func startPulsing() {
        pulsing = true
        loadedBeans.textColor = BellwetherColor.red
        
        pulse()
    }
    
    func stopPulsing() {
        pulsing = false
        loadedBeans.textColor = .white
    }
    
}

// MARK: Animations

extension RoastLoadBeansView {
    
    func pulse() {
        guard pulsing else { return }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0) { [unowned self] in
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: { [unowned self] in
                self.loadedBeans.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: { [unowned self] in
                self.loadedBeans.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [unowned self] in
            self.pulse()
        }
    }
    
}
