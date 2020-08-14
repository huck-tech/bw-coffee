//
//  RoastLogViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Parse
import SwiftyJSON
import mailgun
import NotificationBannerSwift

class RoastLogViewController: UIViewController {
    
    @IBOutlet weak var graphBox: UIView!
    
    @IBOutlet weak var firmwareLabel: UILabel!
    @IBOutlet weak var firmwareTitle: UILabel!
    @IBOutlet weak var roastDateLabel: UILabel!

    @IBOutlet weak var exportBtn: UIButton!
    @IBOutlet weak var cloneBtn: UIButton!
    
    weak var graphView: BWRoastProfileGraphViewController!
    weak var infoBox: RoastingInformationViewController?
    var bwRoastProfile: BWRoastProfile?
    var roastLog: RoastLog?
    var infoDelegate: RoastLogInformationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide bw-only info
        [exportBtn, cloneBtn, firmwareLabel, firmwareTitle, roastDateLabel.superview]
            .forEach{($0)?.isHidden = !BellwetherAPI.auth.isBellwetherUser}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadGraph()
    }
    
    private func loadGraph() {
        guard let bwRoastProfile = bwRoastProfile?.evenIntervals(count: 80) else {return print("guard.fail \(#function)")}
        graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: bwRoastProfile,isEditable: false, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
        
        guard let measurements = roastLog?.bwMeasurements() else {return print("no measurements \(#function)")}
        graphView.roastLogDataSource = BWRoastLogGraphDataSource.init(measurements: measurements)
        graphView.roastSkinDataSource = BWRoastSkinGraphDataSource.init(measurements: measurements)
        graphView.roastRiseRateDataSource = BWRoastRiseRateGraphDataSource.init(measurements: measurements)

        self.firmwareLabel.text = roastLog?.firmware
        self.roastDateLabel.text = roastLog?.date?.string()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        //capture the roasting info box
        if let child = childController as? RoastingInformationViewController {
            self.infoBox = child
            self.infoBox?.isEditable = false
            self.infoBox?.roastInfoSource = self
        } else if let child = childController as? BWRoastProfileGraphViewController {
            self.graphView = child
        }
    }
    
    @IBAction func prepare(_ sender: Any) {
        
        guard !Roaster.shared.firmwareUpdating else {
            return RoastingProcessViewController.showRoasterUpdating()
        }
        
        guard RoastingProcess.roasting.state == .none else {
            return RoastingProcessViewController.showRoasterBusy()
        }
        
        guard Roaster.shared.isReadyForNewRoast else {
            return RoastingProcessViewController.showRoasterNotReady()
        }
        
        BellwetherAPI.orders.getGreenItem(bean: self.bwRoastProfile?.asRoastProfile.bean) {[weak self] greenItem in
            guard let profile = self?.bwRoastProfile?.asRoastProfile, let greenItem = greenItem else {return}
            
            AppDelegate.navController?.showRoast(greenItem: greenItem, profile: profile)
        }
    }
    
    @IBAction func schedule(_ sender: Any) {
        BellwetherAPI.orders.getGreenItem(bean: self.bwRoastProfile?.asRoastProfile.bean) {[weak self] greenItem in
            guard let profile = self?.bwRoastProfile?.asRoastProfile, let greenItem = greenItem else {return}
            RoastScheduleController.shared.scheduleRoast(greenItem: greenItem, roastProfile: profile)
        }
    }
    
    @IBAction func clone(_ sender: Any) {
        _clone()
    }
    
    
    @IBAction func export(_ sender: Any) {
        
        //create an email
        guard let email = BellwetherAPI.auth.currentProfileInfo?.subtitle else {return}
        let subject = "\(roastLog?.date?.string() ?? "") Roast Log for \(beanName ?? "") (\(roastProfile?.metadata?.name ?? ""))"
        let message = MGMessage.init(from: ADMIN_EMAIL, to: email, subject: subject, body: "-")
        
        //create temp file for the roast profile actually sent
        let profile = bwRoastProfile?.evenIntervals(count: 80).evenIntervals()
        
        //we need a graph source for the rate of rise
        let riseRateSource = BWRoastRiseRateGraphDataSource.init(measurements: roastLog?.bwMeasurements() ?? [])

        let headers = "Seconds, Profile, Bean Probe, Drum Bottom, Rate of Rise\n"
        let _roast = roastLog?.bwMeasurements()?.map {
            "\($0.time),\(profile?.temp(at: $0.time)?.asFahrenheit ?? 0.0),\($0.temperature),\($0.skinTemp),\(riseRateSource.temp(at: $0.time.rounded().asInt))\n"
            }.reduce("",+)
        if let roast = _roast {
            let body = headers + roast
            message?.addAttachment(body.data(using: .utf8), withName: "roast_profile_air_skin_rise.csv", type: "text")
        }
        
        //send out the mail
        AppDelegate.shared?.mailgun?.send(message, success: {[weak self] success in
            
            let banner = NotificationBanner(title: "Roast Log Sent!", subtitle: "The roast log was emailed to \(email).", style: .success, colors: BWColors())
            banner.dismissOnTap = true
            banner.show()
            
        }, failure: {[weak self] error in
            self?.confirm(title: "Email Error", message: "Sorry, but could not send the log. The error was \(error?.localizedDescription ?? "<unknown>")", cancellable: false)
        })
    }
    
    private func _clone() {
        BellwetherAPI.orders.getGreenItem(bean: self.bwRoastProfile?.asRoastProfile.bean) {[weak self] greenItem in
            guard let profile = self?.bwRoastProfile?.asRoastProfile, let greenItem = greenItem else {return}
            
            let detail = BeanDetailViewController()
            detail.greenItem = greenItem
            
            //make a copy of the profile and set it as the roast profile for editing
            RoastingProcess.editing.roastProfile = profile.asBWRoastProfile
            
            //convert the measurements into steps
            let _steps: [BWRoastProfileStep]? = self?.roastLog?.bwMeasurements()?.map {measurement in
                return BWRoastProfileStep(temperature: measurement.temperature.asCelsius, time: measurement.time)
            }
            
            guard var steps = _steps else {return print("could not generate steps")}
            
            //replace the charge temp with the *skin* temperature from the original profile! muy importante.
            if let _ = steps.first, let firstSourceStep = RoastingProcess.editing.roastProfile?.steps.first {
                steps[0] = BWRoastProfileStep(temperature: firstSourceStep.temp , time: 0.0)
            }
            
            //create a roast profile with the same steps, but down to just 25 points
            var bwRoastProfile = profile.asBWRoastProfile
            bwRoastProfile = bwRoastProfile?.replaceSteps(steps: steps)
            RoastingProcess.editing.roastProfile = bwRoastProfile?.curvedRoastProfile(maxNumberOfSteps: 25)
            
            let editor = RoastProfileEditorViewController.bw_instantiateFromStoryboard()
            editor.editMode = .duplicate
            AppDelegate.navController?.setViewControllers([detail, editor], animated: true)
        }
    }
}

