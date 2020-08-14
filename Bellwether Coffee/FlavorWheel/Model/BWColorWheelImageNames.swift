//
//  BWColorWheelImageNames.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/8/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit


struct BWColorWheelImageNames {
    struct JSONKeys {
        static let BackgroundImage  = "BackgroundImage"
        static let Circle1          = "Circle1"
        static let Circle2          = "Circle2"
        static let Circle3          = "Circle3"
    }
    
    // workaround for compiler bug
    typealias BWColorWheelCircle1 = BWColorWheel.Circle1
    typealias BWColorWheelCircle2 = BWColorWheel.Circle2
    typealias BWColorWheelCircle3 = BWColorWheel.Circle3
    
    let backgroundImageFileName: String
    var circle1ValueToFileName = [BWColorWheelCircle1 : String]()
    var circle2ValueToFileName = [BWColorWheelCircle2 : String]()
    var circle3ValueToFileName = [BWColorWheelCircle3 : String]()
    
    init?(json: [String : Any]) {
        guard let bgFileName = json[JSONKeys.BackgroundImage] as? String,
            let dict1 = json[JSONKeys.Circle1] as? [String : String],
            let dict2 = json[JSONKeys.Circle2] as? [String : String],
            let dict3 = json[JSONKeys.Circle3] as? [String : String] else {
                return nil
        }
        
        backgroundImageFileName = bgFileName
        
        for value in bw_iterateEnum(BWColorWheel.Circle1.self) {
            guard let fileName = dict1[value.rawValue] else {
                return nil
            }
            circle1ValueToFileName[value] = fileName
        }
        
        for value in bw_iterateEnum(BWColorWheel.Circle2.self) {
            guard let fileName = dict2[value.rawValue] else {
                return nil
            }
            circle2ValueToFileName[value] = fileName
        }
        
        for value in bw_iterateEnum(BWColorWheel.Circle3.self) {
            guard let fileName = dict3[value.rawValue] else {
                return nil
            }
            circle3ValueToFileName[value] = fileName
        }
    }
}
