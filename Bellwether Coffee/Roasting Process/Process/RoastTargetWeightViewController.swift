//
//  RoastTargetWeightViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastTargetWeightViewController: RoastingStepController {    
    let weights: [Double] = Array(stride(from: 0.1, through: 5.7, by: 0.2))
    
    @IBOutlet weak var weightPicker: UIPickerView!
    @IBOutlet weak var nextStepBtn: UIButton!
    
    override func undo() {
        RoastingProcess.roasting.targetWeight = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupAppearance()
    }
    override func setupAppearance() {
        super.setupAppearance()
        
        self.nextStepBtn.roundCorners()
    }
    
    private func select(selected: Int){
        RoastingProcess.roasting.targetWeight = weights[selected]
        self.roastingStepDelegate?.stepDidComplete()
    }

    @IBAction func nextStep(_ sender: Any) {
        let selected = weightPicker.selectedRow(inComponent: 0)
        if RoastingProcess.roasting.greenItem?.quantity == nil  {
            self.confirm(title: "Enough Inventory?", message: "Could not retrieve the current green inventory, so please make sure you have enough.", cancellable: true) {confirmed in
                if confirmed { self.select(selected: selected) }
            }
        } else if let existing = RoastingProcess.roasting.greenItem?.quantity,
            let shrinkage = RoastingProcess.roasting.roastProfile?.shrinkage,
            existing < weights[selected] * (1.0 + shrinkage) { // we need at least enough existing to cover target *and* shrinkage
            self.confirm(title: "Enough Inventory?", message: "Inventory seems to be \(existing) lbs, so not quite enough. Continue?", cancellable: true) {[weak self] confirmed in
                if confirmed { self?.select(selected: selected) }
            }
        } else {self.select(selected: selected)}
    }
}

extension RoastTargetWeightViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        weightPicker.drawWhiteSeparators()
        
        let title = weights[row].description
        return NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font:
                UIFont(name: "AvenirNext-DemiBold", size: 22.0)!
            ])
    }
}

extension RoastTargetWeightViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weights.count
    }
}
