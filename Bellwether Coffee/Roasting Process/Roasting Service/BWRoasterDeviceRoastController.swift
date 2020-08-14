//
//  BWRoasterDeviceRoastController.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 20.10.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


extension BWRoasterDevice {
    var roastController: BWRoasterDeviceRoastController? {
        return services.flatMap { $0 as? BWRoasterDeviceRoastController }.first
    }
}


protocol BWRoasterDeviceRoastControllerDelegate: class {
    func roastDidStart()
    func roast(didAppend newMeasurement: BWRoastLogMeasurement)
    func roast(didChange summary: BWRoastLogSummaryBlank)
    func roastDidChangeState(from oldState: BWRoasterDeviceRoastState,
                             to newState: BWRoasterDeviceRoastState)
    func roasterIsReadyToRoast()
    func roastDidFinish()
    func roastDidFail(with error: NSError)
}


protocol BWRoasterDeviceRoastController: BWRoasterDeviceService {
    var lastSuccess: Date { get }
    var roastProfile: BWRoastProfile? { get }
    var currentRoastLogMetadata: BWRoastLogMetadata? { get }
    var currentRoastLogSummaryBlank: BWRoastLogSummaryBlank? { get }
    var currentRoastLogMeasurements: [BWRoastLogMeasurement]? { get }
    var currentRoasterStatus: BWRoasterDeviceRoastStatus? { get }

    weak var delegate: RoasterDelegate? { get set }

    //we now monitor the machine continuously, so we must control polling start.stop
    func startPolling()
    func stopPolling()
    func poll()
    
    func set(state: BWRoasterDeviceRoastState)
    func serialNumber(completion: @escaping StringHandler)

    func startRoast(for beanId: String, with weight: BWWeight, using roastProfile: BWRoastProfile)
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion)
    func getHopperState(_ completion: @escaping BooleanErrorHandler)
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion)
    func forceDropBeans(completion: @escaping (NSError?) -> Void)
    func cancelCurrentRoast(completion: @escaping (NSError?) -> Void)
    func preheatRoaster(temperature: BWTemperature?, completion: @escaping BWRoasterDeviceRoastServiceCompletion)
    func coolTimeRemaining(completion: @escaping DoubleHandler)
}



struct BWRoastLogSummaryBlank {
    var startWeight: BWWeight
    var endWeight: BWWeight?
    var chargeTemperature: BWTemperature?
    var minutes5Temperature: BWTemperature?
    var minutes8Temperature: BWTemperature?
    var endTemperature: BWTemperature?
    var dropTime: TimeInterval?
    var firstCrack: TimeInterval?

    init(startWeight: BWWeight) {
        self.startWeight = startWeight
    }

    init(summary: BWRoastLogSummary) {
        self.startWeight = summary.startWeight
        self.endWeight = summary.endWeight
        self.chargeTemperature = summary.chargeTemperature
        self.minutes5Temperature = summary.minutes5Temperature
        self.minutes8Temperature = summary.minutes8Temperature
        self.endTemperature = summary.endTemperature
        self.dropTime = summary.dropTime
        self.firstCrack = summary.firstCrack
    }
}

var useBLE = true

class BWRoasterDeviceRoastControllerBase: NSObject, BWRoasterDeviceRoastController {
    func coolTimeRemaining(completion: @escaping DoubleHandler){
        roastService.coolTimeRemaining(completion: completion)
    }
    
    func set(state: BWRoasterDeviceRoastState) {
        print(#function)
        roastService.set(state: state)
    }
    
    func serialNumber(completion: @escaping StringHandler) {
        roastService.serialNumber(completion: completion)
    }

    
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion) {
        roastService.getFirmwareVersion {version, error in
            completion(version, error)
        }
    }
    
    weak var delegate: RoasterDelegate?
    

    // MARK: - DI
    var httpRoastService: BWRoasterDeviceRoastService!
    var deviceInfo: BWRoasterDeviceInfo!

    var pollingInterval: TimeInterval = 1

