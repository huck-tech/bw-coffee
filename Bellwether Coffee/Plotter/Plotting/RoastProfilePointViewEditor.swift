//
//  RoastProfilePointViewEditor.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 5/14/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastProfilePointViewEditor: UIViewController {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    
    let timeFormatter = BWTimeFormatter(dateComponenetsFormatter: NumberFormatter.bw_secondsNumberFormatter)
    var tempFormatter = NumberFormatter.bw_temperatureNumberFormatter

    let vectorTempPickerDelegate = VectorTempPickerDelegate()
    
    var index: UInt?
    
    weak var controller: BWRoastProfileGraphViewController?
    
    var dataSource: BWRoastProfileGraphDataSource? {
        return self.controller?.roastProfileDataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true

        self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
        
        self.view.onTap(target: self, selector: #selector(editVector))
    }
    
    func load(index: UInt, controller: BWRoastProfileGraphViewController) {
        self.index = index
        self.controller = controller
        
        if let step = dataSource?.step(at: index) {
            self.tempLbl.text = self.tempFormatter.string(from: NSNumber.init(value: step.temp.asFahrenheit))
            self.timeLbl.text = self.timeFormatter.string(for: step.time)
        } else {
            print("\(#function)")
        }
    }
    
    @objc private func editVector() {
        guard let _ = minDuration, let _ = maxDuration else {return print("endpoint!")}
        // first, figure out the step
        let controller = RoastVectorViewController.bw_instantiateFromStoryboard()
        let _ = controller.view
        
        controller.timePicker.dataSource = self
        controller.timePicker.delegate = self
        
        controller.tempPicker.dataSource = vectorTempPickerDelegate
        controller.tempPicker.delegate = vectorTempPickerDelegate

        controller.delegate = self
        
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true)
    }
    
}

protocol VectorEditorPickerDelegate {
    var minDuration: TimeInterval?  {get}
    var maxDuration: TimeInterval?  {get}
    var time: TimeInterval?     {get}
    var temp: BWTemperature?     {get}
    func didSelect(time: TimeInterval, temp: BWTemperature)
}

class VectorTempPickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let temps: [BWTemperature] = Array(stride(from: Roaster.AMBIENT_TEMPERATURE, through:550.0, by:1))

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
      return "\(temps[row]) °"
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {return temps.count}
}

extension RoastProfilePointViewEditor: VectorEditorPickerDelegate {

    var minDuration: TimeInterval? {
        guard let time = dataSource?.step(before: index)?.time else {return nil}

        //we need to find the step before this one
        return time + TimeInterval(BWRoastProfile.minimumStepGap)
        
    }
    
    var maxDuration: TimeInterval? {
        guard let time = dataSource?.step(after: index)?.time else {return nil}
        
        return time - TimeInterval(BWRoastProfile.minimumStepGap)
    }
    
    var time: TimeInterval? {
        return dataSource?.step(at: index)?.time
    }
    
    var temp: BWTemperature? {
        return dataSource?.step(at: index)?.temp
    }
    
    func didSelect(time: TimeInterval, temp: BWTemperature) {
        guard let controller = controller, let index = index else {return}
        let step = BWRoastProfileStep(temperature: temp, time: time)
        
        //obtain the new graph point index for the step we just replaced.
        self.index = dataSource?.replaceStep(at: index, with: step)
        
        controller.dismiss(animated: true)
        
        //update the curve
        controller.stepHighlightPlot.reloadData()
        controller.roastProfilePlot.reloadData()

        //hide the point editor for now
        controller.pointEditor.view.isHidden = true
        
        //reload move the pointer to its new location
        DispatchQueue.main.async {[weak self] in
            guard let index = self?.index else {return print("nil index")}
            controller.showEditor(forPointAt: index)
        }

    }
}

extension RoastProfilePointViewEditor: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        guard let min = self.minDuration else {return nil}

        return timeFormatter.string(for: Int(min) + row)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //we must be between steps in order for anything to work
        guard let min = self.minDuration, let max = self.maxDuration else {return 0}
        
        //if we are too tight, then we cannot move on the time scale
        guard max - min > 0 else {return 0}
        
        //we offer second-resolution *between* these values.
        return Int(max - min) + 1
    }
}
