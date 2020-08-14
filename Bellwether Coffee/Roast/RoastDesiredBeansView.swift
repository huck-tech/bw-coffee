//
//  RoastDesiredBeansView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol RoastDesiredBeansViewDelegate: class {
    func roastDesiredBeansDidSelect(amount: Double)
}

class RoastDesiredBeansView: View {
    
    weak var delegate: RoastDesiredBeansViewDelegate?
    
    var currentAmount: Double = 0.5
    
    var prompt: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "How many lbs of this roast would you like to end up with?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var lbsPicker: UIPickerView = {
        let picker = UIPickerView(frame: .zero)
        picker.delegate = self
        picker.tintColor = .white
        picker.showsSelectionIndicator = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    lazy var nextStep: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(nextTitle, for: .normal)
        button.backgroundColor =  .brandPurple
        button.tintColor =  .brandPurple
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
    
    override func setupViews() {
//        backgroundColor = .red
        
        addSubview(prompt)
        
        prompt.topAnchor.constraint(equalTo: topAnchor, constant: 80).isActive = true
        prompt.widthAnchor.constraint(equalToConstant: 248).isActive = true
        prompt.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(lbsPicker)
        
        lbsPicker.topAnchor.constraint(equalTo: prompt.bottomAnchor).isActive = true
        lbsPicker.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lbsPicker.widthAnchor.constraint(equalToConstant: 64).isActive = true
        lbsPicker.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(nextStep)
        
        nextStep.topAnchor.constraint(equalTo: lbsPicker.bottomAnchor, constant: 4).isActive = true
        nextStep.widthAnchor.constraint(equalToConstant: 140).isActive = true
        nextStep.heightAnchor.constraint(equalToConstant: 32).isActive = true
        nextStep.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    @objc func selectNext() {
        delegate?.roastDesiredBeansDidSelect(amount: currentAmount)
    }
    
}

extension RoastDesiredBeansView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 12
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let renderer = TextRenderer()
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        
        let amount = Double(row) / 2 + 0.5
        renderer.appendText(string: "\(amount)")
        
        return renderer.renderedText
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let amount = Double(row) / 2 + 0.5
        currentAmount = amount
    }
    
}
