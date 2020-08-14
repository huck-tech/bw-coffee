//
//  AuthFlowViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Parse

class AuthFlowViewController: UIViewController {
    //navigator for the roasting screens
    weak var navigator: UINavigationController!
    
    var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.0
    
        //take over the status bar as well
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = UIColor.brandBackground
        self.view.addSubview(barView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 1.0
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {return UIStatusBarStyle.default}
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        //capture the embedded navigation controller
        if let navigator = childController as? UINavigationController {
            self.navigator = navigator
            self.navigator.isNavigationBarHidden = true
        }
    }

    private func pinAuthView(with delegate: PinAuthViewControllerDelegate){
        let authViewController = PinAuthViewController.bw_instantiateFromStoryboard()
        let _ = authViewController.view
        authViewController.delegate = delegate
        self.navigator?.setViewControllers([authViewController], animated: false)
    }
    
    func create(){
        self.pinAuthView(with: PinCreateFlow(controller: self))
    }
    
    func willConfirm(digits: [Int?]){
        self.pinAuthView(with: PinConfirmFlow(controller: self, pin: String.pin(from: digits)))
    }
    
    private func persist(pin: String, completion: @escaping BoolHandler){
        guard let query = PinAuth.query()?.whereKey("authpin", equalTo: pin) else {return completion(false)}
    
        query.findObjectsInBackground {results, error in
            guard let pins = results as? [PinAuth] else {return completion(false)}
            guard pins.count == 0 else {return completion(false)}
            
            guard let pinAuth = PinAuth.init(authpin: pin, token: Defaults.shared.authToken, user: Defaults.shared.userInfo) else {return completion(false)}
            pinAuth.saveInBackground {success, _ in
                completion(success)
            }
        }
    }
    
    func didConfirm(pin: String){
        
        //the pin was confirmed, so we now must check whether it is unique and network it optimistically
        self.persist(pin: pin){[weak self] success in
            guard success else {
                self?.confirm(title: "PIN Not Created", message: "The PIN could not be created, probably because it is not unique. Please try again.", cancellable: false, completion: {_ in
                    self?.create()
                })
                return
            }
            
            Defaults.shared.set(pin: pin)
            
            //go back to the autentication, but don't ask to create a pin again...we just created it
            self?.didAuthenticate(createPin: false)
        }
    }
    
    func showPasswordAuth(){
        //we use the username/password method instead
        let loginController = LoginViewController()
        loginController.delegate = self
        self.navigator?.setViewControllers([loginController], animated: false)
    }
    
    func authenticate(){
        if Defaults.shared.usePin {
            self.showPinAuth()
        } else {
            self.showPasswordAuth()
        }
    }
    
    func showPinAuth(){
        self.pinAuthView(with: PinAuthenticateFlow(controller: self))
    }
    
    func willAuthenticate(pin: String) -> Bool {
        //record that we have last tried to authenticate with the pin
        Defaults.shared.set(usePin: true)
        
        //ensure that this iPad has been locked to a cafe via email/pword auth *first*
        guard let cafe = Defaults.shared.cafe else {
            self.confirm(title: "Authentication Error", message: "You must authenticate at least once with email and password before using a pin.", cancellable: false, completion: {[weak self] _ in
                self?.authenticate()
            })
            return false
        }
        
        //attempt to authenticate with this pin
        PinAuth.query()?.whereKey("authpin", equalTo: pin).getFirstObjectInBackground {[weak self] result,error in
            guard let pinAuth = result as? PinAuth else {
                self?.confirm(title: "Authentication Error", message: "Please try again.", cancellable: false, completion: {_ in
                    self?.authenticate()
                })
                return print("authentication failed")
            }
            guard let token = pinAuth.token, let data = pinAuth.userInfo?.data(using: String.Encoding.utf8),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                let user = dict else {return print("decoding failed")}
            
            //the cafe references in the pin
            let pinCafe = (dict?["cafes"] as? [String])?.first
            
            //we must confirm that the cafe retrieved in the dictionary is the same as the lockdown cafe
            guard pinCafe == cafe else {
                self?.confirm(title: "Authentication Error", message: "Please try again.", cancellable: false, completion: {[weak self] _ in
                    self?.authenticate()
                })
                return print("cafe mismatch: pin's == \(pinCafe ?? "n/a") app:\(cafe)")
            }
            
            //save the user info
            BellwetherAPI.auth.update(token: token, user: user)
            
            //set the default pin on this ipad
            Defaults.shared.set(pin: pin)
            
            self?.didAuthenticate(createPin: false)
        }

        return true
    }
    
    func didAuthenticate(createPin: Bool){
        //make sure the user has a pin if we want it created
        PinAuth.given(email: BellwetherAPI.auth.currentProfileInfo?.subtitle) {pinAuth, error in
            
            //if no error and we don't have a pin, create one
            if error == nil && pinAuth == nil {return self.create()}
            
            //capture the delegate
            let delegate = self.delegate
            self.dismiss(animated: true) {
                delegate?.loginDidAuthenticateSuccessfully()
            }
        }
    }
    
    
    func clear(){}
    
    @IBAction func selectStagingHost(sender: Any) {
        let alert = TextFieldAlert.build(title: "Set Host IP", current: "") {[weak self] value in
            guard let value =  value  else {return print("guard.fail \(#function)")}
            
            Defaults.shared.set(stagingHost: value)
        }
        
        self.present(alert, animated: true)
    }
}

