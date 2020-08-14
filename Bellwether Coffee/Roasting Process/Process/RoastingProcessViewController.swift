//
//  RoastingProcessViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import SwiftState
import Parse
import SwiftyJSON
import Cloudinary
import Alamofire

class RoastingProcessViewController: UIViewController {
    
    //navigator for the roasting screens
    weak var navigator: UINavigationController!
    
    @IBOutlet weak var roasterStatus: UILabel!
    
    //storyboardID we are currently presenting
    var currentID: String?
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        //capture the embedded navigation controller
        if let navigator = childController as? UINavigationController {
            self.navigator = navigator
            self.navigator.isNavigationBarHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        roasterStatus.textDropShadow()
        Roaster.shared.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: .roasterStateUpdated, object: nil, queue: nil, using: {[weak self] _ in
            self?.reloadRoasterState()
        })
        
        self.presentNextStep() //identify the current viewController to be showing.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .roasterStateUpdated, object: nil)
    }

    private func reloadRoasterState(){
        self.roasterStatus.text = Roaster.shared.device?.roasterID ?? "(No Roaster)"
        self.roasterStatus.textColor = Roaster.shared.isConnected ? .white : .brandJolt
    
        if !Roaster.shared.isConnected {
            print("redrum")
        }
    }
    
    static func showRoasterUpdating() {
        AppDelegate.visibleViewController?.confirm(title: "Roaster Updating", message: "The roaster is updating its software. Please try again later.", cancellable: false, completion: {_ in
        })
    }
    
    static func showRoasterBusy() {
        AppDelegate.visibleViewController?.confirm(title: "Roaster Busy", message: "Currently working on \(Roasting.roasting.description).", ok: "Show Me", cancel: "OK", cancellable: true, completion: {confirmed in
            if confirmed {
                AppDelegate.navController?.showRoast();
            }
        })
    }
    
    static func showRoasterNotReady() {
        AppDelegate.visibleViewController?.confirm(title: "Roaster Busy", message: "Roaster is roasting or cooling.", ok: "Show Me", cancel: "OK", cancellable: true, completion: {confirmed in
            if confirmed {
                AppDelegate.navController?.showRoast();
            }
        })
    }
    
    
    //set the green item and roast profile we are working with
    func set(greenItem: GreenItem, profile: RoastProfile) {
        RoastingProcess.roasting.greenItem = greenItem
        RoastingProcess.roasting.roastProfile = profile.asBWRoastProfile?.evenIntervals(count: 80)
    }
    
    var currentStepViewController: RoastingStepController? {
        guard let controller = self.navigator.viewControllers.last as? RoastingStepController else {return nil}
        
        //only respond positively if the view is loaded and presented
        return controller.isOnScreen ? controller : nil
    }
    

    private func presentNextStep() {
        //first, ensure that we have a bean. If we do not, get out of here
        //altogether and take the user to the market
        if RoastingProcess.roasting.greenItem?._id == nil {
            AppDelegate.navController?.showInventory(.green)
            return
        }
        if let storyboardID = nextStepId() {
            //are we already presenting the correct screen? If so, no need for action
            if self.currentID == storyboardID {return print("abort presentNextStep(\(currentID ?? "<>")")}
            guard let controller = storyboard?.instantiateViewController(withIdentifier: storyboardID) as? RoastingStepController else {return print("could not create \(storyboardID)")}
            
            print("switch screen from \(self.currentID ?? "") to \(controller.storyboardID)" )
            controller.roastingStepDelegate = self
            self.currentID = controller.storyboardID
            self.navigator.setViewControllers([controller], animated: false)

        }
    }

    private func nextStepId() -> String? {

        if RoastingProcess.roasting.state == .finished {
            //in this case, we must present the cooling screen
            return RoastingDoneViewController.storyboardID
        }
    
        //first step is to connect to a roaster
        guard Roaster.shared.isConnected else {
            return RoasterSelectionViewController.storyboardID
        }
        
        guard let _ = RoastingProcess.roasting.targetWeight else {
            return RoastTargetWeightViewController.storyboardID
        }
        
        guard let _ = RoastingProcess.roasting.inputWeight else {
            return RoastInputWeightViewController.storyboardID
        }
        
        //we need to get our marching orders from HopperHoming
        if RoastingProcess.roasting.state == .none {
            return RoastHopperHomingViewController.storyboardID
        }
        
        //once the preconditions are met, it is about responding to roaster events...very passively
        
        switch Roaster.shared.state {
        case .reset, .initialize, .offline, .shutdown, .error:
//            oops the roast went into neverland, and we need to abort the roast
            return RoastWaitingViewController.storyboardID

        case .ready, .preheat:
            //start the preheat...all pre-conditions in place or we are already doing it.
            if RoastingProcess.roasting.state == .requested {
                RoastingProcess.roasting.start()
            }
            return RoastPreheatViewController.storyboardID

        case .cool:
            //if we are cooling, show the world.
            return RoastCoolingViewController.storyboardID
        case .roast:
            //if we are roasting, show the world.
            return RoastRoastingViewControlller.storyboardID
        }
    }
}

