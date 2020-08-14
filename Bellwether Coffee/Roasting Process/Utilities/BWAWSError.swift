//
//  BWAWSError.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/13/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


let BWAWSErrorDomain = "BWAWSErrorDomain"


enum BWAWSErrorCode: Int {
    case invalidAuthToken
    case invalidServerResponse
    case internalServerError
    case invalidRequest
    case operationFailed

    // Cart
    case cartExpired             = 1000
    case cartActive              = 1001
    case invalidAmount           = 1002
    case cartEmpty               = 1003
    case invalidShipmentRate     = 1004
    case invalidShipmentOrder    = 1005
    case invalidTotalPrice       = 1006

    // Market errors
    case marketBeanNotFound      = 2000

    // Users errors
    case userInvalidData         = 3000
    case userHasNoPermissions    = 3001
    case invalidPasswordFormat   = 3002
    case invalidRepeatPassword   = 3003
    case invalidUserPassword     = 3004
    case invalidLoginFormat      = 3005
    case userUsernameExists      = 3006

    // Payment
    case paymentAccountCreateError    = 4001
    case paymentTransactionNotFound   = 4002
    case paymentMakePaymentError      = 4003

    // Order errors
    case orderNotExists          = 5001
    case orderNotNew             = 5002
    case orderNotCanceled        = 5003
    case orderNotArchived        = 5004
    case orderCantBuyLabels      = 5005

    // EasyPost error
    case invalidShipmentRateIdRrror = 6001
    case cantBuyOrderLabels         = 6002
    case addressValidationError     = 6003

    // Inventory
    case inventoryCreatingError     = 7000
    case inventoryNoBeansOnOrder    = 7001
    case inventoryMoveBeanError     = 7002
    case inventoryNotFoundError     = 7003
    case inventoryInvalidAmountError = 7004
    case inventoryUpdatedError      = 7005


    // Roaster device

    case roastProfileNotFound               = 8000
    case cannotSaveOrUpdate                 = 8001
    case unsupportedRoastProfileType        = 8002
    case cannotFindRoastLog                 = 8003
    case incorrectRoastProfileVector        = 8004
    
    case roasterDeviceNotFound              = 8007
    case roasterdeviceCannotSaveOrUpdate    = 8008
    case roasterdeviceAlreadyCreated        = 8009

    // General errors
    case notImplementedYet                  = 9000
}


extension NSError {
    static func bw_awsErrorWithCode(_ code: BWAWSErrorCode, defaultErrorMessage: String? = nil) -> NSError {
        var userInfo: [String : AnyObject]

        if let defaultErrorMessage = defaultErrorMessage {
            userInfo = [NSLocalizedDescriptionKey: defaultErrorMessage as AnyObject]
        } else {
            let predefinedMessage = String(format: "Error %d. %@", code.rawValue,
                                           NSLocalizedString("ERROR_AWS_UNEXPECTED_RESPONSE", comment: ""))
            userInfo = [NSLocalizedDescriptionKey: predefinedMessage as AnyObject]
        }

        return NSError(domain: BWAWSErrorDomain,
                       code: code.rawValue,
                       userInfo: userInfo)
    }
}
