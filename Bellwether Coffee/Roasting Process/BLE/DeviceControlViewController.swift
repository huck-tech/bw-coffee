//
//  DeviceControlViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension DeviceControlViewController: RoasterBLEDeviceDatabaseDelegate {
    func devicesDidChange() {
        self.load()
    }
    
    
}

struct PID {
    let p: Int?
    let i: Int?
    let d: Int?
    var t: Int? //temperature
    
    static let module = "HTR"
    
    enum Types: Int {
        case Air = 3
        case Cat = 2
        case Mixer = 0
        case Roast = 1
        case Band = 4
        
        var writeCommand: String {return "SPID"}
        var readCommand: String {return "GPID"}
        
        var getTempCommand: String {return self == .Air || self == .Mixer ? "GHMT" : "GTMP"}
        var setTempCommand: String {return self == .Air || self == .Mixer ? "SHMT" : "STMP"}

        static let all: [Types] = [.Air, .Cat, .Mixer, .Roast, .Band]
        var stringValue: String {
            switch (self) {
            case .Air: return "Air Heater"
            case .Cat: return "Cat"
            case .Mixer: return "Blower"
            case .Roast: return "Roast"
            case .Band: return "Band"
            }
        }
    }
    
    mutating func update(t: Int?) {self.t = t}
}

class PIDCollectionViewController: NSObject {}
extension PIDCollectionViewController: UICollectionViewDelegate {}
extension PIDCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PID.Types.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PIDCollectionViewCell.reuseIdentifier, for: indexPath) as! PIDCollectionViewCell
        cell.load(index: indexPath.row)
        
        return cell
    }
}

extension PIDCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width/7
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

class PIDCollectionViewCell: UICollectionViewCell {
    static var pids = Array<[Int]?>(repeating: [-1,-1,-1,-1], count: PID.Types.all.count)
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var p: UITextField!
    @IBOutlet weak var i: UITextField!
    @IBOutlet weak var d: UITextField!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var t: UITextField!
    
    var index: Int?

    override func prepareForReuse() {
        [p,i,d,t].forEach{$0.text=""}
    }
    
    func load(index: Int) {
        self.index = index
        self.name.text = PID.Types.all[index].stringValue
        self.temp.text = "\(pidTemps[index]) Temp"
        [p,i,d,t].enumerated().forEach{
            let value = PIDCollectionViewCell.pids[PID.Types.all[index].rawValue]?[$0.offset]
            
            if value == -1 {
                $0.element?.text = "-"
            } else {
                $0.element?.text = PIDCollectionViewCell.pids[PID.Types.all[index].rawValue]?[$0.offset].description
            }
        }
    }
    
    @IBAction func set(_ sender:Any){
        guard let index = index else {return print("\(#function) has index == nil")}
        let pid = PID.init(p: p.text?.asInt, i: i.text?.asInt, d: d.text?.asInt, t: -1) //-1 is not used
        DeviceControlViewController.shared?.set(pidType:PID.Types.all[index], pid: pid)
    }
}

extension PIDCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == t, let index = index,
            let celsius = t.text?.asInt?.asDouble.asCelsius.asInt {
            DeviceControlViewController.shared?.set(celsius: celsius, for: PID.Types.all[index])
        }
        return true
    }
}

class PWMCollectionViewController: NSObject {}
extension PWMCollectionViewController: UICollectionViewDelegate {}
extension PWMCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pwmcontrols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PWMCollectionViewCell.reuseIdentifier, for: indexPath) as! PWMCollectionViewCell
        cell.load(index: indexPath.row)
        
        return cell
    }
}

extension PWMCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width/6
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

class PWMCollectionViewCell: UICollectionViewCell {
    static var pwm = Array<Int?>(repeating: nil, count: pwmcontrols.count)
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UITextField!
    var index: Int?
    

    override func prepareForReuse() {
        self.value.text = ""
    }
    
    @objc private func requestValue(){
        let alert = TextFieldAlert.build(title: "Set \(name.text ?? "PWM")", current: "") {[weak self] value in
            guard let val =  value?.asInt, let index = self?.index else {return print("guard.fail \(#function)")}
            DeviceControlViewController.shared?.setPWM(index: index, value: val) {_ in}
            self?.value.text = value
        }
        
        AppDelegate.visibleViewController?.present(alert, animated: true)
    }
    
