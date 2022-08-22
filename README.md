# Axeptio SDK

## Introduction

User consent is not only limited to the Web but applies to all platforms collecting user data. Mobile devices are part of it.

## Requirements

Minimum iOS version: **12.x**

## Installation

1. If you haven’t already, install the latest version of [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#installation).

2. If you don’t have an existing Podfile, create a new one by running the command:

```bash
pod init
```

3. Add `pod 'AxeptioSDK'` to your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'AxeptioSDK'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
		end
	end
end
```

4. Run the following command:

```bash
pod install
```

5. In the future, to update the SDK to its latest version, run the command:

```bash
pod update AxeptioSDK
```

## Getting started

### Swift

In the main controller of your app, import the `AxeptioSDK` module, initialize the SDK by calling the `initialize` method providing a `clientId` and a `version`. Once the initialization is completed, you can make the widget appear by calling the `showConsentController` method.

```swift
import UIKit
import AxeptioSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set a custom token
        // Axeptio.shared.token = "auto-generated-token-xxx"

        Axeptio.shared.initialize(clientId: "<Client ID>", version: "<Version>") { error in
	    // Handle error
	    // You could try to initialize again after some delay for example
            Axeptio.shared.showConsentController(in: self) { error in
                // User has made his choices
		// We can now enable or disable the collection of metrics of the analytics library
                if Axeptio.shared.getUserConsent(forVendor: "<Vendor name>") ?? false {
                    // Disable collection
                } else {
                    // Enable collection
                }
            }
        }
    }


}
```

If your app supports multiple languages you probably have created a different version for each of the language in Axeptio's [admin web page](https://admin.axeptio.eu). In this case you can store the version for each language in `Localizable.strings` file and use `NSLocalizedString` to get the appropriate version for the user.

### Objective-C

```objective-c
#import "ViewController.h"
#import <AxeptioSDK/AxeptioSDK-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set a custom token
    // [Axeptio setToken:@"auto-generated-token-xxx"];

    [Axeptio initializeWithClientId:@"<Client ID>" version:@"<Version>" completionHandler:^(NSError *error) {
        // Handle error
        // You could try to initialize again after some delay for example
        [Axeptio showConsentControllerWithInitialStepIndex:0 onlyFirstTime:TRUE in:self animated:YES completionHandler:^(NSError *error) {
            // User has made his choices
            // We can now enable or disable the collection of metrics of the analytics library
            if ([Axeptio getUserConsentForVendor:@"<Vendor name>"]) {
                // Disable collection
            } else {
                // Enable collection
            }

        }];
    }];
}


@end
```

## API Reference

### Properties

#### token

The `token` property can be used to set a custom token. By default, a random identifier is set.

This property is particularly useful for apps using webviews. By opening the webview while passing the token in the `axeptio_token` querystring parameter, the consent previously given in the app will be reused on the website if it uses the web SDK.

### Methods

#### initialize

The `initialize` function initializes the SDK by fetching the configuration and calling the completion handler when done. If it fails (because of network for example) it is OK to call the `initialize` function again.

```swift
func initialize(clientId: String, version: String, completionHandler: @escaping (Error?) -> Void)
```

#### showConsentController

The `showConsentController` function shows Axeptio's widget to the user in a given view controller and calls the completion handler when the user has made his choices. If `onlyFirstTime` is true and the user has already made his choices in a previous call the widget is not shown and the completion is called immediately. However if the configuration includes new vendors then the widget is shown again. You can specify an `initialStepIndex` greater than 0 to show a different step directly.

```swift
func showConsentController(initialStepIndex: Int = 0, onlyFirstTime: Bool = true, in viewController: UIViewController, animated: Bool = true, completionHandler: @escaping (Error?) -> Void) -> (() -> Void)?
```

If the widget is shown the function returns a dismiss handler that you can call to hide the widget should you need it. Otherwise returns nil.

#### getUserConsent

The `getUserConsent` function returns an optional boolean indicating if the user has made his choice for given vendor and whether or not he gave his consent. If the returned value is `nil` it either means the vendor was not present in the configuration or the widget has not been presented to the user yet.

```swift
func getUserConsent(forVendor name: String) -> Bool?
```

#### setUserConsentToDisagreeWithAll

The `setUserConsentToDisagreeWithAll` function sets the consent for all vendors to false and saves the preference. This function is useful when using the App Tracking Transparency. If a user denies the tracking authorization request, call this function so that the CMP is not displayed and the consent of the user is saved in the Axeptio consent registry.

## Author

Axeptio

## License

AxeptioSDK is available under the MIT license. See the LICENSE file for more info.
