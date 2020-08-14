//
//  BWNetworkDataProvider.swift
//  Bellwether-iOS
//
//  Created by Anna Yefremova on 24/02/2016.
//  Copyright © 2016 Bellwether. All rights reserved.
//


import Alamofire

// swiftlint:disable function_parameter_count

typealias BWResponseJSONHandler = (_ JSON: AnyObject?, _ error: NSError?, _ response: HTTPURLResponse?) -> Void
typealias BWResponseDataHandler = (_ data: Data?, _ error: NSError?, _ response: HTTPURLResponse?) -> Void
typealias BWResponseProgressHandler = (_ progress: Float) -> Void

// MARK: protocol BWNetworkDataProvider
protocol BWNetworkDataProvider {
    func requestJSON(method: HTTPMethod, relativePath: String,
                     responseHandler: @escaping BWResponseJSONHandler)
    
    func requestJSON(method: HTTPMethod, relativePath: String,
                     parameters: [String : Any]?, encoding: ParameterEncoding, headers: [String : String]?,
                     responseHandler: @escaping BWResponseJSONHandler)
    
    func requestData(method: HTTPMethod, relativePath: String,
                     responseHandler: @escaping BWResponseDataHandler)
    
    func requestData(method: HTTPMethod, relativePath: String,
                     parameters: [String : Any]?, encoding: ParameterEncoding, headers: [String : String]?,
                     responseHandler: @escaping BWResponseDataHandler)
    
    func upload(method: HTTPMethod, data: Data, relativePath: String, fileName: String,
                progressHandler: BWResponseProgressHandler?,
                responseHandler: @escaping BWResponseJSONHandler)
    
    func upload(method: HTTPMethod, url: URL, relativePath: String, fileName: String,
                progressHandler: BWResponseProgressHandler?,
                responseHandler: @escaping BWResponseJSONHandler)
}

// MARK: -
class BWNetworkService: BWNetworkDataProvider, BWLoggerContainer {
    
    let serverInfo: BWServerInfo!
    fileprivate let authDelegate: BWNetworkAuthDelegate?
    fileprivate let sessionManager: Alamofire.SessionManager
    
    public var requestRetrier: Alamofire.RequestRetrier? = nil {
        didSet {
            sessionManager.retrier = requestRetrier
        }
    }
    
    // MARK: Lifecycle
    
    init(serverInfo: BWServerInfo,
         authDelegate: BWNetworkAuthDelegate? = nil,
         configuration: URLSessionConfiguration? = nil) {
        self.serverInfo = serverInfo
        self.authDelegate = authDelegate
        
        if let configuration = configuration {
            self.sessionManager = Alamofire.SessionManager(configuration: configuration)
        } else {
            sessionManager = Alamofire.SessionManager.default
        }
        
        sessionManager.adapter = self
        
        acceptInvalidSSLCerts()        
    }
    
