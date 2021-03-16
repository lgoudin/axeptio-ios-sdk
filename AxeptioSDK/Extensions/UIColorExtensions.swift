//
//  UIColorExtensions.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 04/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

extension UIColor {
	convenience init(web: String) {
		var hex = web
		if (hex.hasPrefix("#")) {
			hex.remove(at: hex.startIndex)
		}
		var int: UInt32 = 0
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.count {
		case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default: (a, r, g, b) = (0, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
	}
	
	var web: String {
		var red: CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		var web = String(format: "#%02X%02X%02X", Int(round(red * 255)), Int(round(green * 255)), Int(round(blue * 255)))
		if alpha < 1.0 {
			web += String(format: "%02X", Int(round(alpha * 255)))
		}
		return web
	}
}

extension KeyedEncodingContainer {
	mutating func encode(_ value: UIColor, forKey key: Key) throws {
		try encode(value.web, forKey: key)
	}
	
	mutating func encodeIfPresent(_ value: UIColor?, forKey key: Key) throws {
		if value != nil {
			try encode(value!, forKey: key)
		} else {
			try encodeNil(forKey: key)
		}
	}
}

extension KeyedDecodingContainer {
	func decode(_ type: UIColor.Type, forKey key: Key) throws -> UIColor {
		let web = try decode(String.self, forKey: key)
		return UIColor(web: web)
	}
	
	func decodeIfPresent(_ type: UIColor.Type, forKey key: Key) throws -> UIColor? {
		if try decodeNil(forKey: key) {
			return nil
		} else {
			return try decode(type, forKey: key)
		}
	}
}