    // MARK: - BWRoasterDeviceService

    static var name: String {
        return "Roast"
    }
    
    
    var roastService: BWRoasterDeviceRoastService {
        if useBLE {
            if let device = Roaster.shared.device {
                return device.bcpService
            }
        }

        return self.httpRoastService
    }

    // MARK: - BWRoasterDeviceRoastController

    private(set) var roastProfile: BWRoastProfile?
    private(set) var currentRoastLogMetadata: BWRoastLogMetadata?
    private(set) var currentRoastLogSummaryBlank: BWRoastLogSummaryBlank? {
        didSet {
            if let summary = currentRoastLogSummaryBlank {
                delegate?.roast(didChange: summary)
            }
        }
    }
    private(set) var currentRoastLogMeasurements: [BWRoastLogMeasurement]?
    private(set) var currentRoasterStatus: BWRoasterDeviceRoastStatus?
    
    func preheatRoaster(temperature: BWTemperature?, completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        let temp = temperature ?? Defaults.shared.defaultPreheat
        self.roastService.preheatRoaster(to: temp) {error in
            print("preheatRoaster: \(error.debugDescription)")
            completion(error)
        }
    }
    func startRoast(for beanId: String, with weight: BWWeight, using roastProfile: BWRoastProfile) {
        RoastEvent.log(state: BWRoasterDeviceRoastState.preheat)
        guard let roastProfileMetadata = roastProfile.metadata, let firstStep = roastProfile.steps.first else {
            return
        }
        
        self.roastProfile = roastProfile
        
        let profileName: String = roastProfile.metadata?.name ?? "<profileName>"

        currentRoastLogMetadata = BWRoastLogMetadata(roastProfileID: roastProfileMetadata.id,
                                                     roastProfileType: roastProfileMetadata.style,
                                                     startTime: Date(),
                                                     beanWeight: weight,
                                                     beanID: beanId,
                                                     profileName: profileName,
                                                     roasterDeviceID: deviceInfo.id)
        currentRoastLogSummaryBlank = BWRoastLogSummaryBlank(startWeight: weight)
        currentRoastLogMeasurements = []

        //preheat roaster to the last temperature in the roast profile
        roastService.preheatRoaster(to: firstStep.temperature) { [weak self] error in
            if let error = error {
                self?.delegate?.roastDidFail(with: error)
            } else {
                //critical to send the original roastProfile.duration separate from the mangling by the normalizer
                let normalizedRoastProfile = roastProfile.evenIntervals().normalizedRoastProfile()

                let numberOfSteps = 100
                guard normalizedRoastProfile.steps.count <= numberOfSteps else {
                    let message = String(format: NSLocalizedString("ROAST_PROFILE_TOO_MANY_STEPS_ERROR", comment: ""),
                                         normalizedRoastProfile.steps.count,
                                         numberOfSteps)
                    let error = NSError.bw_roasterError(.tooManyStepsInRoastProfile, message: message)
                    self?.delegate?.roastDidFail(with: error)
                    return
                }

                self?.roastService.upload(roastProfile: normalizedRoastProfile, beanWeight: weight) { [weak self] (error) in
                    if let error = error {
                        self?.delegate?.roastDidFail(with: error)
                    } else {
                        self?.delegate?.roastDidStart()
                    }
                }

            }
        }
    }
    
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion) {
        return roastService.getInputWeight(completion)
    }
    
    func getHopperState(_ completion: @escaping BooleanErrorHandler) {
        return roastService.getHopperState(completion)
    }



    func forceDropBeans(completion: @escaping (NSError?) -> Void) {
        guard currentState == .preheat else {
            let errorMessage = NSLocalizedString("ROAST_FORCE_DROP_ERROR_WRONG_STATE", comment: "")
            completion(NSError.bw_roasterError(.invalidState, message: errorMessage))
            return
        }

        roastService.forceDropBeans {error in
            RoastEvent.log(state: BWRoasterDeviceRoastState.roast)
            completion(error)
        }
    }

    func cancelCurrentRoast(completion: @escaping (NSError?) -> Void) {
        roastService.cancelCurrentRoast {error in
            completion(error)
        }
    }

    // MARK: - State
    private var currentState: BWRoasterDeviceRoastState = .reset

    // MARK: - Polling

    private var timer: Timer? = nil

    func startPolling() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }

        let aTimer = Timer(timeInterval: pollingInterval,
                           target: self,
                           selector: #selector(_poll),
                           userInfo: nil, repeats: true)
        RunLoop.main.add(aTimer, forMode: .defaultRunLoopMode)
        self.timer = aTimer
        self.poll()
    }

    func stopPolling() {
        print(#function)
        timer?.invalidate()
    }

    deinit {
        stopPolling()
    }
    

    
    private var targetTemperature: BWTemperature {
        if let target = self.roastProfile?.actualPreheat {
            return target
        } else {
            return Defaults.shared.defaultPreheat
        }
    }

    // 
    var lastSuccess = Date()
    
    @objc func _poll() {
//        print("poll: timer")
        self.poll()
    }
    
    @objc func poll() {
//        print("\(Date().timeIntervalSinceReferenceDate):\(#function)")
        if lastSuccess.timeIntervalSinceNow > Roaster.DEAD_SECONDS {
            self.delegate?.roaster(available: false)
        }
        
        roastService.getUpdating {isUpdating in
            
            //update the flag; if we cannot reach the roaster, we do not change
            if let isUpdating = isUpdating {
                Roaster.shared.firmwareUpdating = isUpdating
                
                //if we are updating and are in the ready state, we can issue an upgrade command
                if isUpdating && Roaster.shared.state == .ready {
                    Roaster.shared.updateFirmware {success in
                        print("Roaster.shared.updateFirmware: \(success)")
                        
                        //if the next reading is nil, that means we cannot reach it, and nothing happens. If api_app is
                        //dead, it might be that an update is onoing. That means the flag stays false, which is good.
                        
                        //if the next reading is true, the updateFirmware will fire again, but it will fail, which is OK.
                        
                        //if the next reading is false, then the api_app is running (because we have data) and the file
                        //is no longer in place. This is probably OK, but it might also be that the reboot is *about* to
                        //happen, but has not happened yet. In this case, we are getting a false reading...update is
                        //still occurring, but we report NO, and that we are ok. This will cause 
                    }
                }
            }
            //if we are now updating
        }
        
        roastService.getHopperState {isInserted, error in
            if let error = error {
                let pollingError = NSError.bw_roasterError(.pollingError, underlyingError: error)
                self.delegate?.roastDidFail(with: pollingError)
            } else if let isInserted = isInserted {
                
                //P1 does not have hopper detection, so early exit if we see that or don't know the firmware
                if Roaster.shared.firmwareVersion?.contains("GLADYS") ?? true {return}
                Roaster.shared.hopperInserted = isInserted
            }
        }

        roastService.getRoastStatus() { [weak self] (roastStatus: BWRoasterDeviceRoastStatus?, error: NSError?) in
            if let `self` = self, let status = roastStatus {
                self.currentRoasterStatus = status
                
                //record our success
                self.lastSuccess = Date()
                
                //important to track this info immediately
                Roaster.shared.state = status.state
                
                if let isReadyToRoast = status.isReadyToRoast, isReadyToRoast == true, status.state == .preheat {
                    self.delegate?.roasterIsReadyToRoast()
                }

                if self.currentState != status.state {
                    let oldState = self.currentState
                    self.currentState = status.state
                    
                    if oldState == .cool &&
                        (status.state == .ready || status.state == .shutdown || status.state == .offline || status.state == .preheat) {
                        //we need to know early that the state changes coming are while roast is finishing
                        self.roastComplete()
                    }

                    self.delegate?.roastDidChangeState(from: oldState, to: status.state)

                    if oldState == .preheat && status.state == .roast {
                        self.roastStarted(status: status)
                    }
                    if oldState == .roast && status.state == .cool {
                        self.roastCooldown(status: status)
                    }

                }
                
                //let the delegate know the updated status after we process it, so it is contextualized
                self.delegate?.roasterUpdated(status: self.currentRoasterStatus)

                if status.state == .roast {
                    self.addMeasurement(for: status)
                }
                
                //shouldLog is true once every 10 seconds during the roast
                var shouldLog: Bool {return Date().timeIntervalSinceReferenceDate.asInt % 20 == 0 && status.state == .roast}
                
                //log measurements every 10 seconds, in case the roast is killed
                if  shouldLog {
                    DispatchQueue.main.async{
                        RoastingProcess.roasting.log()
                    }
                }
                

                self.updateSummary(with: status)
            } else if let error = error {
                print("\(#function).\(error)")

                let pollingError = NSError.bw_roasterError(.pollingError, underlyingError: error)

                self?.delegate?.roastDidFail(with: pollingError)
            }
        }
    }

    private func timestamp(for status: BWRoasterDeviceRoastStatus) -> TimeInterval? {
        guard let metadata = currentRoastLogMetadata else {
            return nil
        }

        let startTime = metadata.startTime
        return status.timestamp.timeIntervalSince(startTime) * 1
    }
    
    //return the target temperature at the given 

    static var DELTA_ATTENUATION: Double {
        if let _ = Roaster.shared.device as? MockRoasterDevice {
            return 0.02
        } else {
            return 1.0
        }
    }
    static var attenuation = BWRoasterDeviceRoastControllerBase.DELTA_ATTENUATION
    
    private func addMeasurement(for status: BWRoasterDeviceRoastStatus) {
        guard let timestamp = timestamp(for: status) else {return}
        
        guard status.temperature > 0 else {return}
        
        let target = self.roastProfile?.temp(at: timestamp) ?? status.temperature
        let pseudo = target + (status.temperature - target) * BWRoasterDeviceRoastControllerBase.attenuation

        let skinTarget = self.roastProfile?.temp(at: timestamp) ?? status.drumpBottomTemp
        let skinPseudo = skinTarget + (status.drumpBottomTemp - skinTarget) * BWRoasterDeviceRoastControllerBase.attenuation

        Roaster.shared.pseudo = pseudo
        
        let measurement = BWRoastLogMeasurement(time: timestamp,
                                                temperature: pseudo * 9/5 + 32,
                                                skinTemp: skinPseudo * 9/5 + 32,
                                                humidity: status.humidity)
        currentRoastLogMeasurements?.append(measurement)
        
        //protect against out-of-order data by sorting in-place based on timestamps
        currentRoastLogMeasurements?.sort {prev, next in prev.time < next.time}

        delegate?.roast(didAppend: measurement)
    }

    private func updateSummary(with status: BWRoasterDeviceRoastStatus) {
        self.currentRoasterStatus = status
        
        guard let currentRoastLogMeasurements = currentRoastLogMeasurements,
            var summary = currentRoastLogSummaryBlank else {
                return
        }

        if let firstMeasurement = currentRoastLogMeasurements.first,
            summary.chargeTemperature == nil {
            summary.chargeTemperature = firstMeasurement.temperature
        }

        currentRoastLogSummaryBlank = summary
    }

    private func roastPreheatComplete(status: BWRoasterDeviceRoastStatus) {
    }

    private func roastStarted(status: BWRoasterDeviceRoastStatus) {
        currentRoastLogMetadata?.startTime = status.timestamp
    }

    private func roastCooldown(status: BWRoasterDeviceRoastStatus) {
        guard var summary = currentRoastLogSummaryBlank else {
            return
        }

        summary.dropTime = timestamp(for: status)
        summary.endTemperature = status.temperature * 9/5 + 32

        currentRoastLogSummaryBlank = summary
        
        delegate?.roastCooling()
    }

    private func roastComplete() {
        delegate?.roastDidFinish()
    }
}
