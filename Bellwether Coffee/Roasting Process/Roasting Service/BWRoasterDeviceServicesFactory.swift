//
//  BWRoasterDeviceServicesFactory.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


protocol BWRoasterDeviceServicesFactory {
    func createServices(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> [BWRoasterDeviceService]
}

protocol BWRoasterDeviceCompositeServicesFactoryDelegate: class {
    func shouldCreateHTTPsServices(for deviceInfo: BWRoasterDeviceInfo) -> Bool
}

class BWRoasterDeviceCompositeServicesFactory: BWRoasterDeviceServicesFactory {
    
    private func factories(for deviceInfo: BWRoasterDeviceInfo) -> [BWRoasterDeviceServicesFactory] {
        var result = [
            bleFactory,
        ]
        
        if delegate?.shouldCreateHTTPsServices(for: deviceInfo) ?? false {
            result.append(httpsFactory)
        }
        
        return result
    }
    
    weak var delegate: BWRoasterDeviceCompositeServicesFactoryDelegate?
    
    private let bleFactory: BWRoasterDeviceServicesFactory
    private let httpsFactory: BWRoasterDeviceServicesFactory
    
    init(bleFactory: BWRoasterDeviceServicesFactory,
         httpsFactory: BWRoasterDeviceServicesFactory) {
        self.bleFactory = bleFactory
        self.httpsFactory = httpsFactory
    }
    
    // MARK: - BWRoasterDeviceServicesFactory
    
    func createServices(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> [BWRoasterDeviceService] {
        return self.factories(for: deviceInfo).map { $0.createServices(for: deviceInfo, port:port) }.flatMap { $0 }
    }
}
