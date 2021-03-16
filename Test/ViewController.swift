//
//  ViewController.swift
//  Test
//
//  Created by Cyril Anger on 02/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit
import Axeptio

class ViewController: UIViewController {
	private var dismissHandler: (() -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		Axeptio.shared.initialize(clientId: "5ffc24255558222597d6afa9") { [weak self] error in
			guard error == nil else {
				return
			}
			self?.showCookiesController()
		}
	}
	
	@IBAction private func clearUserConsents(_ sender: Any? = nil) {
		Axeptio.shared.clearUserConsents()
	}
	
	@IBAction private func showCookiesController(_ sender: Any? = nil) {
		self.dismissHandler?()
		self.dismissHandler = Axeptio.shared.showCookiesController(version: "ga_only", onlyFirstTime: sender == nil, in: self) { error in
			let result = Axeptio.shared.getUserConsent(forVendor: "google_analytics")
			print("Google Analytics consent is \(result)")
		}
	}
}
