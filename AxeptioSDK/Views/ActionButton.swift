//
//  ActionButton.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 11/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
	var action: (() -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}
	
	private func setup() {
		addTarget(self, action: #selector(self.performAction), for: .touchUpInside)
	}
	
	@IBAction private func performAction(_ sender: UIButton) {
		self.action?()
	}
}
