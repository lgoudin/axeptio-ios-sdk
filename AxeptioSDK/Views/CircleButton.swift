//
//  CircleButton.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 07/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

class CircleButton: ActionButton {
	override var bounds: CGRect {
		didSet {
			if oldValue.size != self.bounds.size {
				updateBackgroundImages()
			}
		}
	}
	
	@IBInspectable var color: UIColor = .white {
		didSet {
			updateBackgroundImages()
		}
	}
	
	@IBInspectable var highlightedColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
		didSet {
			updateBackgroundImages()
		}
	}
	
	weak var bottomLabel: UILabel?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setup()
	}
	
	private func setup() {
		updateBackgroundImages()
		self.layer.shadowOpacity = 0.4
		self.layer.shadowOffset = CGSize(width: 0, height: 2)
		self.layer.shadowRadius = 8
	}
	
	private func updateBackgroundImages() {
		var size = self.frame.size
		size.width = min(size.width, size.height)
		size.height = size.width
		var insets = UIEdgeInsets.zero
		insets.left = floor((self.frame.width - size.width) / 2)
		insets.right = self.frame.width - size.width - insets.left
		insets.top = floor((self.frame.height - size.height) / 2)
		insets.bottom = self.frame.height - size.height - insets.top
		setBackgroundImage(UIImage.circle(size: size, color: self.color)?.withInsets(insets), for: .normal)
		setBackgroundImage(UIImage.circle(size: size, color: self.highlightedColor)?.withInsets(insets), for: .highlighted)
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		self.layer.shadowColor = self.tintColor.cgColor
	}
	
	override var isHighlighted: Bool {
		didSet {
			self.bottomLabel?.isHighlighted = self.isHighlighted
		}
	}
}