extension RoastLogViewController: RoastingInfoSource {
    var roastProfile: BWRoastProfile? {
        return bwRoastProfile
    }
    

    var beanName: String? {return self.infoDelegate?.bean(for: roastLog?.bean)?._name}
}

class RoastEvent: PFObject {
    @NSManaged var machine:     String?
    @NSManaged var roaster:     String?
    @NSManaged var state:       NSNumber?
    @NSManaged var cafe: String?     //the cafe
    @NSManaged var imageUrl:    String?
    @NSManaged var serialNumber:     String?

    /*  Logs the given state for the current roasting machine
     */
    static func log(state: BWRoasterDeviceRoastState, imageUrl:String? = nil, completion: BoolHandler? = nil){
        let event = RoastEvent()
        event.machine = Roaster.shared.device?.roasterID
        event.serialNumber = Roaster.shared.serialNumber
        event.state = NSNumber.init(value: state.rawValue)
        event.roaster = BellwetherAPI.auth.currentProfileInfo?.title
        event.cafe = BellwetherAPI.auth.cafe
        event.imageUrl = imageUrl
        event.saveInBackground {success, error in
            completion?(success)
        }
    }
}

class RoastLogComment: PFObject {
    
    @NSManaged var roastLog: RoastLog?
    @NSManaged var roaster: String?     //full name
    @NSManaged var roasterId: String?   //email, at this time
    @NSManaged var comment: String?     //the comment
    @NSManaged var cafe: String?     //the cafe
               var sentAt: Date?          //this is a UI-only attribute for dynamically-generated comments (implies we should abstract an interface)
    
//    init(roastLog: RoastLog? = nil, roaster:String? = nil, roasterId:String? = nil, comment:String? = nil){
//        super.init()
//        self.roastLog = roastLog
//        self.roaster = roaster ?? BellwetherAPI.auth.currentProfileInfo?.title
//        self.roasterId = roasterId ?? BellwetherAPI.auth.currentProfileInfo?.subtitle
//        self.comment = comment
//    }
}


extension RoastData: PFSubclassing {static func parseClassName() -> String {return "RoastData"}}
extension RoastEvent: PFSubclassing {static func parseClassName() -> String {return "RoastEvent"}}
extension RoastLog: PFSubclassing {static func parseClassName() -> String {return "RoastLog"}}
extension RoastLogComment: PFSubclassing {static func parseClassName() -> String {return "RoastLogComment"}}

extension Orders {
    //return a particular green item
    func getGreenItem(bean: String?, completion: @escaping (GreenItem?) -> Void) {
        guard let bean = bean else {return completion(nil)}
        self.getGreen {greenItems in
            completion(greenItems?.filter{$0.bean == bean}.first)
        }
    }
}