protocol RoastingStepDelegate {
    func goBack()
    func stepDidComplete(/*_ error: NSError?*/)
}

extension RoastingProcessViewController: RoastingStepDelegate {
    func goBack() {
            guard let green = RoastingProcess.roasting.greenItem else {return}
            AppDelegate.navController?.showInventory(.green)
            AppDelegate.navController?.inventory.green.showGreenItemDetail(greenItem: green)
    }
    func stepDidComplete() {
        guard AppDelegate.visibleViewController == self else {return  print("\(#function) but cannot presentNextStep(1)")}
        self.presentNextStep() //if a step completed, see what we should be showing
    }
}

extension UIViewController {
    
    class func bw_instantiateFromStoryboard() -> Self {
        return bw_instantiateFromStoryboardHelper()
    }
    
    fileprivate class func bw_instantiateFromStoryboardHelper<T>() -> T {
        let controller = UIStoryboard(name: "\(self)", bundle: nil).instantiateInitialViewController()
        return controller! as! T
    }
}

extension Notification.Name {
    static let roastProfileUpdated = Notification.Name("roastProfileUpdated")
}

extension GreenItem {
    static func empty() -> GreenItem {
        return GreenItem.init(_id: nil, bean:"", name:"", quantity: nil)
    }
}


extension RoastingProcessViewController: RoasterDelegate {
    func roaster(available: Bool) {}
    func hopperChanged(inserted: Bool) {
        self.currentStepViewController?.hopperChanged(inserted: inserted)
    }
    
    func roasterUpdated(status: BWRoasterDeviceRoastStatus?){
        self.currentStepViewController?.roasterUpdated(status: status)
    }
    
    private func profileUploadedCorrectly(_ vectors: [(Int,Int)]) -> Bool {
        guard let steps = RoastingProcess.roasting.roastProfile?.evenIntervals().normalizedRoastProfile().steps else {return false}
        
        //exit early if we do not even have the same count. We also thus protect ourselves while stepping through both arrays simulateneously
        if steps.count != vectors.count {
            print("guard fail at \(#function) vectors: \(vectors.count)")
            return false
        }
        
        return !steps.enumerated().map{(arg) -> Bool in
            let (index, step) = arg
            let vector = vectors[index]
            
            //we compare using the mapToJSON to replicate the transformation before sending the values
            let original = BWRoastProfileStep.mapToJSON(step)
            print("compare [\(original[BWRoastProfileStep.JSONKeys.Time] as! Int):\(vector.0)] and [\(original[BWRoastProfileStep.JSONKeys.Temperature] as! Int):\(vector.1)]")
            return original[BWRoastProfileStep.JSONKeys.Time] as? Int == vector.0 && original[BWRoastProfileStep.JSONKeys.Temperature] as? Int == vector.1
        }.contains(false) //if there are any falses, everything becomes true and inverted to return false
    }
    
