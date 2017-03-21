# SocialToolKit
Easy social network authorization for iOS. Supports Facebook, Vkontakte https://stfalcon.com

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

- add this three methods to your AppDelegate:

1). func appFBDidFinishLaunchingWithOptions(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?)

2). func appFBOpenURL(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:])

3). func appFBDidBecomeActive()

For VK:

- add this method to your AppDelegate:

1). func appVKOpenURL(sourceApplication: String?, url: URL)

Then in ViewController (for example) use:


	SocialToolKit.sharedInstance.requestVKToken(permissions: ["friends", "photos"], appId: "your app id") { (token, error) in
            if error == nil {
                print("TOKEN: \(token)")
            } else {
                print("ERROR: \(error?.localizedDescription)")
            }
        }
				
Don`t forget to add all FacebookAppID and VKontakteAppID into Info.plist and:


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
	 
Also don`t forget to add URL Types in Info section.

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

	
