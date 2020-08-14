//
//  RoastInputWeightViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SnapKit

class RoastInputWeightViewController: RoastingStepController {
    
    @IBOutlet weak var weightView: UIView!
//    @IBOutlet weak var weightFeedback: NSLayoutConstraint!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var weightMeasured: UILabel!
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var tareBtn: UIButton!
    

    var inputWeight: Double?
    
    var autoraise = false {
        didSet {
            autoraise ? raiseInputWeight() : readInputWeight()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weightView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(0)
        }
    }
    
    @objc func toggleRaise() {
        self.autoraise = !autoraise
    }
    
    override func undo() {
        RoastingProcess.roasting.inputWeight = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
        
        self.inputWeight = 0
        if let _ = Roaster.shared.device as? MockRoasterDevice {
            self.raiseInputWeight()
        } else {
            self.readInputWeight()
        }
        
        //turn off the button if the scale auto-tares
        NotificationCenter.default.addObserver(forName: .scaleAutoTared, object: nil, queue: nil, using: {
            [weak self] notification in
            guard let scaleState = notification.object as? ScaleState else {return}
            switch scaleState {
            case .unstable:
                self?.tareBtn.setTitle("Changing", for: .normal)
                self?.tareBtn.backgroundColor = .lightGray
                self?.tareBtn.isEnabled = false
            case .tareable, .nonzero:
                self?.tareBtn.setTitle("Tare", for: .normal)
                self?.tareBtn.backgroundColor = .brandPurple
                self?.tareBtn.isEnabled = true
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .scaleAutoTared, object: nil)
    }
    
    @objc func raiseInputWeight() {
        guard autoraise else {return print("autoraise off , so turning off raiseInputWeight")}
        
        guard let inputWeight = inputWeight, inputWeight < 6.9 else {return}
        
        let increment = weightRatio > 1 ? -0.05 : 0.05
        self.inputWeight = inputWeight + increment
        
        //reload UI
        self.load()
        if weightRatioIsOne {return} //stop going up when we reach our target
        self.perform(#selector(raiseInputWeight), with: nil, afterDelay: 0.02)
    }
    
    func readInputWeight() {
        guard !autoraise else {return print("autoraise, so turning off readInputWeight")}
        Roaster.shared.getInputWeight {[weak self] vratio, weight, error in
            if var weight = weight {
                if weight < 0 {weight = 0}
                self?.inputWeight = weight
                self?.load()
            } else {
                print("\(#function).\(error.debugDescription ?? "")") //@fixme
            }
            
            //read the weight again as long as this view in on-screen
            if let _self = self, _self.isOnScreen {
                _self.readInputWeight()
            }
        }
    }
    
    @IBAction func tareTapped(_ sender: Any) {
        Roaster.shared.tare()
    }
    
    @IBAction func weightChanged(_ sender: Any) {
        self.inputWeight = (sender as? UISlider)?.value.asDouble
        self.load()
    }
    
    private var heightRatio: CGFloat {
        guard let navigator = self.navigationController else {return 1.0}
        return self.view.bounds.height / (self.view.bounds.height + navigator.navigationBar.frame.height)
    }
    
    override internal func load() {
        let weightToLoad = RoastingProcess.roasting.weightToLoad(inputWeight: self.inputWeight) ?? 0.0
        let inputWeight =  self.inputWeight ?? 0.0
        
        let weight: Double = round(weightToLoad * 10)/10
        self.instructions.text = "Load \(weight.asComparable.display) lbs of beans into the hopper."
        self.weightMeasured.text = "\(inputWeight.asComparable.display) lbs"
        
        
        //91% is temporary fix to end below the nav
        weightView.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(self.view.bounds.height * CGFloat(weightRatio) * heightRatio)
        }
        
        weightMeasured.textColor = isOverweight ? self.overweightRed : UIColor.white
        nextStepBtn.isEnabled = weightRatioIsOne
        nextStepBtn.backgroundColor = weightRatioIsOne ? UIColor.brandPurple : .lightGray
        nextStepBtn.roundCorners()
        tareBtn.roundCorners()

        skipBtn.isEnabled = !nextStepBtn.isEnabled
        skipBtn.backgroundColor = weightRatioIsOne ? .lightGray : UIColor.brandPurple
        skipBtn.roundCorners()
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.toggleRaise()
    }
    
    @IBAction func nextStepTapped(_ sender: Any) {
        //only make the input weight available once the user has tapped here.
        RoastingProcess.roasting.inputWeight = self.inputWeight
        self.roastingStepDelegate?.stepDidComplete()
    }
    
    var weightRatioIsOne: Bool {
        return weightRatio == 1.0
    }
    
    var weightRatio: Double {
        guard let inputWeight =  self.inputWeight?.asComparable,
            let weightToLoad = RoastingProcess.roasting.weightToLoad(inputWeight: self.inputWeight)?.asComparable else {
                return 0.0
        }
        return Double(inputWeight) / Double(weightToLoad)
    }
    
    var isOverweight: Bool  {
        return weightRatio > 1.0
    }
    
    var overweightRed: UIColor {
        return UIColor.init(hex: "EF6749")
    }
}
//extension Double {var asRound: Double {return round(Double(self)*10)/10}}

extension Float {var asDouble: Double {return Double(self)}}

extension UIColor {
    static let brandRoast = UIColor.init(hex: "3A3333")
    static let brandText = UIColor.init(hex: "3E4348")
    static let brandJolt = UIColor.init(hex: "EF6749")//
    static let warning = UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
    static let brandBrass = UIColor.init(hex:"ECBEAA")
    static let brandPurple = UIColor.init(hex:"7876E0")
    static let brandDisabled = UIColor.init(hex: "C7C7CD")
    static let brandSoil = UIColor.init(hex: "C2B49C")
    static let brandMilk = UIColor.init(hex: "EDEAE4")
    static let brandIce = UIColor.init(hex: "F4F5F9")
    
    static let grayBg = UIColor.init(hex:"575151")
    static let brandBackground = UIColor.init(hex: "3B3B3B")
}

extension String {var asInt: Int? {return Int(self)}}
extension String {var asDouble: Double? {return Double(self)}}
extension Int {var asNumber: NSNumber {return NSNumber.init(value: self)}}
extension Double {var asComparable: Int {return Int(self*10)}}
extension Double {var asInt: Int {return Int(self)}}
extension Double {var asFloat: Float {return Float(self)}}
extension Double {var asNumber: NSNumber {return NSNumber(value:self)}}

//string representation of the weight
extension Int {var display: String {return "\(self/10).\(self%10)"}}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
