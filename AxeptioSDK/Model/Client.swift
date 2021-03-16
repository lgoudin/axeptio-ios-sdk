//
//  Client.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 06/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

struct Client: Codable {
	struct Colors: Codable {
		let main: UIColor?
		struct PaintTransform: Codable {
			let hue: Int
			let saturation: Int
			let brightness: Int
			
			private enum CodingKeys: String, CodingKey {
				case hue
				case saturation = "sat"
				case brightness = "bri"
			}
		}
		let paintTransform: PaintTransform?
		let secondary: UIColor?
		let tertiary: UIColor?
		let danger: UIColor?
		let text: UIColor?
		let title: UIColor?
		let card: UIColor?
		let widget: UIColor?
		let toggleOff: UIColor?
		let buttonText: UIColor?
		let buttonHighlightedText: UIColor?
		let buttonBorder: UIColor?
		let buttonBackground: UIColor?
		let buttonHighlightedBackground: UIColor?
		let primaryButtonText: UIColor?
		let primaryButtonHighlightedText: UIColor?
		let primaryButtonBackground: UIColor?
		let primaryButtonHighlightedBackground: UIColor?
		
		private enum CodingKeys: String, CodingKey {
			case main
			case paintTransform
			case secondary
			case tertiary
			case danger
			case text
			case title
			case card
			case widget
			case toggleOff = "toggle_off"
			case buttonText = "button_text"
			case buttonHighlightedText = "button_text_hover"
			case buttonBorder = "button_border"
			case buttonBackground = "button_bg"
			case buttonHighlightedBackground = "button_bg_hover"
			case primaryButtonText = "primary_button_text"
			case primaryButtonHighlightedText = "primary_button_text_hover"
			case primaryButtonBackground = "primary_button_bg"
			case primaryButtonHighlightedBackground = "primary_button_bg_hover"
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.main = try container.decodeIfPresent(UIColor.self, forKey: .main)
			self.paintTransform = try container.decodeIfPresent(PaintTransform.self, forKey: .paintTransform)
			self.secondary = try container.decodeIfPresent(UIColor.self, forKey: .secondary)
			self.tertiary = try container.decodeIfPresent(UIColor.self, forKey: .tertiary)
			self.danger = try container.decodeIfPresent(UIColor.self, forKey: .danger)
			self.text = try container.decodeIfPresent(UIColor.self, forKey: .text)
			self.title = try container.decodeIfPresent(UIColor.self, forKey: .title)
			self.card = try container.decodeIfPresent(UIColor.self, forKey: .card)
			self.widget = try container.decodeIfPresent(UIColor.self, forKey: .widget)
			self.toggleOff = try container.decodeIfPresent(UIColor.self, forKey: .toggleOff)
			self.buttonText = try container.decodeIfPresent(UIColor.self, forKey: .buttonText)
			self.buttonHighlightedText = try container.decodeIfPresent(UIColor.self, forKey: .buttonHighlightedText)
			self.buttonBorder = try container.decodeIfPresent(UIColor.self, forKey: .buttonBorder)
			self.buttonBackground = try container.decodeIfPresent(UIColor.self, forKey: .buttonBackground)
			self.buttonHighlightedBackground = try container.decodeIfPresent(UIColor.self, forKey: .buttonHighlightedBackground)
			self.primaryButtonText = try container.decodeIfPresent(UIColor.self, forKey: .primaryButtonText)
			self.primaryButtonHighlightedText = try container.decodeIfPresent(UIColor.self, forKey: .primaryButtonHighlightedText)
			self.primaryButtonBackground = try container.decodeIfPresent(UIColor.self, forKey: .primaryButtonBackground)
			self.primaryButtonHighlightedBackground = try container.decodeIfPresent(UIColor.self, forKey: .primaryButtonHighlightedBackground)
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encodeIfPresent(self.main, forKey: .main)
			try container.encodeIfPresent(self.paintTransform, forKey: .paintTransform)
			try container.encodeIfPresent(self.secondary, forKey: .secondary)
			try container.encodeIfPresent(self.tertiary, forKey: .tertiary)
			try container.encodeIfPresent(self.danger, forKey: .danger)
			try container.encodeIfPresent(self.text, forKey: .text)
			try container.encodeIfPresent(self.title, forKey: .title)
			try container.encodeIfPresent(self.card, forKey: .card)
			try container.encodeIfPresent(self.widget, forKey: .widget)
			try container.encodeIfPresent(self.toggleOff, forKey: .toggleOff)
			try container.encodeIfPresent(self.buttonText, forKey: .buttonText)
			try container.encodeIfPresent(self.buttonHighlightedText, forKey: .buttonHighlightedText)
			try container.encodeIfPresent(self.buttonBorder, forKey: .buttonBorder)
			try container.encodeIfPresent(self.buttonBackground, forKey: .buttonBackground)
			try container.encodeIfPresent(self.buttonHighlightedBackground, forKey: .buttonHighlightedBackground)
			try container.encodeIfPresent(self.primaryButtonText, forKey: .primaryButtonText)
			try container.encodeIfPresent(self.primaryButtonHighlightedText, forKey: .primaryButtonHighlightedText)
			try container.encodeIfPresent(self.primaryButtonBackground, forKey: .primaryButtonBackground)
			try container.encodeIfPresent(self.primaryButtonHighlightedBackground, forKey: .primaryButtonHighlightedBackground)
		}
	}
	let colors: Colors
	struct Fonts: Codable {
		struct Font: Codable {
			let family: String?
			var fontDescriptor: UIFontDescriptor? {
				guard self.family != nil else {
					return nil
				}
				return UIFontDescriptor(fontAttributes: [.family: self.family!]).matchingFontDescriptors(withMandatoryKeys: [.family]).first
			}
			var fontProvider: (CGFloat, UIFont.Weight) -> UIFont {
				guard self.family != nil, let fontDescriptor = UIFontDescriptor(fontAttributes: [.family: self.family!]).matchingFontDescriptors(withMandatoryKeys: [.family]).first else {
					return UIFont.systemFont
				}
				return { size, weight in
					return UIFont(descriptor: fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]]), size: size)
				}
			}
		}
		let title: Font
		let text: Font
	}
	let fonts: Fonts
	struct WidgetStyle: Codable {
		let borderRadius: CGFloat
		let padding: CGFloat
	}
	let widgetStyle: WidgetStyle
}