class PinCreateFlow: PinAuthViewControllerDelegate {
    let controller: AuthFlowViewController
    
    init(controller: AuthFlowViewController){
        self.controller = controller
    }
    
    var instructions: NSAttributedString {
        return "Please create your PIN. You’ll use this 4 digit number to log in from now on.".attributedString
    }
    
    var failure: String? {
        //there is no possible failure message, but you might wish not to allow super-obvious sequences in the future
        return nil
    }
    
    func finished(digits: [Int?])  -> Bool {
        controller.willConfirm(digits: digits)
        return true
    }
    
    func didFail(){
        //this is not called, because we always accept the digits since they are *always* four digits before 'finished' is called
    }
}
extension AuthFlowViewController: AuthFlowViewControllerDelegate {
    func loginDidAuthenticateSuccessfully() {
        //only password login uses this route, so create the pin if needed
        self.didAuthenticate(createPin: true)
    }
}


class PinConfirmFlow: PinAuthViewControllerDelegate {
    
    let controller: AuthFlowViewController
    let pin: String
    
    init(controller: AuthFlowViewController, pin:String){
        self.controller = controller
        self.pin = pin
    }
    
    var instructions: NSAttributedString {
        return "Enter your PIN one more time…".attributedString
    }
    
    var failure: String? {
        return "Sorry, the PINs did not match. Try again."
    }
    
    func finished(digits: [Int?]) -> Bool {
        
        //is the pin entered the same as the one we got earlier?
        let confirmation = String.pin(from: digits)
        guard self.pin == confirmation else {return false}
        
        controller.didConfirm(pin: self.pin)
        return true
    }
    
    func didFail(){
        //if we do not confirm, then go back to the create screen
        controller.create()
    }
}

class PinAuthenticateFlow: PinAuthViewControllerDelegate {
    
    let controller: AuthFlowViewController
    
    init(controller: AuthFlowViewController){
        self.controller = controller
    }
    
    var instructions: NSAttributedString {
        let text = "Login".withTextColor(.brandPurple)
        text.append(" with email and password instead.".attributedString)
        return text
    }
    
    var failure: String? {return "Sorry, that is an incorrect pin sequence; try again."}
    
    func finished(digits: [Int?]) -> Bool {
        let pin = String.pin(from: digits)
        guard controller.willAuthenticate(pin: pin) else {return false}
        return true
    }
    
    func didFail(){
        //if the authentication fails, just try again
        controller.authenticate()
    }
    
    func takeAction() {
        //in this context, the action is to show the login screen instead
        controller.showPasswordAuth()
    }
}

extension String {
    
    //generate a string from the array of digits in the pin
    static func pin(from digits: [Int?]) -> String {
        return digits .compactMap{$0} .map{$0.description} .reduce("",+)
    }
}

class AppInstall: PFObject {

    @NSManaged var cafeId:      String?
    @NSManaged var pushId:      String?
    @NSManaged var deviceId:    String?
    
    enum Fields: String {
        case cafeId = "cafeId"
        case pushId = "pushId"
        case deviceId = "deviceId"
        
        static var all: [Fields] = [.cafeId, .pushId, .deviceId]
    }
    
    static func save(completion: BoolHandler? = nil){
        
        //retrieve the existing record
        self.retrieve {install in
            
            //if we do not have one, create one and save it
            (install ?? AppInstall.create()).saveInBackground {success, error in
                completion?(success)
            }
        }
    }
    static func retrieve(completion: @escaping (AppInstall?)->Void) {
        
        //fetch the existing information for this device
        guard let deviceId = UIDevice.current.identifierForVendor?.description else {return completion(nil)}
        guard let query = AppInstall.query()?.whereKey(Fields.deviceId.rawValue, equalTo: deviceId) else {return completion(nil)}
        
        query.findObjectsInBackground {results, error in
            completion(results?.first as? AppInstall)
        }
    }
    
    override init() {
        super.init()
    }
    
    static func create() -> AppInstall {
        let instance = AppInstall()
        instance.cafeId = BellwetherAPI.auth.cafe
        instance.pushId = BellwetherAPI.auth.pushId
        instance.deviceId = UIDevice.current.identifierForVendor?.description
        
        return instance
    }
}

extension AppInstall: PFSubclassing {static func parseClassName() -> String {return "AppInstall"}}

class PinAuth: PFObject {
    @NSManaged var authpin: String?
    @NSManaged var token: String?
    @NSManaged var userInfo: String?
    @NSManaged var email: String?

    override init() {
        super.init()
    }
    
    init?(authpin: String?, token: String?, user: [String: Any]?){
        guard let authpin = authpin, let token = token, let user = user else {return nil}
        guard let userData = try? JSONSerialization.data(withJSONObject: user as Any, options: []) else {return nil}
        super.init()
        self.authpin  = authpin
        self.token = token
        self.userInfo = String.init(data: userData, encoding: String.Encoding.utf8)
        self.email = user["email"] as? String
    }
    
    static func given(email: String?, completion: @escaping (PinAuth?, Error?) -> Void) {
        guard let email = email,
            let _ = PinAuth.query()?.whereKey("email", equalTo: email).findObjectsInBackground(block: {results, error in
            completion(results?.first as? PinAuth, error)
        }) else {return completion(nil, NSError())}
    }
}

extension PinAuth: PFSubclassing {
    static func parseClassName() -> String {
        return AppDelegate.isProduction ? "PinProd" : "PinAuth"
    }
}


