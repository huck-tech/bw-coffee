//
//  RoastVectorViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 5/15/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation


class RoastVectorViewController: UIViewController {
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var tempPicker: UIPickerView!
    @IBOutlet weak var timeBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.onTap(target: self, selector: #selector(close))
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //round the corners
        self.timeBox.layer.cornerRadius = 8.0
        self.timeBox.clipsToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let time = self.delegate?.time, let temp = self.delegate?.temp else {return}
        self.load(time: time, temp:temp)
    }
    
    var delegate: VectorEditorPickerDelegate?
    
    private var minDuration: TimeInterval {
        return self.delegate?.minDuration ?? 0.00
    }
    
    func load(time: TimeInterval, temp:BWTemperature) {
        let _ow = Int(time) - Int(minDuration)
        print("time row: \(_ow)")
        self.timePicker.selectRow(_ow, inComponent: 0, animated: false)
        
        let row = temp.asFahrenheit - Roaster.AMBIENT_TEMPERATURE
        guard row > 0 else {return print("illegal temperature \(row)")}
        self.tempPicker.selectRow((temp.asFahrenheit - Roaster.AMBIENT_TEMPERATURE).asInt, inComponent: 0, animated: true)
    }
    
    @IBAction func select(sender: Any) {
        self.dismiss(animated: true){[weak self] in
            guard let _self = self else {return}
            let time = TimeInterval(Int(_self.minDuration) + _self.timePicker.selectedRow(inComponent: 0) + 1)
            let temp = Double(_self.tempPicker.selectedRow(inComponent: 0)) + Roaster.AMBIENT_TEMPERATURE
            _self.delegate?.didSelect(time: time, temp:temp.asCelsius)
        }
    }
    
    @IBAction func cancel(_sender: Any) {
        self.dismiss(animated: true)
    }
}