    // TODO: remove this once backend has valid SSH certificate
    // TODO: update info.plist Application Transport Security (ATS) config once this is done
    private func acceptInvalidSSLCerts() {
        logger?.info("[TEMP]Trying to accept invalid certs")
        
        sessionManager.delegate.sessionDidReceiveChallenge = { [weak self] session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    if let storage = self?.sessionManager.session.configuration.urlCredentialStorage {
                        credential = storage.defaultCredential(for: challenge.protectionSpace)
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
    }

    
    // MARK: BWNetworkDataProvider
    
    func requestJSON(method: HTTPMethod, relativePath: String,
                            responseHandler: @escaping BWResponseJSONHandler) {
        requestJSON(method: method,
                    relativePath: relativePath,
                    parameters: nil,
                    encoding: URLEncoding.methodDependent as ParameterEncoding,
                    headers: nil,
                    responseHandler: responseHandler)
    }
    
    func requestJSON(method: HTTPMethod,
                     relativePath: String,
                     parameters: [String : Any]?,
                     encoding: ParameterEncoding = JSONEncoding.default,
                     headers: [String : String]? = nil,
                     responseHandler: @escaping BWResponseJSONHandler) {
            
        let request = fullPathRequest(method: method,
                                      relativePath: relativePath,
                                      parameters: parameters,
                                      encoding: encoding,
                                      headers: headers)
        
        logger?.debug("requestJSON \(request)")
        logger?.verbose(request.debugDescription)
        
        requestJSON(request: request, retryCount: 2, responseHandler: responseHandler)
    }
    
    private func requestJSON(request: DataRequest,
                             retryCount: UInt,
                             responseHandler: @escaping BWResponseJSONHandler) {
        
        request.responseJSON {
            [unowned self] response in
            
            if let authDelegate = self.authDelegate,
                let urlRequest = request.request,
                let authError = authDelegate.checkAuthenticationError(response.request,
                    response: response.response,
                    json: response.result.value as AnyObject?,
                    error: response.result.error as NSError?) {
                
                authDelegate.recoverRequestFromAuthenticationError(urlRequest) { [unowned self] (recoveredRequest) in
                    if retryCount == 0 || recoveredRequest == nil {
                        responseHandler(response.result.value as AnyObject?, authError, request.response)
                    } else if let request = recoveredRequest {
                        self.requestJSON(request: self.sessionManager.request(request),
                            retryCount: retryCount - 1,
                            responseHandler: responseHandler)
                    }
                }
            } else {
                
                if let error = response.result.error {
                    self.logger?.error("requestJSON failure \(error)")
                } else {
                    self.logger?.debug("requestJSON success")
                    self.logger?.verbose(response.result.value as Any)
                }
                
                responseHandler(response.result.value as AnyObject?,
                                self.parseResponseError(response: response),
                                response.response)
            }
        }
    }

    func requestData(method: HTTPMethod, relativePath: String,
                            responseHandler: @escaping BWResponseDataHandler) {
        requestData(method: method, relativePath: relativePath, parameters: nil,
                    encoding: URLEncoding.methodDependent as ParameterEncoding,
                    headers: nil, responseHandler: responseHandler)
    }
    
    func requestData(method: HTTPMethod, relativePath: String,
                            parameters: [String : Any]?, encoding: ParameterEncoding, headers: [String : String]?,
                            responseHandler: @escaping BWResponseDataHandler) {
    
        let request = fullPathRequest(method: method,
                                      relativePath: relativePath,
                                      parameters: parameters,
                                      encoding: encoding,
                                      headers: headers)
    
        logger?.debug("requestJSON \(request)")
        
        requestData(request: request, retryCount: 2, responseHandler: responseHandler)
    }
    
    func upload(method: HTTPMethod, data: Data, relativePath: String,
                fileName: String,
                progressHandler: BWResponseProgressHandler?,
                responseHandler: @escaping BWResponseJSONHandler) {
        upload(method: method,
               multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: fileName, fileName: fileName, mimeType: "")
            },
               relativePath: relativePath,
               fileName: fileName,
               progressHandler: progressHandler,
               responseHandler: responseHandler)
    }

