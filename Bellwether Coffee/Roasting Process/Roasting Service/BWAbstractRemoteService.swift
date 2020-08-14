//
//  BWAbstractRemoteService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 27.04.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class BWAbstractRemoteService: BWLoggerContainer {
    
    // MARK: - DI
    var networkDataProvider: BWNetworkDataProvider!
    var responseErrorParser: BWResponseErrorParser!
    
    var logger: BWLogger?
    
    // MARK: - Shared Utility
    
    internal enum ParameterEncoding {
        case json
        case url
    }
    
    internal typealias RequestInfo = (name: String,
        method: Alamofire.HTTPMethod,
        path: String,
        parameters: [String: Any]?,
        parametersEncoding: ParameterEncoding?,
        headers: [String: String]?)

    internal typealias UploadInfo = (name: String,
        method: Alamofire.HTTPMethod,
        path: String,
        data: Data?,
        url: URL?,
        fileName: String)

    internal func getItems<ResultType>(_ requestName: String, requestPath: String,
                           jsonParsingClosure: @escaping (_ json: AnyObject) throws -> ResultType?,
                           completion: @escaping (_ result: ResultType?, _ error: NSError?) -> Void) {
        
        let requestInfo = RequestInfo(name: requestName,
                                      method: .get,
                                      path: requestPath,
                                      parameters: nil,
                                      parametersEncoding: nil,
                                      headers: nil)
        
        requestItems(requestInfo, jsonParsingClosure: jsonParsingClosure, completion: completion)
    }
    
    func uploadData<ResultType>(info: UploadInfo, jsonParsingClosure: @escaping (_ json: AnyObject) throws -> ResultType?,
                                progress: ((Float) -> Void)?,
                                completion: @escaping (_ result: ResultType?, _ error: NSError?) -> Void) {
    
        let networkDataProviderCompletion = { (JSON: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> Void in
            
            var resultItem: ResultType?
            var resultError: NSError?
            
            if let error = self.responseErrorParser.parse(json: JSON, error: error, response: response) {
                resultError = error
            } else if let JSON = JSON, let parsedItem = try? jsonParsingClosure(JSON) {
                resultItem = parsedItem
            } else {
                resultError = NSError.bw_awsErrorWithCode(.invalidServerResponse)
            }
            
            if let resultError = resultError {
                self.logger?.error("\(info.name) failure: \(resultError)")
            } else {
                self.logger?.debug("\(info.name) success")
                self.logger?.verbose(resultItem as Any)
            }
            
            completion(resultItem, resultError)
        }
    
        if let data = info.data {
            networkDataProvider.upload(method: info.method, data: data, relativePath: info.path, fileName: info.fileName,
                        progressHandler: progress, responseHandler: networkDataProviderCompletion)
        } else if let url = info.url {
            networkDataProvider.upload(method: info.method, url: url, relativePath: info.path, fileName: info.fileName,
                        progressHandler: progress, responseHandler: networkDataProviderCompletion)
        } else {
            assertionFailure()
        }
    }
    
    internal func requestItems<ResultType>(_ requestInfo: RequestInfo,
                               jsonParsingClosure: @escaping (_ json: AnyObject) throws -> ResultType?,
                               completion: @escaping (_ result: ResultType?, _ error: NSError?) -> Void) {
        
        let encoding: Alamofire.ParameterEncoding
        
        if let parametersEncoding = requestInfo.parametersEncoding {
            switch parametersEncoding {
            case .json:
                encoding = Alamofire.JSONEncoding.default
            case .url:
                encoding = Alamofire.URLEncoding.default
            }
        } else {
            encoding = Alamofire.URLEncoding.methodDependent
        }
        
        let networkDataProviderCompletion = { (JSON: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> Void in
            
            var resultItem: ResultType?
            var resultError: NSError?
            
            if let error = self.responseErrorParser.parse(json: JSON, error: error, response: response) {
                resultError = error
            } else if let JSON = JSON, let parsedItem = try? jsonParsingClosure(JSON) {
                resultItem = parsedItem
            } else {
                resultError = NSError.bw_awsErrorWithCode(.invalidServerResponse)
            }
            
            if let resultError = resultError {
                self.logger?.error("\(requestInfo.name) failure: \(resultError)")
            } else {
                self.logger?.debug("\(requestInfo.name) success")
            }
            
            completion(resultItem, resultError)
        }
        
        logger?.debug("\(requestInfo.name)")
//        networkDataProvider
        networkDataProvider.requestJSON(
            method: requestInfo.method,
            relativePath: requestInfo.path,
            parameters: requestInfo.parameters,
            encoding: encoding,
            headers: requestInfo.headers,
            responseHandler: networkDataProviderCompletion)
    }
    
    func request(_ requestInfo: RequestInfo,
                 completion: @escaping (_ error: NSError?) -> Void) {
        
        let encoding: Alamofire.ParameterEncoding
        
        if let parametersEncoding = requestInfo.parametersEncoding {
            switch parametersEncoding {
            case .json:
                encoding = Alamofire.JSONEncoding.default
            case .url:
                encoding = Alamofire.URLEncoding.default
            }
        } else {
            encoding = Alamofire.URLEncoding.methodDependent
        }
        
        let networkDataProviderCompletion = { (JSON: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> Void in
            
            var resultError: NSError?
            
            if let error = self.responseErrorParser.parse(json: JSON, error: error, response: response) {
                resultError = error
            }
            
            if let resultError = resultError {
                self.logger?.error("\(requestInfo.name) failure: \(resultError)")
            } else {
                self.logger?.debug("\(requestInfo.name) success")
            }
            
            completion(resultError)
        }
        
        logger?.debug("\(requestInfo.name)")
        
        networkDataProvider.requestJSON(
            method: requestInfo.method,
            relativePath: requestInfo.path,
            parameters: requestInfo.parameters,
            encoding: encoding,
            headers: requestInfo.headers,
            responseHandler: networkDataProviderCompletion)
    }
    
    func uploadWithSuccessfulModelValidation(_ info: UploadInfo,
                                             progressHandler: ((Float) -> Void)?,
                                             completion: @escaping (_ error: NSError?) -> Void) {
        let jsonParsingClosure = { (json: AnyObject) throws -> BWServiceSuccessResponseModel? in
            return try BWServiceSuccessResponseModel.mapFromJSON(json)
        }
        
        uploadData(info: info, jsonParsingClosure: jsonParsingClosure, progress: progressHandler) { (successModel, error) in
            var resultError = error

            if let successModel = successModel {
                if !successModel.success {
                    self.logger?.error("Response model success == false")
                    resultError = NSError.bw_awsErrorWithCode(.operationFailed,
                                                              defaultErrorMessage: successModel.message)
                }
            }

            completion(resultError)
        }
     }
    
    func requestWithSuccessModelValidation(_ requestInfo: RequestInfo, completion: @escaping (_ error: NSError?) -> Void) {
        
        let jsonParsingClosure = { (json: AnyObject) throws -> BWServiceSuccessResponseModel? in
            return try BWServiceSuccessResponseModel.mapFromJSON(json)
        }
        
        requestItems(requestInfo,
                     jsonParsingClosure: jsonParsingClosure) { (successModel, error) in
                        
                        var resultError = error
                        
                        if let successModel = successModel {
                            if !successModel.success {
                                self.logger?.error("Response model success == false")
                                resultError = NSError.bw_awsErrorWithCode(.operationFailed,
                                                                          defaultErrorMessage: successModel.message)
                            }
                        }
                        
                        completion(resultError)
        }
    }
    
}


struct BWServiceSuccessResponseModel {
    var success: Bool
    var message: String?
}


extension BWServiceSuccessResponseModel: BWFromJSONMappable {
    
    struct JSONKeys {
        static var Success = "success"
        static var Message = "message"
    }
    
    // MARK: BWFromJSONMappable
    
    static func mapFromJSON(_ json: Any) throws -> BWServiceSuccessResponseModel {
        let swiftyJSON = JSON(json)
        
        guard let success = swiftyJSON[JSONKeys.Success].bool else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        let result: BWServiceSuccessResponseModel
        
        if let message = swiftyJSON[JSONKeys.Message].string {
            result = BWServiceSuccessResponseModel(success: success, message: message)
        } else {
            result = BWServiceSuccessResponseModel(success: success, message: nil)
        }
        
        return result
    }
}
