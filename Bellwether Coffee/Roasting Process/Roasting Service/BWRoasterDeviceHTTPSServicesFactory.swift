//
//  BWRoasterDeviceHTTPSServicesFactory.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


protocol BWRoasterDeviceHTTPSServicesFactoryNetworkConfigurationProvider {
    func serverInfo(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> BWServerInfo
    func networkAuthenticator(for deviceInfo: BWRoasterDeviceInfo) -> BWNetworkAuthDelegate?
    func responseErrorParser(for deviceInfo: BWRoasterDeviceInfo) -> BWResponseErrorParser
    func requestRetrier(for deviceInfo: BWRoasterDeviceInfo) -> BWRoasterHTTPRequestRetrier?
}


class BWRoasterDeviceHTTPSServicesFactory: BWRoasterDeviceServicesFactory {

    // MARK: - DI
    var networkConfigurationProvider: NetworkConfigurationProvider!
    var logger: BWLogger?
    var roastController: BWRoasterDeviceRoastController?
    
    typealias NetworkConfigurationProvider = BWRoasterDeviceHTTPSServicesFactoryNetworkConfigurationProvider
    
    // MARK: - BWRoasterDeviceServicesFactory
    
    func createServices(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> [BWRoasterDeviceService] {
        let networkDataProvider = createNetworkService(for: deviceInfo, port:port)
        let responseErrorParser = networkConfigurationProvider.responseErrorParser(for: deviceInfo)
        
        let bcpService: BWRoasterDeviceBCPService

        let service = BWRoasterDeviceBCPHTTPsService()
        service.networkDataProvider = networkDataProvider
        service.responseErrorParser = responseErrorParser
        bcpService = service
        
        let roastService = createRoastService(bcpService: bcpService)
        self.roastController = createRoastController(deviceInfo: deviceInfo, roastService: roastService)
        let services: [BWRoasterDeviceService] = [
            bcpService,
            roastController!,
        ]
        return services
    }
    
    // MARK: - Utils
    
    private func createRoastService(bcpService: BWRoasterDeviceBCPService) -> BWRoasterDeviceRoastService {
        let service = BWRoasterDeviceRoastHTTPsService()
        service.bcpService = bcpService
        return service
    }
    
    static var roastController = BWRoasterDeviceRoastControllerBase()
    
    private func createRoastController(deviceInfo: BWRoasterDeviceInfo,
                               roastService: BWRoasterDeviceRoastService) -> BWRoasterDeviceRoastController {
        
        BWRoasterDeviceHTTPSServicesFactory.roastController.httpRoastService = roastService
        BWRoasterDeviceHTTPSServicesFactory.roastController.deviceInfo = deviceInfo

        return BWRoasterDeviceHTTPSServicesFactory.roastController
    }
    
    // MARK: - Network
    
    func createNetworkService(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> BWNetworkDataProvider {
        let serverInfo = networkConfigurationProvider.serverInfo(for: deviceInfo, port:port)
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfiguration.timeoutIntervalForResource = 10.0
        
        let networkAuthenticator = networkConfigurationProvider.networkAuthenticator(for: deviceInfo)
        let networkService = BWNetworkService(serverInfo: serverInfo,
                                              authDelegate: networkAuthenticator,
                                              configuration: sessionConfiguration)
        networkService.requestRetrier = networkConfigurationProvider.requestRetrier(for: deviceInfo)
        networkService.logger = logger
        return networkService
    }
    
}