    func upload(method: HTTPMethod, url: URL, relativePath: String,
                fileName: String,
                progressHandler: BWResponseProgressHandler?,
                responseHandler: @escaping BWResponseJSONHandler) {
        upload(method: method,
               multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: fileName)
            },
               relativePath: relativePath,
               fileName: fileName,
               progressHandler: progressHandler,
               responseHandler: responseHandler)
    }
    
    private func requestData(request: DataRequest,
                             retryCount: UInt,
                             responseHandler: @escaping BWResponseDataHandler) {
        request.responseData { [unowned self] response in
            if let authDelegate = self.authDelegate,
                let urlRequest = request.request,
                let authError = authDelegate.checkAuthenticationError(response.request,
                    response: response.response,
                    data: response.result.value,
                    error: self.parseResponseError(response: response)) {
                
                authDelegate.recoverRequestFromAuthenticationError(urlRequest) { [unowned self] (recoveredRequest) in
                    if retryCount == 0 || recoveredRequest == nil {
                        responseHandler(response.result.value, authError, request.response)
                    } else if let request = recoveredRequest {
                        self.requestData(request: self.sessionManager.request(request),
                            retryCount: retryCount - 1,
                            responseHandler: responseHandler)
                    }
                }
            } else {
                
                if let error = response.result.error {
                    self.logger?.error("requestData failure \(error)")
                } else {
                    self.logger?.debug("requestData success")
                    self.logger?.verbose(response.result.value as Any)
                }
                
                responseHandler(response.result.value as Data?,
                                self.parseResponseError(response: response),
                                response.response)
            }
        }
    }
    
    // MARK: BWLoggerContainer
    
    var logger: BWLogger?
    
    // MARK: Private
    
    private func fullPathRequest(method: HTTPMethod,
                                 relativePath: String,
                                 parameters: [String : Any]? = nil,
                                 encoding: ParameterEncoding = URLEncoding.methodDependent,
                                 headers: [String : String]? = nil) -> DataRequest {
        let requestURL = fullURLPathForRelativePath(relativePath: relativePath)
        let request = sessionManager.request(requestURL,
                                             method: method,
                                             parameters: parameters,
                                             encoding: encoding,
                                             headers: headers)
        return request
    }
    
    private func fullURLPathForRelativePath(relativePath: String) -> URL {
        return serverInfo.baseURL.appendingPathComponent(relativePath)
    }
    
    private func upload(method: HTTPMethod,
                        multipartFormData: @escaping (Alamofire.MultipartFormData) -> Void,
                        relativePath: String,
                        fileName: String,
                        progressHandler: BWResponseProgressHandler?,
                        responseHandler: @escaping BWResponseJSONHandler) {
        guard let request = fullPathRequest(method: method, relativePath: relativePath).request else {
            return
        }
        
        sessionManager.upload(multipartFormData: multipartFormData, with: request) {
            (encodingResult: Alamofire.SessionManager.MultipartFormDataEncodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.validate()
                upload.responseJSON { response in
                    let responseJSON = response.result.value
                    responseHandler(responseJSON as AnyObject?, response.result.error as NSError?, response.response)
                }
                
            case .failure(_):
                let error  = NSError.bw_awsErrorWithCode(.operationFailed)
                responseHandler(nil, error, nil)
            }
        }
    }
    
    // MARK: - Errors
    
    private func parseResponseError<T>(response: DataResponse<T>) -> NSError? {
        guard case let .failure(error) = response.result else { return nil }
        
        return parseResponseError(error: error)
    }
    
    private func parseResponseError(error: Error) -> NSError? {
        // TODO: Migrate to Swift 3.0 Errors
        if let error = error as? AFError {
            var userInfo: [String: Any] = [:]
            userInfo[NSLocalizedFailureReasonErrorKey] = error.failureReason
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = error.recoverySuggestion
            userInfo[NSLocalizedDescriptionKey] = error.localizedDescription
            return NSError(domain: "org.alamofire", code: error._code, userInfo: userInfo)
        } else if let error = error as? URLError {
            return NSError(domain: NSURLErrorDomain, code: error.errorCode, userInfo: error.userInfo)
        } else {
            logger?.error("Unknown error: \(error)")
            return nil
        }
    }
}

extension BWNetworkService: Alamofire.RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let url = urlRequest.url else {
            return urlRequest
        }
        
        var adaptedRequest = urlRequest
        
        // Update URL for case if serverInfo has changed
        if var adaptedURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            adaptedURLComponents.host = serverInfo.baseURL.host
            adaptedURLComponents.port = serverInfo.baseURL.port
            adaptedURLComponents.scheme = serverInfo.baseURL.scheme
            if let adaptedURL = try? adaptedURLComponents.asURL() {
                adaptedRequest.url = adaptedURL
            }
        }
        
        // Inject auth data into request
        if let authDelegate = authDelegate {
            adaptedRequest = authDelegate.authenticateRequest(urlRequest)
        }
        
        return adaptedRequest
    }
}

// swiftlint:enable function_parameter_count
