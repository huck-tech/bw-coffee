//
//  PoundPickerViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class PoundPickerViewController: UIViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var boxer: UIView!
    @IBOutlet weak var header: UILabel!
    
    
    var closeOnTapOutside = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.onTap(target: self, selector: #selector(close))
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    
    @objc func close() {
        guard closeOnTapOutside else {return}
        
        self.dismiss(animated: true)
    }
    
    private func updateSelection(){
        
        //select the row with the current value
        guard let item = item, let minVal = range.first else
        {return print("no item or minVal to work with")}
        
        let row = Int(self.quantity - minVal / item.increment)
        self.picker.selectRow(row, inComponent: 0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //round the courners
        self.boxer.layer.cornerRadius = 8.0
        self.boxer.clipsToBounds = true

        self.updateSelection()
    }
    
    var delegate: PoundPickerDelegate?
    var item: PoundPickerSource?
    

    private var range = [Double]() {
        didSet {
            if isViewLoaded {
                picker.reloadAllComponents()
            }
        }
    }

    var quantity: Double {return (item?.units ?? 0.0) / (item?.increment ?? 1.0)}
    
    func load(_ title: String? = nil, item: PoundPickerSource) {
        self.item = item
        if let _ = title {self.header.text = title}
        
        let increment = item.increment
        var max = (quantity + 200.0) * increment
        
        item.max {realMax in
            
            //if we have a real max to work with, use it instead.
//            if let realMax = realMax, realMax != 1.0 {
//                max = realMax
//            }
            
            self.range = Array(stride(from: 0.0, through: max, by: increment))

        }
    }
    
    @IBAction func select(sender: Any) {
        guard let item = item, let minVal = range.first, let maxVal = range.last else {return print("no roast item or range provided")}
        let row = picker.selectedRow(inComponent: 0)
        let units: Double = Double(minVal + row.asDouble * item.increment)
        
        self.item?.max { max in
            if let max = max {
                if max ==  -1.0 || max >= units {
                self.confirm(title: "Are you sure?", message: "The new quantity is \(units.formattedLbs(fractionDigits: 1)) lbs."){
                    [weak self] confirmed in
                    if confirmed {
                        self?.delegate?.didSelect(units: units, for: item)
                        self?.dismiss(animated: true)
                    }
                    }
                } else {
                    self.confirm(title: "Maximum Exceeded", message: "There are only \(max) lbs available at this time.")
                }
            } else {
                self.showNetworkError(message: "There was a problem fetching the maximum pounds; please try again.")
            }
        }
        


    }
    
    @IBAction func cancel(_sender: Any) {
        self.dismiss(animated: true)
    }
}

extension PoundPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return range.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return "\(range[row].formattedLbs(fractionDigits: 1))"
    }
}

protocol PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource)
}

protocol PoundPickerSource {
    var units: Double? {get}
    var increment: Double {get}
    func max(completion: @escaping DoubleHandler)
}


extension RoastItem: PoundPickerSource {
    var units: Double? {return self.stockQuantity ?? 0}
    var increment: Double {return 0.1}
    func max(completion: @escaping DoubleHandler) {return completion(-1.0)}
}

extension GreenItem: PoundPickerSource {
    //the basic implementation already conforms
    var units: Double? {return quantity ?? 0}
    var increment: Double {return 0.1}
    func max(completion: @escaping DoubleHandler) {return completion(-1.0)}
}

extension OrderItem: PoundPickerSource {
    var units: Double? {return self.quantity ?? 0}
    var increment: Double {return 22}
    func max(completion: @escaping DoubleHandler) {
        guard let beanId = self.bean else {return completion(nil)}
        BellwetherAPI.beans.getBean(id: beanId) {bean in
            completion(bean?.amount)
        }
    }
}
