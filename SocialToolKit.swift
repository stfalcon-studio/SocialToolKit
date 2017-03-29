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

protocol SocialToolKitProtocol {
    func topViewController(_ base: UIViewController?) -> UIViewController?
}

extension SocialToolKitProtocol {
    func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
}

public final class SocialToolKit: NSObject, VKSdkDelegate, SocialToolKitProtocol {
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
    fileprivate var instaVC: InstagramVC?
    
    //MARK: AppDelegate methods
    public func appFBDidFinishLaunchingWithOptions(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func appFBOpenURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    public func appVKOpenURL(sourceApplication: String?, url: URL) -> Bool {
        return VKSdk.processOpen(url, fromApplication: sourceApplication)
    }
    
    public func appFBDidBecomeActive() {
        FBSDKAppEvents.activateApp()
    }
    
    //MARK: Helpers
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
                handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"FB User pressed cancel!"]))
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
            handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"VK doesn`t work with simulator!"]))
        }
    }
    
    //MARK: Instagram
    public func requestInstagramToken(permissions: [String]?, clientID: String, redirectURI: String, _ handler: @escaping SocialTokenHandler) {
        let vc = InstagramVC(permissions: permissions, clientID: clientID, redirectURI: redirectURI, handler: handler)
        topViewController()?.present(vc, animated: true, completion: nil)
    }
    
    //MARK: VKSdkDelegate
    public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let handler = self.handler {
            if let accessToken = result.token {
                if let token = accessToken.accessToken {
                    handler(token, nil)
                    unregisterVKDelegate()
                } else {
                    handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"VK cannot get token!"]))
                }
            }
        }
    }
    
    public func vkSdkUserAuthorizationFailed() {
        if let handler = self.handler {
            unregisterVKDelegate()
            handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"VK registration failed!"]))
        }
    }
    
    public func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        if let handler = self.handler {
            if let token = result.token.accessToken {
                handler(token, nil)
                unregisterVKDelegate()
            } else {
                handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"VK cannot update token!"]))
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
                handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"VK cannot update token!"]))
                unregisterVKDelegate()
            }
        }
    }
}

fileprivate final class InstagramVC: UIViewController, UIWebViewDelegate, SocialToolKitProtocol {
    private var permissions: [String]?
    private var clientID: String?
    private var redirectURI: String?
    private var accessTokenReceived = false
    private let offset: CGFloat = 50.0
    private var handler: ((_ token: String?, _ error: NSError?) -> Void)!
    
    init(permissions: [String]?, clientID: String, redirectURI: String, handler: @escaping (_ token: String?, _ error: NSError?) -> Void) {
        super.init(nibName: nil, bundle: nil)
        
        self.permissions = permissions
        self.clientID = clientID
        self.redirectURI = redirectURI
        self.handler = handler
        
        view.backgroundColor = UIColor(red: 81/255.0, green: 125/255.0, blue: 160/255.0, alpha: 1.0)
        let cancelBtn = UIButton(frame: CGRect(x: 0.0, y: 15.0, width: 60.0, height: offset - 15.0))
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
        
        configureWebView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: { [weak self] in
            self?.handler!(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"Instagram user pressed cancel!"]))
        })
    }
    
    //MARK: Helpers
    func configureWebView() {
        if let topVC = topViewController() {
            let vcFrame = topVC.view.frame
            let webView = UIWebView(frame: CGRect(x: vcFrame.origin.x,
                                                  y: vcFrame.origin.y + offset,
                                                  width: vcFrame.size.width,
                                                  height: vcFrame.size.height - offset))
            webView.delegate = self
            
            //build url path
            var scope = ""
            if let permissions = permissions {
                scope = permissions.joined(separator: "+")
                scope = "&scope=\(scope)"
            }
            
            let path = "https://api.instagram.com/oauth/authorize/?client_id=\(self.clientID!)\(scope)&redirect_uri=\(self.redirectURI!)&response_type=token"
            let urlRequest = URLRequest(url: URL(string: path)!)
            webView.loadRequest(urlRequest)
            view.addSubview(webView)
            
        } else {
            handler(nil, NSError(domain: "com.stfalcon.social", code: 404, userInfo: [NSLocalizedDescriptionKey:"Instagram cannot get topViewController!"]))
        }
    }
    
    //MARK: UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.request?.url?.absoluteString.contains("#access_token") == true {
            if accessTokenReceived == false {
                accessTokenReceived = true
                
                //trim token
                let accessToken = (webView.request!.url!.absoluteString as NSString).lastPathComponent.replacingOccurrences(of: "#access_token=", with: "")
                
                dismiss(animated: true, completion: { [weak self] in
                    self?.handler(accessToken, nil)
                })
            }
        }
    }
}