    func load(index: Int) {
        self.index = index
        self.name.text = pwmcontrols[index]
        self.value.text = PWMCollectionViewCell.pwm[index]?.description
    }
}

extension PWMCollectionViewCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {[weak self] in
            self?.requestValue()
        }
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let val =  self.value.text?.asInt, let index = index else {
            print("guard.fail \(#function)")
            return true
        }
        
        DeviceControlViewController.shared?.setPWM(index: index, value: val) {_ in}
        return true
    }
}


class ToggleCollectionViewController: NSObject {}
extension ToggleCollectionViewController: UICollectionViewDelegate {}
extension ToggleCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toggleNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! ToggleCollectionViewCell
        cell.load(index: toggleOrder[indexPath.row])
        
        return cell
    }
}

extension ToggleCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = indexPath.row == 1 || indexPath.row == 2 ? 0 : UIScreen.main.bounds.size.width/9.8
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

extension DeviceControlViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == vfdHertz {
            self.vfd(hertz: vfdHertz.text?.asInt)
        } else if textField == powerPercent {
            self.power(value: powerPercent.text?.asInt ?? 0)
        } else if textField == preheatTemp {
            self.preheat(value: preheatTemp.text?.asInt ?? 0)
        }
        
        return true
    }
}

class DeviceControlViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var thermoCollectionView: UICollectionView!
    @IBOutlet weak var toggleCollectionView: UICollectionView!
    @IBOutlet weak var pwmCollectionView: UICollectionView!
    @IBOutlet weak var pidCollectionView: UICollectionView!
    @IBOutlet weak var kioskSwitch: UISwitch!
    @IBOutlet weak var debugPanel: UILabel!
    @IBOutlet weak var currentFirmware: UILabel!
    @IBOutlet weak var serialNumberLbl: UILabel!
    @IBOutlet weak var hider: UIView!
    @IBOutlet weak var inputWeight: UILabel!

    @IBOutlet weak var hopperSwitch: UISwitch!
    
    var pidValues = [PID.Types:PID]() {
        didSet {pidCollectionView.reloadData()}
    }
    
    static var shared:DeviceControlViewController?
    
    var lastSelectedIndex: IndexPath?
    
    let toggleCollectionViewController = ToggleCollectionViewController()
    let pwmCollectionViewController = PWMCollectionViewController()
    let pidCollectionViewController = PIDCollectionViewController()

    static var numbTaps = 0
    static var lastTap = Date()
    static var shouldAppear: Bool {
        
        //tap 10 times in less than 10 seconds
        if lastTap.timeIntervalSinceNow < (-10) {numbTaps = 0}
        
        self.lastTap = Date()
        
        numbTaps += 1
        
        return numbTaps > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hider.isHidden = false
        
        DeviceControlViewController.shared = self
        
        tableView.tableFooterView = UIView(frame: .zero) //remove empty cells
        
        self.toggleCollectionView.dataSource = toggleCollectionViewController
        self.toggleCollectionView.delegate = toggleCollectionViewController

        self.pwmCollectionView.dataSource = pwmCollectionViewController
        self.pwmCollectionView.delegate = pwmCollectionViewController
        
        self.pidCollectionView.dataSource = pidCollectionViewController
        self.pidCollectionView.delegate = pidCollectionViewController

        
        diverterAutoBtn.enable(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.acceptInvalidSSLCerts()
        self.updateEachSecond()
        RoasterBLEDeviceDatabase.shared.delegate  = self
        
        
        //starts to perform this query
        self.updateRoasterInformation()
        
        NotificationCenter.default.addObserver(forName: .hopperChanged, object: nil, queue: nil, using: {[weak self] _ in
            self?.hopperSwitch.isOn = Roaster.shared.hopperInserted
            self?.hopperSwitch.alpha = 1.0
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func readInputWeight() {
        Roaster.shared.getInputWeight {[weak self] _, weight, _ in
            self?.inputWeight.text = weight?.formattedLbs(fractionDigits: 2) ?? "-"
        }
    }
    
    func load() {
        getTemperatures()
        readInputWeight()
        //only enable diverter control if the roaster is ready
        [diverterAutoBtn, diverterManualBtn].forEach {$0?.enable(Roaster.shared.state == .ready)}
        
        self.tableView.reloadData()
        self.thermoCollectionView.reloadData() //thermocouples
        self.debugPanel.text = Roaster.shared.debug
    }
    
    fileprivate func set(celsius: Int, for pidType: PID.Types){
        let command = "\(pidType.setTempCommand) \(celsius)"
        print("------------------------------------\(pidType.rawValue)")
        getSensor(module: PID.module, command: command, index: pidType.rawValue) {dict in
            print("\(#function).\(dict)")
        }
    }
    
    private func getTemp(pidType: PID.Types, completion: @escaping (Int?) -> Void){
        getSensor(module: PID.module, command: pidType.getTempCommand, index: pidType.rawValue) {[weak self] dict in
            guard let value = dict?["value"] as? [String: Any],
                let t = value["p0"] as? String
                else {
                    return completion(nil)
            }
            completion(t.asInt)
        }
    }

    fileprivate func set(pidType: PID.Types, pid:PID){
        guard let p = pid.p, let i = pid.i, let d = pid.d else {return print("guard fail in \(#function)")}
        let command = "\(pidType.writeCommand) \(p) \(d) \(i)"
        getSensor(module: PID.module, command: command, index: pidType.rawValue) {dict in
            print("\(#function).\(dict)")
        }
    }
    
    private func get(pidType: PID.Types, completion: @escaping (PID?) -> Void){
        getSensor(module: PID.module, command: pidType.readCommand, index: pidType.rawValue) {[weak self] dict in
            guard let value = dict?["value"] as? [String: Any],
                let p = value["p0"] as? String,
            let i = value["p2"] as? String,
            let d = value["p1"] as? String
                else {
                    return completion(nil)
            }
            
            let pidValue = PID.init(p: p.asInt, i: i.asInt, d: d.asInt, t:-1)
            completion(pidValue)
        }
    }
    
    private func getPIDs(){
        PID.Types.all.forEach {pidType in
            get(pidType: pidType, completion: {[weak self] pidValue in
                guard let pid = pidValue else {return print("pid \(pidType.rawValue) == nil")}
                
                self?.getTemp(pidType: pidType, completion: {temp in
                    let fTemp = temp?.asDouble.asFahrenheit.asInt
                    var pidValue = pidValue
                    PIDCollectionViewCell.pids[pidType.rawValue] = [pid.p ?? -1, pid.i ?? -1, pid.d ?? -1, fTemp ?? -1]
                    pidValue?.update(t: fTemp)
                    self?.pidValues[pidType] = pidValue
                })
        })}
    }
    
    private func getTemperatures() {
        (0..<8).forEach{getTemperature(index: $0)}
    }
    
    
//    private func getCurrentFirmware() {
//        guard let address = device?.localAddress else {return}
//        Alamofire.request("https://\(address)/roaster/version", method:.post, parameters:[:], encoding: URLEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {[weak self] response in
//            switch response.result {
//            case .success(_):
//                if let valuesDictionary = response.value as? [String: Any],
//                    let version = valuesDictionary["value"] as? String {
//                    Roaster.shared.firmwareVersion = version
//                }
//            case .failure(let error):
//                print("could not get roaster firmware version because :\(error.localizedDescription)")
//            }
//        }
//    }
    
    
    @objc private func updateRoasterInformation() {
        guard isOnScreen else {return}
        
        Roaster.shared.refreshFirmwareVersion(){[weak self] in
            self?.currentFirmware.text = "Current: \(Roaster.shared.firmwareVersion?.description ?? "")"
        }
                
        Roaster.shared.httpsServicesFactory.roastController?.serialNumber {[weak self] number in
            Roaster.shared.serialNumber = number
            self?.serialNumberLbl.text = "Serial: \(number ?? "<unknown>")"
        }
        
       //repeat the query every minute
        self.perform(#selector(self.updateRoasterInformation), with: nil, afterDelay: 5)
    }
    
    fileprivate func getDigitalInputs(completion: @escaping ([Bool]?) -> ()){
        self.getSensor(module: "OPTO",
                       command: "ALL",
                       index: 0){result in
                        guard let value = result?["value"] as? [String: Any],
                            let values = value["p0"] as? String else {
                                return completion(nil)
                        }
                        
                        //map each of the values to booleans
                        completion(values.map {$0 == "1"})
                        
        }
    }
    
    @IBOutlet weak var preheatTemp: UITextField!

    
    @IBOutlet weak var vfdHertz: UITextField!
    @IBAction func startVFD(_ sender: Any) {self.vfd(start: true)}
    @IBAction func stopVFD(_ sender: Any) {self.vfd(start: false)}
    
    @IBOutlet weak var powerPercent: UITextField!
    
    private func getPower(){
        self.getSensor(module: "HTR", command: "GHMP", index: 2) {[weak self] dict in
            
            let value = dict?["value"] as? [String: Any]
            self?.powerPercent.text = value?["p0"] as? String
            print(dict)
        }
    }
    
    @IBOutlet weak var diverterAutoBtn: UIButton!
    @IBOutlet weak var diverterManualBtn: UIButton!
    
    @IBAction func setDiverter(_ sender: UIButton){
        
        // 0 = manual diverter
        // 1 = auto diverter
        // 2 = manual roaster control (but send an auto first)
        let mode = sender == diverterManualBtn ? 0 : 1

        let command = "SSS \(mode)"
        self.getSensor(module: "BCP", command:command, index: 0) {dict in print("\(#function).\(dict)")}
    }
    
    private func preheat(value: Int){
        var value = value
        if value < 0 {value = 0}
        if value > 250 {value = 250}
        
        let celsius = value.asDouble.asCelsius.asInt
        self.preheatTemp.text = celsius.asDouble.asFahrenheit.description //set the UI back
        let command = "STMP \(celsius)"
        self.getSensor(module: "BCP", command:command, index: 0) {dict in print("\(#function).\(dict)")}
    }
    
    private func power(value: Int){
        var value = value
        if value < 0 {value = 0}
        if value > 100 {value = 100}
        
        let command = "SHMP \(value)"
        self.powerPercent.text = value.description //set the ui back to the adjusted value
        self.getSensor(module: "HTR", command:command, index: 2) {dict in print("\(#function).\(dict)")}
    }

    fileprivate func vfd(start: Bool? = nil, hertz:Int? = nil){
        let command: String
        
        if let start = start {
            command = start ? "ON" : "OFF"
        } else {
            
            //bound the hertz
            var hz = hertz ?? 0
            if hz < 0 {hz = 0}
            if hz > 100 {hz = 100}
        
            //
            hz = 10 * hz
            //write back to the UI what we understood
            vfdHertz.text = hz.description
            
            command = "PWM \(hz)"
        }
        
        self.getSensor(module: "VFD", command: command, index: 0) {_ in}
    
    }
    
    fileprivate func setPWM(index: Int, value:Int, completion: @escaping ResponseHandler) {
        guard let unit = PWMUnit.init(rawValue: index) else {return print("guard.fail \(index)")}
        guard value >= 0, value <= 1000 else {return print("pwm out of range")}

        
        
        self.getSensor(module: "VOUT",
                       command: "PWM \(value)",
                       index: index){result in
                        print("\(#function).\(result)")
                        completion(result)
        }
    }

    fileprivate func setToggle(index: Int, value:Bool, override:Bool = false, completion: ResponseHandler? = nil) {
        guard let unit = ToggleUnit.init(rawValue: index) else {return print("guard.fail \(index)")}
        switch unit {
        case .beanDropClose, .beanDropOpen:
            if value && !override {
                //make sure to turn off the opposing force *first*
                self.setToggle(index: index == ToggleUnit.beanDropClose.rawValue ? ToggleUnit.beanDropOpen.rawValue : ToggleUnit.beanDropClose.rawValue,
                               value: false) {[weak self] dict in
                                self?.setToggle(index: index, value: value, override:true, completion: completion)
                }
            }
            
        case .drumAgitator:
            //we must set the speed to zero before
            if (!override) {
                setPWM(index: PWMUnit.drumAgitator.rawValue, value: 0) {[weak self] dict in
                    self?.setToggle(index: index, value: value, override: true, completion: completion)
                }
            }
        default:
            break
        }

        
        self.getSensor(module: ToggleCommand.writeModule.rawValue,
                       command: value ? ToggleCommand.on.rawValue : ToggleCommand.off.rawValue,
                       index: index){dict in
            print("\(#function).\(dict)")
                        completion?(dict)
        }
    }
    
    
//    private func getOPTO(index: Int) {
//        self.getSensor(module: ToggleCommand.readModule.rawValue, command:"VAL", index: index){result in
//            guard let values = result?["value"] as? [String: Any],
//                let value = values["p0"] as? String else {
//                    return ToggleCollectionViewCell.toggles[index] = nil
//
//            }
//            ToggleCollectionViewCell.toggles[index] = value == "1";
//        }
//    }
    
    private func getTemperature(index: Int) {
        self.getSensor(module: "TMP", command:"VAL", index: index){result in
            guard let values = result?["value"] as? [String: Any],
                let temperature = values["p1"] as? String else {
                    return ThermocoupleViewCell.temperatures[index] = nil
                    
            }
            guard let temp = Double(temperature) else {
                ThermocoupleViewCell.temperatures[index] = -2
                return
            }
            ThermocoupleViewCell.temperatures[index] = (temp * BWRoasterDeviceBCPHTTPsService.TEMP_FACTOR).asFahrenheit.asInt// ?? -2
        }
    }
    private func getSensor(module:String, command:String, index: Int, completion:@escaping ResponseHandler) {

        guard let device = device else {return}
        if let address = device.localAddress {
            RoasterCommander.shared.process(address: address, module: module,
                                     command: command, index: index, completion: completion)
        }
    }
    
    private func set(state: BWRoasterDeviceRoastState) {
        Roaster.shared.httpsServicesFactory.roastController?.set(state: state)
    }
    
    @IBAction func selectState(_ sender: Any) {
        let sheet = UIAlertController(title: "Select Roaster State", message: nil, preferredStyle: .actionSheet)
        var states = BWRoasterDeviceRoastState.all
        states.removeLast() //remove 'error' as a state
        states.forEach {state in
            sheet.addAction(UIAlertAction(title: state.stringValue, style: .default, handler:
                {[weak self] _ in self?.set(state: state) }))
        }
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
        }
        self.present(sheet, animated:true)
    }
    
    @IBAction func dc_resetRoast(_ sender: Any) {
        self.confirm(title: "Are you sure?", message: "'Reset Roast' clears the app's memory of what's going on.", ok: "Reset") {confirmed in
            if confirmed {
                RoastingProcess.reset()
            }
        }
    }
    
    @IBAction func dc_hardReset(_ sender: Any) {
        self.confirm(title: "HARD Reset. Are you sure?", message: "'Hard Reset' essentially reboots the actual roasting machine.", ok: "Reset") {confirmed in
            if confirmed {
                Roaster.shared.hardReset()
            }
        }
    }
    
    @IBAction func dc_test(_ sender: Any) {
        let controller = RoasterTestingViewController.bw_instantiateFromStoryboard()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func dc_workout(_ sender: Any) {
        let blueVelvet = BlueVelvetViewController.bw_instantiateFromStoryboard()
        self.navigationController?.pushViewController(blueVelvet, animated: true)
        /*
        let alert = TextFieldAlert.build(title: "How many cycles", current: "") {[weak self] value in
            guard let val =  value?.asInt else {return print("guard.fail \(#function)")}
            RoasterDriver.shared.start(cycles: val)
        }
        
        AppDelegate.visibleViewController?.present(alert, animated: true){
            //show the user interface
        }
        */
    }
    
    @IBAction func dc_shutdown(_ sender: Any) {
        Roaster.shared.shutdown()
        RoastLogCommentsViewController.showComments(for: nil)
    }
    
    @IBAction func dc_showKiosk(_ sender: UISwitch) {
        RoasterCommander.shared.serialNumber {serial in
            print("\(#function).\(serial)")
            
        }
        self.hider.isHidden = sender.isOn
    }

    @objc internal func updateEachSecond() {
        
        //go ahead only if the virew is being presentes
        guard isOnScreen else {return}
        
        self.load()
        
        self.perform(#selector(updateEachSecond), with: nil, afterDelay: 1)
    }
}

let pidTemps = ["Max ", "", "Max ", "", "Conduction"]
let toggleOptions: [ToggleUnit:(String,String)] = [.beanLoad:("Open", "Close"), .beanDropOpen:("Open", "Off"),
                                                   .beanDropClose:("Close", "Off"), .beanExit:("Open", "Close"), .drumAgitator:("Rev", "Fwd")]

let pwmcontrols = ["Diverter", "Cooler Blower", "Inlet Blower", "Drum Agitator"]
let thermocouples = ["Blower", "BeanFr", "Exhaust", "HtrOut", " CatOwt", "BeanBtm", "DrumBtm", "DrumTop"]
let toggleNames = ["Cool.Agit", "BLUE", "RED", "B.Load","B.Exit", "D.Agit", "W.Pump", "BD.Open",  "BD.Close"]
let toggleOrder = [0,1,2,3,7,8,4,5,6]

enum PWMUnit: Int {
    case diverter = 0 // heater if during roasts
    case coolerBlower = 1
    case inletBlower = 2
    case drumAgitator = 3
    case unused = 4
}
enum ToggleUnit: Int {
    case cooler = 0
    case blue = 1
    case red = 2
    case beanLoad = 3
    case beanExit = 4
    case drumAgitator = 5
    case waterPump = 6
    case beanDropOpen = 7
    case beanDropClose = 8
}

enum ToggleCommand: String {
    case writeModule = "SWT"
    case on = "ON"
    case off = "OFF"
}

enum BeanExitState: Int {
    case open = 0
    case error = 1
    case closed = 2
}

typealias BeanExitStateHandler = (BeanExitState?) -> ()

class RoasterCommander {
    
    static let shared = RoasterCommander()
    
    var handlers = [String:ResponseHandler]()
    
    var turnBLEOn = false
    
    func serialNumber(completion: @escaping StringHandler){
        guard let address = Roaster.shared.device?.localAddress else {return completion(nil)}
        
        self.process(address: address, module: "MISC", command: "GSN"){dict in
            guard let value = dict?["value"] as? [String:Any] else {return completion(nil)}
            completion(value["p0"] as? String)
        }
    }
    
    func coolTimeRemaining(completion: @escaping DoubleHandler){
        guard let address = Roaster.shared.device?.localAddress else {return completion(nil)}
        
        self.process(address: address, module: "BCP", command: "GCTR"){dict in
            guard let value = dict?["value"] as? [String:Any] else {return completion(nil)}
            guard let time = value["p0"] as? String else {return completion(nil)}

            completion(time.asDouble)
        }
    }
    
    func beanExitState(completion: @escaping BeanExitStateHandler){
        return completion(.closed) //disableBeanExit
        
        guard let address = Roaster.shared.device?.localAddress else {return completion(nil)}
        
        self.process(address: address, module: "BCP", command: "BXS"){dict in
            guard let value = dict?["value"] as? [String:Any] else {return completion(nil)}
            guard let string = value["p0"] as? String else {return completion(nil)}
            guard let state = string.asInt else {return completion(nil)}
            completion(BeanExitState.init(rawValue: state))
        }
    }
    
    func setBeanExit(state: BeanExitState, completion: @escaping BoolHandler){
        guard let address = Roaster.shared.device?.localAddress else {return completion(false)}
        let command: String
        switch state {
        case .open: command = ToggleCommand.on.rawValue
        case .closed: command = ToggleCommand.off.rawValue
        case .error: return completion(false) //we cannot set the error state
        }
        self.process(address: address, module: ToggleCommand.writeModule.rawValue,
                     command: command, index: ToggleUnit.beanExit.rawValue){_ in
            completion(true)
        }
    }
    
    func roastTime(completion: @escaping DoubleHandler){
        guard let address = Roaster.shared.device?.localAddress else {return completion(nil)}
        
        self.process(address: address, module: "BCP", command: "GRT"){dict in
            guard let time = dict?["value"] as? Double
                else {
                    return completion(nil)
            }
            completion(time)
        }
    }
    
    var manualRoast: Bool = false {
        didSet{
            guard let address = Roaster.shared.device?.localAddress else {return}
            let command = "SSS \(manualRoast ? 2 : 1)"
            self.process(address: address, module: "BCP", command: command)
        }
    }
    
    func setManualRoast(temperature: Double) {
        guard let address = Roaster.shared.device?.localAddress, manualRoast else {return}
        
        self.process(address: address, module: "VOUT",
                     command: "PWM \(temperature.asInt)", index: PWMUnit.diverter.rawValue)
    }
    
    private func flushHandlers(){
        if handlers.count > 0 {
            Roaster.shared.device?.bcpService.readCommand {[weak self] dict in
                guard let _self = self, let dict = dict else {return}
                if let uuid = dict["uuid"] as? String {
                    if let handler = _self.handlers[uuid] {
                        _self.handlers.removeValue(forKey: uuid)
                        
                        //execute the handler
                        handler(dict)
                    }
                    
                }
            }
        }
    }
    
    private func ble(module:String, command:String, index: Int = 0 , completion: ResponseHandler? = nil) {
        guard let completion = completion else {return}
        
        let uuid = UUID().uuidString
        
        //store the completion for this command
        self.handlers[uuid] = completion
        
        //issue the command
        Roaster.shared.device?.bcpService.process(module: module, command: command, unit: index, completion: {[weak self] _ in
            //now we need to retrieve a generic result from BLE aand execute the corresponding handler!
            self?.flushHandlers()
        })
        
    }
    
    func process(address:String, module:String, command:String, index: Int = 0 , completion: ResponseHandler? = nil) {
        //use ble instead in this mode
        if turnBLEOn {return ble(module: module, command: command, index: index, completion: completion)}

        let params: Parameters = [
            "m": module,
            "u": index,
            "cmd": command,
            ]
        
        
        Alamofire.request("https://\(address)/roaster/sensor", method:.get, parameters:params, encoding: URLEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {response in
            switch response.result {
            case .success(_):
                completion?(response.value as? [String: Any])
            case .failure(_):
                completion?(nil)
            }
        }
    }
}

extension UIViewController {
    func confirm(title:String, message: String? = nil, ok:String = "OK", cancel:String = "Cancel", cancellable:Bool = true, completion: BoolHandler? = nil) {
        let alert = ConfirmActionAlert.build(title: title, message: message, ok: ok, cancel: cancel, cancellable: cancellable, completion: completion)
        self.present(alert, animated: true)
    }
}

extension DeviceControlViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            if section == 0 {return 1}
            
            return RoasterBLEDeviceDatabase.shared.devices.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier:"Header")!
        }
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: DeviceControlTableViewCell.reuseIdentifier) as! DeviceControlTableViewCell
        return cell.load(device: RoasterBLEDeviceDatabase.shared.devices[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else {return}
        self.lastSelectedIndex = indexPath
        let device = RoasterBLEDeviceDatabase.shared.devices[indexPath.row]
        guard device.isAvailable, let _ = device.roasterID else {return}

        self.getPIDs()
        self.getPower()
    }
    
    fileprivate var device: RoasterBLEDevice? {
        guard let indexPath = self.lastSelectedIndex else {
            return Roaster.shared.device
        }
        
        return RoasterBLEDeviceDatabase.shared.devices[indexPath.row]
    }
}

extension DeviceControlViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thermocouples.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThermocoupleViewCell.reuseIdentifier, for: indexPath) as! ThermocoupleViewCell
        
        cell.load(device: self.device , index: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width/8.75
        return CGSize(width: width, height: collectionView.frame.height)
    }
}

class ThermocoupleViewCell: UICollectionViewCell {
    static var temperatures = Array<Int?>(repeating: nil, count: thermocouples.count)
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func prepareForReuse() {
        self.value.text = ""
    }

    func load(device: RoasterBLEDevice?, index: Int) {
        self.name.text = thermocouples[index]
        self.value.text = ThermocoupleViewCell.temperatures[index]?.description
    }
}

class ToggleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var on: UILabel!
    @IBOutlet weak var off: UILabel!
    
    var index: Int = 0
    
    @objc func unhighlight(){
        self.backgroundColor = .white
    }

    override func awakeFromNib() {
        on.onTap(target: self, selector: #selector(onTapped))
        off.onTap(target: self, selector: #selector(offTapped))
    }
    @objc func onTapped(){
        self.backgroundColor = UIColor.brandPurple
        DeviceControlViewController.shared?.setToggle(index: index, value: true)
        self.perform(#selector(unhighlight), with: nil, afterDelay: 0.5)
    }
    @objc func offTapped(){
        self.backgroundColor = UIColor.brandPurple
        DeviceControlViewController.shared?.setToggle(index: index, value: false)
        self.perform(#selector(unhighlight), with: nil, afterDelay: 0.5)
    }

    func load(index: Int) {
        self.index = index
        [on,off].forEach{
            let enabled = true//[0,3,4,6].index(of: index) != nil
            $0?.isUserInteractionEnabled = enabled
            $0?.alpha = enabled ? 1.0 : 0.0
        }
        self.name.text = toggleNames[index]
        
        guard let unit = ToggleUnit.init(rawValue: index) else {return}
        on.text = toggleOptions[unit]?.0 ?? "On"
        off.text = toggleOptions[unit]?.1 ?? "Off"
        
        //we do not need the off button, maybe?
        if unit == .beanDropOpen || unit == .beanDropClose {
            off.alpha = 0.1
            off.isEnabled = false
        }
        
        if unit == .blue || unit == .red {
            self.contentView.alpha = 0.1
            self.contentView.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func toggle(_ sender: UISwitch){
print("\(#function).\(sender.isOn)")
        
    }
}


class DeviceControlTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ipAddress: UILabel!
    @IBOutlet weak var bluetooth: UILabel!
    @IBOutlet weak var raspberry: UILabel!
    @IBOutlet weak var firmware: UILabel!
    @IBOutlet weak var roasting: UILabel!
    @IBOutlet weak var connectBtn: UIButton!
    
    weak var device: RoasterBLEDevice?
    
    @IBAction func connect(_ sender: Any) {
        guard let device = device else {return}
        
        if device.state == .connected {
            device.disconnect()
        } else {
            if Defaults.shared.defaultRoaster == device.roasterID || Defaults.shared.defaultRoaster == nil{
                //go ahead and select it...this is what we usually do
                self.select(device: device)
            } else {
                AppDelegate.visibleViewController?.confirm(title: "Changing Default Roaster", message: "You are connecting to \(device.roasterID ?? "<New Roaster>") instead of your usual \(Defaults.shared.defaultRoaster ?? "<Default Roaster>"). Are you sure?") {[weak self] confirmed in
                    if confirmed {
                        self?.select(device: device)
                    }
                }
            }
        }
    }
    
    private func select(device: RoasterBLEDevice){
        if (!device.select()){
            AppDelegate.visibleViewController?.confirm(title: "Connection Failure", message: "Could not connect to the roaster. Are you sure you are both on the same WiFi network?", cancellable: false)
        }
    }
    
    
    func load(device:RoasterBLEDevice) -> UITableViewCell {
        self.device = device
        self.name.text = device.roasterID ?? "roasterID"
        self.ipAddress.text = device.localAddress ?? "localAddress"
        self.bluetooth.text = device.state.stringValue
        self.roasting.text = device.state == .connected ? Roasting.roasting.state.stringValue : "-"
        self.connectBtn.setTitle(device.state == .connected ? "Disconnect" : "Connect", for: .normal)
        self.connectBtn.isEnabled = device.seenRecently || device.state == .connected
        self.alpha = device.isAvailable ? 1.0 : 0.5
        self.backgroundColor = device.onNetwork ? .white : .brandJolt
        
        let isDefault = device.roasterID == Defaults.shared.defaultRoaster
        
        self.connectBtn.setTitleColor(device.seenRecently ? (isDefault ? UIColor.brandPurple : .black) : .brandDisabled, for: .normal)
        
        

        if let address = device.localAddress {
            Alamofire.request("https://\(address)/roaster/state", method:.get, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers)
                .responseJSON() {[weak self] response in
                self?.raspberry.text = response.response?.statusCode.description
                
                switch response.result {
                case .success(let data):
                    let state = JSON(data)["value"].int
                    self?.firmware.text = state == nil ? "-" : BWRoasterDeviceRoastState(rawValue: state!)?.stringValue
                case .failure(let _):
                    self?.firmware.text = "failed"
                }
            }
        }
        
        return self
    }
}

extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
print("\(#function).\(error)")
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}

extension UIView {
    
    func enable(_ enabled: Bool){
        self.isUserInteractionEnabled = enabled
        self.alpha = enabled ? 1.0 : 0.5
    }
}
