# SocialToolKit
SocialToolKit purpose is to get access token from Facebook, VK or Instagram. You can use it to get token from specific social network, or from several (now supports only Facebook, VKontakte and Instagram).

How to install:

Requirements:

iOS 9.0+

Swift 3.0

Installing with [CocoaPods](https://cocoapods.org):

```ruby
use_frameworks!
pod 'SocialToolKit'
```

How to use:

For Facebook:

Update this three methods in your AppDelegate:

1.
```swift
import SocialToolKit

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	SocialToolKit.sharedInstance.appFBDidFinishLaunchingWithOptions(application: application, launchOptions: launchOptions)
return true
}

func applicationDidBecomeActive(_ application: UIApplication) {
	SocialToolKit.sharedInstance.appFBDidBecomeActive()
}
        
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
	SocialToolKit.sharedInstance.appFBOpenURL(app: app, url: url, options: options)
	return true
}
```
	
2. Go to Info.plist, secondary-clic Info.plist and select OpenAs -> SourceCode.

Insert the following XML snippet into the body of your file just before the final </dict> element.
```xml
	<key>CFBundleURLTypes</key>
	<array>
	    <dict>
        	<key>CFBundleURLSchemes</key>
        		<array>
		            <string>fb{your-app-id}</string>
		        </array>
	    </dict>
	</array>
		<key>FacebookAppID</key>
			<string>{your-app-id}</string>
		<key>FacebookDisplayName</key>
			<string>{your-app-name}</string>
		<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>fbapi</string>
		<string>fb-messenger-api</string>
		<string>fbauth2</string>
		<string>fbshareextension</string>
	</array>
```

   - replace fb{your-app-id} with your Facebook app ID, prefixed with fb. For example, fb123456. You can find your app ID on the Facebook App Dashboard — https://developers.facebook.com/apps.
   - replace {your-app-id} with your app ID.
   - replace {your-app-name} with the display name you specified in the App Dashboard.
   - replace {human-readable reason for photo access} with the reason your app needs photo access.
    
3. In yor viewController add as button-action (for example):

```swift
import SocialToolKit

SocialToolKit.sharedInstance.requestFacebookToken(permissions: ["public_profile", "user_friends"], loginBehavior: FBSDKLoginBehavior.systemAccount, { (token, error) in
	if error == nil {
		print("TOKEN: \(token)")
	} else {
		print("ERROR: \(error?.localizedDescription)")
	}
})
```

For VK:

1. Update this method in your AppDelegate:

```swift
import SocialToolKit

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        SocialToolKit.sharedInstance.appVKOpenURL(sourceApplication: sourceApplication, url: url)
        return true
}
```
2. Go to Project -> Targets -> Info -> URL Types and add URL Schemes vk<your-app-id>, for example: 

URL Schemes:  vk1234567
Role:  Editor

3. Go to Info.plist, secondary-clic Info.plist and select OpenAs -> SourceCode. And add AppTransportSequrity:
```xml
	<key>NSAppTransportSecurity</key>
        <dict> 
            <key>NSExceptionDomains</key> 
            <dict> 
                <key>vk.com</key> 
                <dict> 
                    <key>NSExceptionRequiresForwardSecrecy</key> 
                    false/> 
                    <key>NSIncludesSubdomains</key> 
                    <true/> 
                    <key>NSExceptionAllowsInsecureHTTPLoads</key> 
                    <true/> 
                </dict> 
            </dict> 
        </dict>
```
    
4. Add (update) LSApplicationQueriesSchemes:
```xml
        <key>LSApplicationQueriesSchemes</key> 
        <array> 
            <string>vk</string> 
            <string>vk-share</string> 
            <string>vkauthorize</string> 
        </array>
```
If you are using FB iOS SDK and VK iOS SDK it looks like this:
```xml
        <key>LSApplicationQueriesSchemes</key>
        <array>
            <string>fbapi</string>
            <string>fb-messenger-api</string>
            <string>fbauth2</string>
            <string>fbshareextension</string>
            <string>vk</string>
            <string>vk-share</string>
            <string>vkauthorize</string>
        </array>
```

5. Then in ViewController (for example) use:

```swift
SocialToolKit.sharedInstance.requestVKToken(permissions: ["friends", "photos"], appId: "your app id") { (token, error) in
	if error == nil {
		print("TOKEN: \(token)")
	} else {
		print("ERROR: \(error?.localizedDescription)")
	}
}
```	

LICENCE:

Copyright (c) 2017 Stfalcon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.	
