//
//  CreateConsent.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 01/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import Foundation

struct CreateConsentFullRequest: Codable {
	let url: URL
	let body: CreateConsentRequest
}

struct CreateConsentRequest: Codable {
	let accept: Bool
	let preferences: Preferences
	let token: String
}

struct CreateConsentResponse: Codable {
	let consentId: String
	let projectId: String
	let createdAt: Date
	let accept: Bool
	enum Collection: String, Codable {
		case cookies
	}
	let collection: Collection
	let identifier: String
	let token: String
	let preferences: Preferences
}

struct Preferences: Codable {
	let vendors: [String: Bool]
	struct Config: Codable {
		let identifier: String
		let name: String
		let language: String?
	}
	let config: Config
}
