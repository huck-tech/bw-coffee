//
//  GreenItemPickerViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/10/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

typealias GreenItemHandler = (GreenItem?) -> Void

class GreenItemPickerViewController: UIViewController {
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var boxer: UIView!
    
    var handler: GreenItemHandler?
    var items = [GreenItem]() {
        didSet {self.picker.reloadAllComponents()}
    }
    
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
        
        //obtain the current duration from the delegate or set to a default
        self.load()
        
        //round the corners
        self.boxer.layer.cornerRadius = 8.0
        self.boxer.clipsToBounds = true
    }
    
    func load() {
        BellwetherAPI.orders.getGreen {greenItems in
            guard let greenItems = greenItems else {return self.close()}
            
            self.items = greenItems
        }
    }
    
    @IBAction func select(sender: Any) {
        let index = picker.selectedRow(inComponent: 0)
        handler?(items[index])
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(_sender: Any) {
        self.dismiss(animated: true)
    }
}

extension GreenItemPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return items[row]._name
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}
