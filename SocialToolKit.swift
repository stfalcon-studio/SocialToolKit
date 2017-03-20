//
//  SocialManager.swift
//  Triplook
//
//  Created by Victor Amelin on 6/10/16.
//  Copyright © 2016 Victor Amelin. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import VK_ios_sdk

public final class SocialToolKit: NSObject, VKSdkDelegate {
    public typealias SocialTokenHandler = (_ token: String?, _ error: NSError?) -> Void
    
    private override init() {}
    public static let sharedInstance = SocialToolKit()
    override open func copy() -> Any {
        fatalError("You are not allowed to use copy method on singleton!")
    }
    override open func mutableCopy() -> Any {
        fatalError("You are not allowed to use copy method on singleton!")
    }
    
    //================================
    
    private var handler: SocialTokenHandler?
    private var vkAppID: String?
    
    //MARK: AppDelegate methods
    public func appFBDidFinishLaunchingWithOptions(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func appFBOpenURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) {
        FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    public func appVKOpenURL(sourceApplication: String?, url: URL) {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
    }
    
    public func appFBDidBecomeActive() {
        FBSDKAppEvents.activateApp()
    }
    
    //MARK: Helpers
    private func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    private func isSimulator() -> Bool {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return true
        #endif
        return false
    }
    
    private func registerVKDelegate() {
        let sdkInstance = VKSdk.initialize(withAppId: vkAppID)
        sdkInstance?.register(self)
    }
    
    private func unregisterVKDelegate() {
        let sdkInstance = VKSdk.initialize(withAppId: vkAppID)
        sdkInstance?.unregisterDelegate(self)
    }
    
    //MARK: Facebook
    public func requestFacebookToken(permissions: [String], loginBehavior: FBSDKLoginBehavior, _ handler: @escaping SocialTokenHandler) {
        let login = FBSDKLoginManager()
        login.loginBehavior = loginBehavior
        login.logIn(withReadPermissions: permissions, from: nil) { (result, error) in
            if error != nil {
                handler(nil, error as NSError?)
            } else if (result?.isCancelled)! {
                handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"FB User pressed cancel!"]))
            } else {
                if let token = result?.token?.tokenString {
                    handler(token, nil)
                } else {
                    handler(nil, nil)
                }
            }
        }
        login.logOut()
    }
    
    //MARK: VK
    public func requestVKToken(permissions: [String], appId: String, _ handler: @escaping SocialTokenHandler) {
        if !self.isSimulator() {
            VKSdk.forceLogout()
            self.handler = handler
            self.vkAppID = appId
            
            registerVKDelegate()
            VKSdk.authorize(permissions)
        } else {
            handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"VK doesn`t work with simulator!"]))
        }
    }
    
    //MARK: VKSdkDelegate
    public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let handler = self.handler {
            if let accessToken = result.token {
                if let token = accessToken.accessToken {
                    handler(token, nil)
                    unregisterVKDelegate()
                } else {
                    handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"VK cannot get token!"]))
                }
            }
        }
    }
    
    public func vkSdkUserAuthorizationFailed() {
        if let handler = self.handler {
            unregisterVKDelegate()
            handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"VK registration failed!"]))
        }
    }
    
    public func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        if let handler = self.handler {
            if let token = result.token.accessToken {
                handler(token, nil)
                unregisterVKDelegate()
            } else {
                handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"VK cannot update token!"]))
                unregisterVKDelegate()
            }
        }
    }
    
    public func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        if let handler = self.handler {
            if let newToken = newToken.accessToken {
                handler(newToken, nil)
                unregisterVKDelegate()
            } else {
                handler(nil, NSError(domain: "com.stfalcon.social", code: 0, userInfo: [NSLocalizedDescriptionKey:"VK cannot update token!"]))
                unregisterVKDelegate()
            }
        }
    }    
}




