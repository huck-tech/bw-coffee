//
//  WeightScaleViewController.swift
//  HeavyBean
//
//  Created by Marcos Polanco on 5/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import mailgun

typealias DoubleDoubleHandler = (Double?,Double?) -> Void

enum Fields: String {
    case address = "address"
    case port = "port"
    case offset = "offset"
    case factor = "factor"
    case first = "first"
    case second = "second"
    
    static var all: [Fields] = [.address, .port, .offset, .factor, .first, .second]
}

class Defaults {
    static func set(_ field:Fields, value:String?) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: field.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: field.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func get(_ field:Fields) -> String? {
        return UserDefaults.standard.value(forKey: field.rawValue) as? String
    }
}

extension WeightScaleViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var index = fields.index(of: textField) else {return}
        
        //save the each value entered as the default in the future
        Defaults.set(Fields.all[index], value: textField.text)
        
        //move on to the next field
        index += 1
        if index >= fields.count {index = 0}
        fields[index].becomeFirstResponder()
    }
}

class WeightScaleViewController: UIViewController {
    
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var offset: UITextField!
    @IBOutlet weak var factor: UITextField!
    @IBOutlet weak var short: UITextField!
    @IBOutlet weak var long: UITextField!
    @IBOutlet weak var voltage: UITextField!
    @IBOutlet weak var output: UILabel!
    
    @IBOutlet weak var shortWeight: UILabel!
    @IBOutlet weak var longWeight: UILabel!

    
    var fields = [UITextField]()
    var readings = [(String,String)]()
    
    var longInputWeightAvg: Double = 0.0
    var shortInputWeightAvg: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fields = [address, port, offset, factor, short, long]
        
        acceptInvalidSSLCerts()
    }
    
    func export() {
        
        //create an email
        let email = "marcos@bellwethercoffee.com"
        let subject = "weight scale data - during preheat (max vibration)"
        let message = MGMessage.init(from: email, to: "mjpolanco@gmail.com", subject: subject, body: "-")//leewolochuk@gmail.com
        
        let body = readings.map {"\($0.0)\t\($0.1)\n"}.reduce("",+)
        message?.addAttachment(body.data(using: .utf8), withName: "vratio.tsv", type: "text")
        
        //send out the mail
        AppDelegate.shared?.mailgun?.send(message, success: {[weak self] success in
            print("Sent!")
            
            }, failure: {[weak self] error in
                print(error ?? "<error>")
        })
    }
    
    private func loadDefaults() {
        let placeholders = ["192.168.86.173", "8443", "-6.268", "-194070", "10", "100"]
        //load default values back from the database if they have been entered in the past
        Fields.all.enumerated().forEach{index, field in
            guard var value = Defaults.get(Fields.all[index]) else {return print("1.\(index)")}
            if value.isEmpty {value = placeholders[index]}
            fields[index].text  = value
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadDefaults()
        self.readInputWeight()
    }
    
    @IBAction func tare(_ sender: Any) {
        guard let weight = self.output.text?.asDouble,
        let b = self.offset.text?.asDouble else {return print("sorry")}

        self.offset.text = (b - weight).description
    }


    @objc func readInputWeight() {
        self.getInputWeight {[weak self] vratio, weight in
            guard let _self = self else {return}
            if let weight = weight, let vratio = vratio {
                _self.voltage.text = vratio.description
                _self.readings.append((Date().timeIntervalSince1970.description, vratio.description))
                
                if _self.readings.count == 400 {_self.export()}
                
                _self.output.text = weight.description
                _self.shortWeight.text = _self.shortInputWeightAvg.description
                _self.longWeight.text = _self.longInputWeightAvg.description
            }
            _self.perform(#selector(_self.readInputWeight), with: nil, afterDelay: 0.1)
        }
    }
    
    private func autotare(current: Double){
        let short_div = (self.short.text?.asDouble ?? 10.0)
        let long_div = (self.long.text?.asDouble ?? 10.0)
        
        self.shortInputWeightAvg += (current - self.shortInputWeightAvg) / short_div
        self.longInputWeightAvg += (current - self.longInputWeightAvg) / long_div
        
        //are we near zero
        guard abs(current) < 0.1 else {return /*print("far from zero")*/}
        guard abs(shortInputWeightAvg - longInputWeightAvg) < 0.1 else {return /*print("unstable")*/}
        guard let vratio = self.voltage.text?.asDouble, let m = self.factor.text?.asDouble else {return print("nil m or b")}
        
        print("----------------tare: \(current.description)")
        
        //we reverse the equation given the shortInputWeightAvg
        self.offset.text = (0.0 - (m * vratio)).description
    }
    
    
    func getInputWeight(_ completion: @escaping DoubleDoubleHandler) {
        guard let host = self.address.text, let port = self.port.text, let b = self.offset.text?.asDouble, let m = self.factor.text?.asDouble else {return completion(nil, nil)}

        let path = "https://\(host):\(port)/roaster/input_weight"
        Alamofire.request(path, method:.get, parameters:nil, encoding: JSONEncoding.default, headers:nil).responseJSON() {
            response in
            switch response.result {
            case .success(let data):
                let vratio = JSON(data)["value"].doubleValue
                let weight = m * vratio + b
                
                DispatchQueue.main.async {[weak self] in self?.autotare(current: weight)}
                completion(vratio, weight)
            case .failure(_):
                completion(nil, nil)
            }
        }

    }
}

extension String {
    var asDouble: Double? {
        return Double(self)
    }
}

extension UIViewController {
    func acceptInvalidSSLCerts() {
        SessionManager.default.delegate.sessionDidReceiveChallenge = {session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    if let storage = SessionManager.default.session.configuration.urlCredentialStorage {
                        credential = storage.defaultCredential(for: challenge.protectionSpace)
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
    }
}
