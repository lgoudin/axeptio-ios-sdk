//
//  Configuration.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 01/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import Foundation

struct Configuration: Codable {
	let publishedAt: String
	let client: Client
	let cookies: [Cookie]
}
