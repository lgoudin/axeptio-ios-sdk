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
	override func viewDidLoad() {
		super.viewDidLoad()
		Axeptio.shared.initialize(clientId: "<Replace with your client ID>") { [weak self] error in
			guard self != nil && error == nil else {
				return
			}
			Axeptio.shared.showCookiesController(version: "<Replace with your version>", in: self!) { error in
				let result = Axeptio.shared.getUserConsent(forVendor: "google_analytics")
				print("Google Analytics consent is \(result)")
			}
		}
	}
}
