//
//  Int+HTTPStatusCode.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 15.04.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


extension Int {
    static var HTTPStatusCode1XXInformationalUnknown: Int { return 1 }
    static var HTTPStatusCode100Continue: Int { return 100 }
    static var HTTPStatusCode101SwitchingProtocols: Int { return 101 }
    static var HTTPStatusCode102Processing: Int { return 102 }
    
    // Success
    static var HTTPStatusCode2XXSuccessUnknown: Int { return 2 }
    static var HTTPStatusCode200OK: Int { return 200 }
    static var HTTPStatusCode201Created: Int { return 201 }
    static var HTTPStatusCode202Accepted: Int { return 202 }
    static var HTTPStatusCode203NonAuthoritativeInformation: Int { return 203 }
    static var HTTPStatusCode204NoContent: Int { return 204 }
    static var HTTPStatusCode205ResetContent: Int { return 205 }
    static var HTTPStatusCode206PartialContent: Int { return 206 }
    static var HTTPStatusCode207MultiStatus: Int { return 207 }
    static var HTTPStatusCode208AlreadyReported: Int { return 208 }
    static var HTTPStatusCode209IMUsed: Int { return 209 }
    
    // Redirection
    static var HTTPStatusCode3XXSuccessUnknown: Int { return 3 }
    static var HTTPStatusCode300MultipleChoices: Int { return 300 }
    static var HTTPStatusCode301MovedPermanently: Int { return 301 }
    static var HTTPStatusCode302Found: Int { return 302 }
    static var HTTPStatusCode303SeeOther: Int { return 303 }
    static var HTTPStatusCode304NotModified: Int { return 304 }
    static var HTTPStatusCode305UseProxy: Int { return 305 }
    static var HTTPStatusCode306SwitchProxy: Int { return 306 }
    static var HTTPStatusCode307TemporaryRedirect: Int { return 307 }
    static var HTTPStatusCode308PermanentRedirect: Int { return 308 }
    
    // Client error
    static var HTTPStatusCode4XXSuccessUnknown: Int { return 4 }
    static var HTTPStatusCode400BadRequest: Int { return 400 }
    static var HTTPStatusCode401Unauthorised: Int { return 401 }
    static var HTTPStatusCode402PaymentRequired: Int { return 402 }
    static var HTTPStatusCode403Forbidden: Int { return 403 }
    static var HTTPStatusCode404NotFound: Int { return 404 }
    static var HTTPStatusCode405MethodNotAllowed: Int { return 405 }
    static var HTTPStatusCode406NotAcceptable: Int { return 406 }
    static var HTTPStatusCode407ProxyAuthenticationRequired: Int { return 407 }
    static var HTTPStatusCode408RequestTimeout: Int { return 408 }
    static var HTTPStatusCode409Conflict: Int { return 409 }
    static var HTTPStatusCode410Gone: Int { return 410 }
    static var HTTPStatusCode411LengthRequired: Int { return 411 }
    static var HTTPStatusCode412PreconditionFailed: Int { return 412 }
    static var HTTPStatusCode413RequestEntityTooLarge: Int { return 413 }
    static var HTTPStatusCode414RequestURITooLong: Int { return 414 }
    static var HTTPStatusCode415UnsupportedMediaType: Int { return 415 }
    static var HTTPStatusCode416RequestedRangeNotSatisfiable: Int { return 416 }
    static var HTTPStatusCode417ExpectationFailed: Int { return 417 }
    static var HTTPStatusCode418IamATeapot: Int { return 418 }
    static var HTTPStatusCode419AuthenticationTimeout: Int { return 419 }
    static var HTTPStatusCode420MethodFailureSpringFramework: Int { return 420 }
    static var HTTPStatusCode420EnhanceYourCalmTwitter: Int { return 4200 }
    static var HTTPStatusCode422UnprocessableEntity: Int { return 422 }
    static var HTTPStatusCode423Locked: Int { return 423 }
    static var HTTPStatusCode424FailedDependency: Int { return 424 }
    static var HTTPStatusCode424MethodFailureWebDaw: Int { return 4240 }
    static var HTTPStatusCode425UnorderedCollection: Int { return 425 }
    static var HTTPStatusCode426UpgradeRequired: Int { return 426 }
    static var HTTPStatusCode428PreconditionRequired: Int { return 428 }
    static var HTTPStatusCode429TooManyRequests: Int { return 429 }
    static var HTTPStatusCode431RequestHeaderFieldsTooLarge: Int { return 431 }
    static var HTTPStatusCode444NoResponseNginx: Int { return 444 }
    static var HTTPStatusCode449RetryWithMicrosoft: Int { return 449 }
    static var HTTPStatusCode450BlockedByWindowsParentalControls: Int { return 450 }
    static var HTTPStatusCode451RedirectMicrosoft: Int { return 451 }
    static var HTTPStatusCode451UnavailableForLegalReasons: Int { return 4510 }
    static var HTTPStatusCode494RequestHeaderTooLargeNginx: Int { return 494 }
    static var HTTPStatusCode495CertErrorNginx: Int { return 495 }
    static var HTTPStatusCode496NoCertNginx: Int { return 496 }
    static var HTTPStatusCode497HTTPToHTTPSNginx: Int { return 497 }
    static var HTTPStatusCode499ClientClosedRequestNginx: Int { return 499 }
    
    
    // Server error
    static var HTTPStatusCode5XXSuccessUnknown: Int { return 5 }
    static var HTTPStatusCode500InternalServerError: Int { return 500 }
    static var HTTPStatusCode501NotImplemented: Int { return 501 }
    static var HTTPStatusCode502BadGateway: Int { return 502 }
    static var HTTPStatusCode503ServiceUnavailable: Int { return 503 }
    static var HTTPStatusCode504GatewayTimeout: Int { return 504 }
    static var HTTPStatusCode505HTTPVersionNotSupported: Int { return 505 }
    static var HTTPStatusCode506VariantAlsoNegotiates: Int { return 506 }
    static var HTTPStatusCode507InsufficientStorage: Int { return 507 }
    static var HTTPStatusCode508LoopDetected: Int { return 508 }
    static var HTTPStatusCode509BandwidthLimitExceeded: Int { return 509 }
    static var HTTPStatusCode510NotExtended: Int { return 510 }
    static var HTTPStatusCode511NetworkAuthenticationRequired: Int { return 511 }
    static var HTTPStatusCode522ConnectionTimedOut: Int { return 522 }
    static var HTTPStatusCode598NetworkReadTimeoutErrorUnknown: Int { return 598 }
    static var HTTPStatusCode599NetworkConnectTimeoutErrorUnknown: Int { return 599 }
}
