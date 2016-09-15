//
//  Authorization.swift
//  QuadratTouch
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit

/** The delegate of authorization view controller. */
@objc public protocol SessionAuthorizationDelegate: class {
    
    /** It can be useful if one needs 1password integration. */
    @objc optional func sessionWillPresentAuthorizationViewController(_ controller: AuthorizationViewController)
    
    @objc optional func sessionWillDismissAuthorizationViewController(_ controller: AuthorizationViewController)
}

extension Session {
    
    public func canUseNativeOAuth() -> Bool {
        let baseURL = self.configuration.server.nativeOauthBaseURL
        let URL = Foundation.URL(string: baseURL) as Foundation.URL!
        return UIApplication.shared.canOpenURL(URL!)
    }
    
    public func handleURL(_ URL: Foundation.URL) -> Bool {
        if let nativeAuthorizer = self.authorizer as? NativeTouchAuthorizer {
           return nativeAuthorizer.handleURL(URL) as Bool!
        }
        let nativeAuthorizer = NativeTouchAuthorizer(configuration: self.configuration)
        return nativeAuthorizer.handleURL(URL) as Bool!
    }
    
    public func authorizeWithViewController(_ viewController: UIViewController,
        delegate: SessionAuthorizationDelegate?, completionHandler: @escaping AuthorizationHandler) {
            
        if self.authorizer == nil {
            let block = {
                (accessToken: String?, error: NSError?) -> Void in
                self.authorizer = nil
                completionHandler(accessToken != nil, error)
            }
            
            if self.canUseNativeOAuth() {
                let nativeAuthorizer = NativeTouchAuthorizer(configuration: self.configuration)
                nativeAuthorizer.authorize(block)
                self.authorizer = nativeAuthorizer
            } else {
                let touchAuthorizer = TouchAuthorizer(configuration: self.configuration)
                touchAuthorizer.authorize(viewController, delegate: delegate, completionHandler: block)
                self.authorizer = touchAuthorizer
            }
        }

    }
}