    func roastDidStart() {
//        Roaster.shared.getProfile {[weak self] vectors in
            if RoastingProcess.roasting.state != .started {
                print("autonomous roast?")
            }
            
            RoastingProcess.roasting.roastStartTime = Date()
            self.currentStepViewController?.roastDidStart()
            
//            self?.profileUploadedCorrectly(vectors ?? [])
        
//        }
    }
    
    func roast(didAppend newMeasurement: BWRoastLogMeasurement) {
        self.currentStepViewController?.roast(didAppend: newMeasurement)
   }
    func roast(didChange summary: BWRoastLogSummaryBlank) {
        self.currentStepViewController?.roast(didChange: summary)
    }
    
    func slackRoastImage(imageUrl: String){
        let endpoint = "https://hooks.slack.com/services/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"
        let params: Parameters = ["attachments":[imageUrl]]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON() {
            response in
            switch response.result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func roastDidChangeState(from oldState: BWRoasterDeviceRoastState,
                             to newState: BWRoasterDeviceRoastState) {
        guard AppDelegate.visibleViewController == self else {return  print("\(#function) but cannot presentNextStep(2)")}
        
        
        //ensure that the old -> new roaster state transition was legal
        switch oldState {
        case .roast, .preheat:
            switch newState {
                case .ready, .offline, .initialize, .shutdown, .error:
                    //the machine just got recycled
                    RoastingProcess.abort()
                    
                    return self.confirm(title: "Roaster restarted so must cancel the roast.", cancellable:false, completion:{[weak self] _ in
                        self?.presentNextStep()
                    })
            case .cool:
                //create a roast event with a photo of the roast
                if let image = self.view.asImage {
                    self.uploadImage(image: image) {urlString in
                        RoastEvent.log(state: .cool, imageUrl: urlString)
                        
                        if let urlString = urlString {
                            self.slackRoastImage(imageUrl: urlString)
                        }
                    }
                }
                break
                default:
                break
                
            }
        default: break
        }
        
        self.presentNextStep() //respond to a state change
    }
    
    private func uploadImage(image: UIImage, completion: @escaping StringHandler) {
        
        guard let cloudinary = AppDelegate.shared?.cloudinary,
            let imageData = UIImagePNGRepresentation(image) else {return completion(nil)}
        cloudinary.createUploader().signedUpload(data: imageData) {result, _ in
            return completion(result?.url)
        }
    }
    
    func roasterIsReadyToRoast() {
        //there is a case where the roaster wants to start, but there is no roast requested.
        guard Roaster.shared.hopperInserted else {
            
            //we only attempt to present next steps if the RoastingProcessView is on-screen
            guard AppDelegate.visibleViewController == self else
                {return  print("\(#function) but cannot presentNextStep(3)")}
            
            //hopper is no longer inserted! present appropriately
            
            return presentNextStep()
        }
        guard RoastingProcess.roasting.state == .started else {
            return print("\(#function) can't roast if rState == \(RoastingProcess.roasting.state)")
        }

        guard let _ = RoastingProcess.roasting.roastStartTime else {
            return print("\(#function) we have not finished uploading the roast profile!")
        }
        
        //we are now roasting; we are optimistic and set that as our state so it
        //does not get called again
        RoastingProcess.roasting.state = .roasting
        
        RoastingProcess.roasting.roast() {[weak self] error in
            if let error = error {
                self?.showNetworkError(message: error.description)
            }
        }
    }
    func roastDidFinish() {
        //we can only move to finished from roasting. If the roast was aborted, leave it alone
//        if RoastingProcess.roasting.state == .roasting {
//            RoastingProcess.roasting.state = .finished
//        } else {
//            print("RoastingProcess.state == \(RoastingProcess.roasting.state) so cannot finish.")
//        }
        if  RoastingProcess.roasting.state != .none {
            RoastingProcess.roasting.state = .finished
        }

        //update the screen with the 'add to roasting inventory' and store the roast in the database
    }
    
    func roastDidFail(with error: NSError) {
        return
        //we present the user with the error and the option to skip, skip all or abort.
//       self.confirm(title: "Roasting Error", message: error.description, ok: "Skip", cancel:"Stop Roast") {confirmed in
//            if confirmed {
//                //do nothing...we keep cruising
//            } else {
//                RoastingProcess.abort(){[weak self] error in
//                    guard AppDelegate.visibleViewController == self else
//                    {return  print("\(#function) but cannot presentNextStep(4)")}
//                    //we may have no network to call us back with the state change, so we must explicity present
//                    self?.presentNextStep()
//                }
//            }
//        }
    }
    
    func roastCooling() {
        //record when the cooling started so we can offer user feedback
        RoastingProcess.roasting.coolStartTime = Date()
        
        
        //store the measurements
        if let measurements = Roaster.shared.httpsServicesFactory.roastController?.currentRoastLogMeasurements {
            RoastingProcess.roasting.measurements = measurements
        }
        
        //log them
        _ = RoastingProcess.roasting.log()
    }
}

extension UIView {
    func drawWhiteSeparators() {
        if self.bounds.height <= 1.0 {
            self.backgroundColor = .white
        }
        subviews.forEach{$0.drawWhiteSeparators()}
    }
    
    var asImage: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        self.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {return nil}
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView {
    func roundCorners() {
        self.layer.cornerRadius = self.bounds.height / 2.0
    }
}

extension UIViewController {
    
    var isOnScreen: Bool {
        return self.viewIfLoaded?.window != nil
    }
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowColor = UIColor.brandRoast.cgColor
    }
}

class RoasterDriverViewController: UIViewController {
    @IBOutlet weak var cycles: UITextField!
    
    
    @IBAction func cancel(_ sender: Any){
        RoasterDriver.shared.cycles = 0
        Roaster.shared.hardReset()
    }
}

class RoasterDriver: RoasterDelegate {
    
    static let shared = RoasterDriver()
    
    enum State {
        case none
        case started
        case done
    }
    
    var cycles = 0
    var measurements = [BWRoastLogMeasurement]()
    var process = State.none
    
    func reset(){
        self.cycles = 0
    }
    
    func start(cycles: Int){
        guard let roastController = Roaster.shared.httpsServicesFactory.roastController else {return}
        guard cycles > 0 else {return print("finished cycles")}
        
        Roaster.shared.delegate = self
        
        //clear state
        self.cycles = cycles
        self.process = State.none
        self.measurements = [BWRoastLogMeasurement]()

        //start the roast
        roastController.startRoast(for: "", with: 6.0, using: Mujeres.roastProfile)
        
    }
    
    func roaster(available: Bool) {}
    
    func roasterUpdated(status: BWRoasterDeviceRoastStatus?) {
        print(#function)
    }
    
    func roastCooling() {
        print(#function)
    }
    
    func hopperChanged(inserted: Bool) {}
    
    func roastDidStart() {
        print(#function)
        self.process = State.started
    }
    
    func roast(didAppend newMeasurement: BWRoastLogMeasurement) {
        measurements.append(newMeasurement)
    }
    
    func roast(didChange summary: BWRoastLogSummaryBlank) {
        print(#function)
    }
    
    func roastDidChangeState(from oldState: BWRoasterDeviceRoastState, to newState: BWRoasterDeviceRoastState) {
        print("\(#function): old:\(oldState.stringValue) new: \(newState.stringValue)")
        
        //do we detect we are coming back into ready state from cycling at the end of colling
        if (oldState == .initialize || oldState == .offline || oldState == .shutdown)
            && newState == .ready {
            //decremente the number of pending roasts and restart if we are above zero
           self.start(cycles: self.cycles - 1)
        }
    }
    
    func roasterIsReadyToRoast() {
        guard process  == State.started else
        {return print("\(#function) but roastStarted == \(process.hashValue)")}
        Roaster.shared.roast {error in
            print("\(#function). error:\(error.debugDescription)")
        }
    }
    
    func roastDidFinish() {
        self.process = State.done
    }
    
    func roastDidFail(with error: NSError) {
        return print("\(#function). \(error.debugDescription)")
    }
}
