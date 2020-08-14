//
//  BWRoasterDeviceRoastService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 19.10.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


struct BWRoasterDeviceRoastStatus {
    var state: BWRoasterDeviceRoastState
    var temperature: BWTemperature
    var drumpBottomTemp: BWTemperature
    var humidity: BWHumidity?
    var timestamp: Date
    var isReadyToRoast: Bool?
    var weightInputScale: Double?
    var weightOutputScale: Double?
    
    init(state: BWRoasterDeviceRoastState,
         temperature: BWTemperature,
         drumpBottomTemp: BWTemperature,
         timestamp: Date,
         humidity: BWHumidity? = nil,
         isReadyToRoast: Bool? = nil,
         weightInputScale: Double? = nil,
         weightOutputScale: Double? = nil){
        self.state = state
        self.temperature = temperature
        self.drumpBottomTemp = drumpBottomTemp
        self.timestamp = timestamp
        self.humidity = humidity
        self.isReadyToRoast = isReadyToRoast
        self.weightInputScale = weightInputScale
        self.weightOutputScale = weightOutputScale
    }
}


typealias BWRoasterDeviceRoastServiceCompletion = (NSError?) -> Void
typealias BWRoasterDeviceRoastStatusCompletion = (BWRoasterDeviceRoastStatus?, NSError?) -> Void
typealias BWRoasterDeviceMaxStepsCompletion = (Int?, NSError?) -> Void


protocol BWRoasterDeviceRoastService {
    func serialNumber(completion: @escaping StringHandler)
    func set(state: BWRoasterDeviceRoastState)
    func coolTimeRemaining(completion: @escaping DoubleHandler)
    func preheatRoaster(to temperature: BWTemperature, completion: @escaping BWRoasterDeviceRoastServiceCompletion)
    func upload(roastProfile: BWRoastProfile, beanWeight weight: BWWeight,
                completion: @escaping BWRoasterDeviceRoastServiceCompletion)
    func forceDropBeans(completion: @escaping BWRoasterDeviceRoastServiceCompletion)
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion)
    func getHopperState(_ completion: @escaping BooleanErrorHandler)
    func getRoastStatus(_ completion: @escaping BWRoasterDeviceRoastStatusCompletion)
    func cancelCurrentRoast(completion: @escaping BWRoasterDeviceRoastServiceCompletion)
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion)
    func getUpdating(completion: @escaping (Bool?)->())
}
