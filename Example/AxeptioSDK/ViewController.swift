//
//  ViewController.swift
//  AxeptioSDK
//
//  Created by Axeptio on 02/26/2021.
//  Copyright (c) 2021 Axeptio. All rights reserved.
//

import UIKit
import AxeptioSDK



class ViewController: UIViewController {
    
    let yourClientId = "6058635aa6a92469bed037b0"
    let yourVersion = "ga_fb"

	override func viewDidLoad() {
		super.viewDidLoad()
		Axeptio.shared.initialize(clientId: yourClientId, version: yourVersion) { [weak self] error in
			guard self != nil && error == nil else {
				return
			}
			Axeptio.shared.showConsentController(in: self!) { error in
				let result = Axeptio.shared.getUserConsent(forVendor: "google_analytics")
				print("Google Analytics consent is \(result)")
			}
		}
	}
}
