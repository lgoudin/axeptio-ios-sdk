//
//  StringExtensions.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 04/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

extension String {
	func HTMLAttributedString(defaultFont: UIFont, defaultTextColor: UIColor) -> NSAttributedString? {
		let string = """
		<style>
			body, div
			{
				font-family: '\(defaultFont.familyName == UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName ? "-apple-system" : defaultFont.fontName)';
				font-size: \(defaultFont.pointSize)px;
				color: \(defaultTextColor.web);
			}
		</style>
		\(self)
		"""
		guard let data = string.data(using: .utf16, allowLossyConversion: false) else {
			return nil
		}
		guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
			return nil
		}
		return attributedString
	}
}
