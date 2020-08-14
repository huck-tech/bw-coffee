//
//  RoastingInformationViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/27/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SnapKit

protocol RoastingInfoSource: class {
    var beanName: String? { get }
    var roastProfile: BWRoastProfile? { get }
}

class RoastingInformationViewController: UIViewController {
    @IBOutlet weak var coffeeName: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var startingTemp: UILabel!
    @IBOutlet weak var roastDuration: UILabel!
    
    let MINIMUM_MINUTES = 3 //minumum number of minutes that can be selected
    
    var isEditable: Bool = false
    weak var delegate: RoastProfileEditingDelegate?
    weak var roastInfoSource: RoastingInfoSource?
    
    var source: RoastingInfoSource {
        return roastInfoSource ?? current
    }
    var current: RoastingProcess {        
        return isEditable ? RoastingProcess.editing : RoastingProcess.roasting
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileName.onTap(target: self, selector: #selector(requestProfileName))
        roastDuration.onTap(target: self, selector: #selector(requestRoastDuration))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.load()

        NotificationCenter.default.addObserver(forName: .roastProfileUpdated, object: nil, queue: nil, using: {[weak self] _ in
            self?.load()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roastProfileUpdated, object: nil)
    }


    @objc func requestProfileName() {
        guard isEditable, var roastProfile = current.roastProfile else {return print("\(#function). no profile or not editable")}
        
        let alert = TextFieldAlert.build(title: "Name Roast Profile", current: roastProfile.metadata?.name) {[weak self] name in
            if let name = name {
                self?.current.roastProfile?.metadata?.rename(name: name)
                self?.load()
                self?.delegate?.roastProfileUpdated(roastProfile: roastProfile, reload: true)
            }
        }

        self.present(alert, animated: true)

    }
    
    @objc private func requestRoastDuration() {
        guard isEditable else {return}

        
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: DurationPickerViewController.storyboardID) as? DurationPickerViewController else {
            return print("could not instantiate DurationPickerViewController")
        }
        
        let _ = controller.view
        
        guard let duration = RoastingProcess.editing.roastProfile?.duration, duration >= 180 else {
            return print("this is a specially short roast profile and the UI cannot be used to change its duration.")
        }
        
        controller.timePicker.dataSource = self
        controller.timePicker.delegate = self
        
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true)
    }
    
    
    private func load() {
        
        guard let roastProfile = source.roastProfile else {return}
        
        self.coffeeName.text = source.beanName ?? "<>"
        self.profileName.text = roastProfile.metadata?.name ?? "<>"
        
        //format the roast preheat temperature
        let temp = roastProfile.actualPreheat?.asFahrenheit.asInt.description
        self.startingTemp.text = "\(temp ?? "<>")°"
        
        //format the roast duration
        let now = Date()
        let startRoastTime = Date.init(timeInterval: roastProfile.duration, since: now)
        self.roastDuration.text = startRoastTime.displayMinSec(since: now).description
        
        //change fields according to editability
        [profileName, startingTemp, roastDuration].forEach{$0?.colorText(isEditable: isEditable)}
    }
}

extension RoastingInformationViewController: DurationPickerDelegate {
    var durationPickerTitle: String? {
        return "Choose Roast Time"
    }
    
    var maxDuration: TimeInterval? {
        return 20 * 60 //20 minutes
    }
    
    var minDuration: TimeInterval? {
        return 3 * 60 //3 minutes
    }
    
    var duration: TimeInterval? {
        return current.roastProfile?.duration
    }
    
    func didSelect(duration: TimeInterval) {
        current.roastProfile?.duration = duration
        self.delegate?.roastProfileUpdated(roastProfile: current.roastProfile, reload: false)
        self.load()
    }
}

extension UILabel {
    func colorText(isEditable: Bool) {
        self.textColor = isEditable ? UIColor.brandPurple : .black
    }
}

//this is not a generalized extension but rather one particulat to the time lookups we are doing here.
extension Int {
    var asTimeDigits : String {
        if self < 10 { //assumes no negative numbers
            return "0\(self)"
        } else {
            return self.description
        }
    }
    
    var asDouble: Double{
        return Double(self)
    }
}

extension RoastingInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if component == 0 {
            return (row + MINIMUM_MINUTES).asTimeDigits
        } else if component == 2 {
            return row.asTimeDigits
        } else {
            return ":"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 1 {
            return 20
        } else {
            return 60
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 15 //from 6 to 20 minutes
        } else if component == 2 {
            return 60 //60 seconds
        } else {
            return 1
        }
    }
    
    
}

typealias StringHandler = (String?) -> ()
typealias ResponseHandler = ([String:Any]?) -> ()

class TextFieldAlert: UIAlertController {
    static func build(title:String, message: String? = nil, current:String? = nil, completion: @escaping StringHandler) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = current
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default){_ in
            completion(nil)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            completion(alert.textFields![0].text)
        })
        
        return alert
    }
}

class ConfirmActionAlert: UIAlertController {
    static func build(title:String, message: String? = nil, ok:String = "OK", cancel:String = "Cancel", cancellable: Bool = true, completion: BoolHandler? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        //if we have a completion, we care about the answer so we offer two options
        if cancellable, let _ = completion {
            alert.addAction(UIAlertAction(title: cancel, style: .default){_ in
                completion?(false)
            })
        }
        
        alert.addAction(UIAlertAction(title: ok, style: .default) { action in
            completion?(true)
        })
        
        return alert
    }
}

class DurationPickerViewController: UIViewController {
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var timeBox: UIView!
    
    let DEFAULT_MINUTES = 12

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
//        self.load(duration: self.delegate?.duration ?? TimeInterval(self.DEFAULT_MINUTES * 60 + 30))
        
        //round the corners
        self.timeBox.layer.cornerRadius = 8.0
        self.timeBox.clipsToBounds = true
    }

    var delegate: DurationPickerDelegate?
    
    private var minDuration: TimeInterval {
        return self.delegate?.minDuration ?? 0.00
    }

    func load(duration: TimeInterval) {
        self.timePicker.selectRow(Int(duration/60) - Int(minDuration/60), inComponent: 0, animated: false)
        self.timePicker.selectRow(Int(duration.truncatingRemainder(dividingBy: 60)),
                                  inComponent: 2, animated: false)
    }
    
    @IBAction func select(sender: Any) {
        let minutes = timePicker.selectedRow(inComponent: 0) + Int(minDuration/60)
        let seconds = timePicker.selectedRow(inComponent: 2)

        self.delegate?.didSelect(duration: TimeInterval(minutes * 60 + seconds))
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(_sender: Any) {
        self.dismiss(animated: true)
    }
}

protocol DurationPickerDelegate {
    var maxDuration: TimeInterval? {get}
    var minDuration: TimeInterval? {get}
    var durationPickerTitle: String? {get}
    var duration: TimeInterval? {get}
    func didSelect(duration: TimeInterval)
}

