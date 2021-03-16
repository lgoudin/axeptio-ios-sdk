//
//  Cookie.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 01/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import Foundation

struct Cookie: Codable {
	let projectId: String
	let identifier: String
	let name: String
	struct Step: Codable {
		let name: String
		enum Layout: String, Codable {
			case welcome, category, info
		}
		let layout: Layout
		let image: String?
		let topTitle: String?
		let title: String?
		let subTitle: String?
		let message: String?
		let strings: [String: String]?
		struct Vendor: Codable {
			let name: String
			let domain: String
			let title: String?
			let shortDescription: String?
			let longDescription: String?
			let policyUrl: URL?
		}
		let vendors: [Vendor]?
		let showToggleAllSwitch: Bool?
		let allowOptOut: Bool?
	}
	let steps: [Step]
	var allVendors: [Step.Vendor] {
		return Array(self.steps.compactMap(\.vendors).joined())
	}
	let language: String?
	let strings: [String: String]?
	let withSaveConsent: Bool?
}
