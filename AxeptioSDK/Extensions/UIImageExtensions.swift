//
//  UIImageExtensions.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 07/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

extension UIImage {
	static func circle(size: CGSize, color: UIColor) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		color.set()
		UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom), false, self.scale)
		draw(at: CGPoint(x: insets.left, y: insets.top))
		let image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
		UIGraphicsEndImageContext()
		return image
	}
}
