# Axeptio SDK

## Introduction

User consent is not only limited to the Web but applies to all platforms collecting user data. Mobile devices are part of it.

## Installation

### **CocoaPods**

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target 'MyApp' do
  pod 'AxeptioSDK'
end
```

## Getting started

In the main file of your app, import the `Axeptio` module, initialize the SDK by calling the `initialize` method providing a `clientId`. Once initialization is completed, you can show Axeptio's widget for a given `version` in a visible view controller.

```swift
import UIKit
import Axeptio

Axeptio.shared.initialize(clientId: "<My client ID>") { error in
	// Handle error
	// You could try to initialize again after some delay for example
	...
	
	Axeptio.shared.showCookiesController(version: "<My version>", in: someVisibleViewController) { error in
		// User has made his choices, we can query them
		let userConsent = Axeptio.shared.getUserConsent(forVendor: "<Vendor name>")
		...
	}
}
```

If your app supports multiple languages you probably have created a different version for each of the language in Axeptio's [admin web page](https://admin.axeptio.eu). In this case you can store the version for each language in `Localizable.strings` file and use `NSLocalizedString` to get the appropriate version for the user.

## API Reference

### initialize

The `initialize` function initializes the SDK by fetching the configuration and calling the completion handler when done. If it fails (because of network for example) it is OK to call the `initialize` function again.

```swift
func initialize(clientId: String, completionHandler: @escaping (Error?) -> Void)
```

### showCookiesController

The `showCookiesController` function shows Axeptio's widget to the user in a given view controller and calls the completion handler when the user has made his choices. If the user has already made his choices in a previous call the widget is not shown and the completion is called immediately. However if the `version` is different or the configuration includes new vendors then the widget is shown again.

```swift
func showCookiesController(version: String, in viewController: UIViewController, animated: Bool = true, completionHandler: @escaping (Error?) -> Void)
```

### getUserConsent

The `getUserConsent` function returns an optional boolean indicating if the user has made his choice for given vendor and whether or not he gave his consent. If the returned value is `nil` it either means the vendor was not present in the configuration or the widget has not been presented to the user yet.

```swift
func getUserConsent(forVendor name: String) -> Bool?
```

## Author

Axeptio

## License

AxeptioSDK is available under the MIT license. See the LICENSE file for more info.
