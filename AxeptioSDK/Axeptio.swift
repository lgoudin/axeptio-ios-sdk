//
//  Axeptio.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 01/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift

private let deviceIdKeychainKey = "Axeptio Device ID"
private let consentsKeychainKeyPrefix = "Axeptio Consents"
private let consentsUploadQueueKeychainKey = "Axeptio Consents Upload Queue"

public final class Axeptio {
	public static let shared = Axeptio()
	
	public enum Error: Swift.Error {
		case notInitialized
		case alreadyInitialized
		case invalidClientId
		case unknownVersion
		case networkFailed
		case apiFailed
	}
	
	private init() {
		// Get device ID or create a new one if needed and store it in the keychain
		let keychain = KeychainSwift()
		var deviceId = keychain.get(deviceIdKeychainKey)
		if deviceId == nil {
			deviceId = UUID().uuidString
			keychain.set(deviceId!, forKey: deviceIdKeychainKey, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
		}
		self.deviceId = deviceId!
		
		loadConsentsUploadQueue()
		processConsentsUploadQueue()
	}
	
	private let deviceId: String
	
	// MARK: - Initialization
	
	private var clientId: String?
	
	public func initialize(clientId: String, completionHandler: @escaping (Error?) -> Void) {
		guard self.configuration == nil && self.configurationTask == nil else {
			completionHandler(.alreadyInitialized)
			return
		}
		guard let url = URL(string: "https://client.axept.io/\(clientId).json") else {
			completionHandler(.invalidClientId)
			return
		}
		let completionHandler = { [weak self] (result: Result<Configuration, Error>) in
			DispatchQueue.main.async() {
				self?.configurationTask = nil
				switch result {
				case let .success(configuration):
					self?.configuration = configuration
					self?.clientId = clientId
					self?.loadConsents()
					completionHandler(nil)
					
				case let .failure(error):
					completionHandler(error)
				}
			}
		}
		self.configurationTask = URLSession.shared.dataTask(with: url) { data, response, error in
			guard data != nil else {
				completionHandler(.failure(.networkFailed))
				return
			}
			let decoder = JSONDecoder()
			do {
				let configuration = try decoder.decode(Configuration.self, from: data!)
				completionHandler(.success(configuration))
			} catch {
				#if DEBUG
				print("[Axeptio] Error while decoding configuration : \(error)")
				#endif
				completionHandler(.failure(.apiFailed))
			}
		}
		self.configurationTask!.resume()
	}
	
	// MARK: - Consents
	
	private struct Consent: Codable {
		let value: Bool
		let date: Date
	}
	private var consents: [String: Consent] = [:]
	
	private var consentsKeychainKey: String? {
		return self.clientId.map({ "\(consentsKeychainKeyPrefix) \($0)" })
	}
	
	private func loadConsents() {
		guard let key = self.consentsKeychainKey, let data = KeychainSwift().getData(key) else {
			return
		}
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		do {
			self.consents = try decoder.decode([String: Consent].self, from: data)
		} catch {
			#if DEBUG
			print("[Axeptio] Error while decoding consents : \(error)")
			#endif
		}
	}
	
	private func saveConsents() {
		guard let key = self.consentsKeychainKey else {
			return
		}
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let data = try encoder.encode(self.consents)
			KeychainSwift().set(data, forKey: key, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
		} catch {
			#if DEBUG
			print("[Axeptio] Error while encoding consents : \(error)")
			#endif
		}
	}
	
	public func getUserConsent(forVendor name: String) -> Bool? {
		return self.consents[name]?.value
	}
	
	func setUserConsent(_ value: Bool, forVendor name: String) {
		self.consents[name] = Consent(value: value, date: Date())
	}
	
	public func clearUserConsents() {
		self.consents.removeAll()
		saveConsents()
	}
	
	private var consentsUploadQueue: [CreateConsentFullRequest] = [] {
		didSet {
			saveConsentsUploadQueue()
		}
	}
	
	private func loadConsentsUploadQueue() {
		guard let data = KeychainSwift().getData(consentsUploadQueueKeychainKey) else {
			return
		}
		let decoder = JSONDecoder()
		do {
			self.consentsUploadQueue = try decoder.decode([CreateConsentFullRequest].self, from: data)
		} catch {
			#if DEBUG
			print("[Axeptio] Error while decoding consents upload queue : \(error)")
			#endif
		}
	}
	
	private func saveConsentsUploadQueue() {
		let encoder = JSONEncoder()
		do {
			let data = try encoder.encode(self.consentsUploadQueue)
			KeychainSwift().set(data, forKey: consentsUploadQueueKeychainKey, withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
		} catch {
			#if DEBUG
			print("[Axeptio] Error while encoding consents upload queue : \(error)")
			#endif
		}
	}
	
	private func processConsentsUploadQueue() {
		guard let request = self.consentsUploadQueue.first else {
			return
		}
		AF.request(request.url, method: .post, parameters: request.body, encoder: JSONParameterEncoder.default)
			.validate()
			.responseDecodable(of: CreateConsentResponse.self) { response in
				switch response.result {
				case let .success(response):
					#if DEBUG
					print("[Axeptio] Uploaded consents : \(response)")
					#endif
					self.consentsUploadQueue.removeFirst()
					self.processConsentsUploadQueue()
					
				case let .failure(error):
					#if DEBUG
					print("[Axeptio] Error while uploading consents : \(error)")
					if let url = response.request?.url {
						print("URL : \(url)")
					}
					if let data = response.request?.httpBody, let string = String(data: data, encoding: .utf8) {
						print("REQUEST\n\(string)")
					}
					if let statusCode = response.response?.statusCode {
						print("STATUS CODE : \(statusCode)")
					}
					if let data = response.data, let string = String(data: data, encoding: .utf8) {
						print("RESPONSE\n\(string)")
					}
					#endif
					
					// Send the request at the end of the queue and try again after a delay
					if self.consentsUploadQueue.count > 1 {
						self.consentsUploadQueue.append(self.consentsUploadQueue.removeFirst())
					}
					DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
						self?.processConsentsUploadQueue()
					}
				}
			}
	}
	
	// MARK: - Configuration
	
	private var configuration: Configuration? {
		didSet {
			self.mainColor = self.configuration?.client.colors.main ?? .black
			self.secondaryColor = self.configuration?.client.colors.secondary ?? .black
			self.tertiaryColor = self.configuration?.client.colors.tertiary ?? .black
			self.dangerColor = self.configuration?.client.colors.danger ?? .black
			self.textColor = self.configuration?.client.colors.text ?? .black
			self.titleColor = self.configuration?.client.colors.title ?? .black
			self.cardColor = self.configuration?.client.colors.card ?? .white
			self.widgetColor = self.configuration?.client.colors.widget ?? .white
			self.toggleOffColor = self.configuration?.client.colors.toggleOff ?? .gray
			self.buttonTextColor = self.configuration?.client.colors.buttonText ?? .black
			self.buttonHighlightedTextColor = self.configuration?.client.colors.buttonHighlightedText ?? .black
			self.buttonBorderColor = self.configuration?.client.colors.buttonBorder ?? .black
			self.buttonBackgroundColor = self.configuration?.client.colors.buttonBackground ?? .white
			self.buttonHighlightedBackgroundColor = self.configuration?.client.colors.buttonHighlightedBackground ?? .white
			self.primaryButtonTextColor = self.configuration?.client.colors.primaryButtonText ?? .black
			self.primaryButtonHighlightedTextColor = self.configuration?.client.colors.primaryButtonHighlightedText ?? .black
			self.primaryButtonBorderColor = self.buttonBorderColor
			self.primaryButtonBackgroundColor = self.configuration?.client.colors.primaryButtonBackground ?? .white
			self.primaryButtonHighlightedBackgroundColor = self.configuration?.client.colors.primaryButtonHighlightedBackground ?? .white
			self.titleFontProvider = self.configuration?.client.fonts.title.fontProvider ?? UIFont.systemFont
			self.textFontProvider = self.configuration?.client.fonts.text.fontProvider ?? UIFont.systemFont
			self.cornerRadius = self.configuration?.client.widgetStyle.borderRadius ?? 8
			self.padding = self.configuration?.client.widgetStyle.padding ?? 20
		}
	}
	private var configurationTask: URLSessionTask?
	
	private(set) var mainColor = UIColor.black
	private(set) var secondaryColor = UIColor.black
	private(set) var tertiaryColor = UIColor.black
	private(set) var dangerColor = UIColor.black
	private(set) var textColor = UIColor.black
	private(set) var titleColor = UIColor.black
	private(set) var cardColor = UIColor.white
	private(set) var widgetColor = UIColor.white
	private(set) var toggleOffColor = UIColor.gray
	private(set) var buttonTextColor = UIColor.black
	private(set) var buttonHighlightedTextColor = UIColor.black
	private(set) var buttonBorderColor = UIColor.black
	private(set) var buttonBackgroundColor = UIColor.white
	private(set) var buttonHighlightedBackgroundColor = UIColor.white
	private(set) var primaryButtonTextColor = UIColor.black
	private(set) var primaryButtonHighlightedTextColor = UIColor.black
	private(set) var primaryButtonBorderColor = UIColor.black
	private(set) var primaryButtonBackgroundColor = UIColor.white
	private(set) var primaryButtonHighlightedBackgroundColor = UIColor.white
	private(set) var titleFontProvider: (CGFloat, UIFont.Weight) -> UIFont = UIFont.systemFont
	private(set) var textFontProvider: (CGFloat, UIFont.Weight) -> UIFont = UIFont.systemFont
	private(set) var cornerRadius: CGFloat = 8
	private(set) var padding: CGFloat = 20
	
	// MARK: - Cookies
	
	@discardableResult
	public func showCookiesController(version: String, onlyFirstTime: Bool = true, in viewController: UIViewController, animated: Bool = true, completionHandler: @escaping (Error?) -> Void) -> (() -> Void)? {
		guard self.configuration != nil else {
			completionHandler(.notInitialized)
			return nil
		}
		guard let configuration = self.configuration!.cookies.first(where: { $0.identifier == version || $0.name == version }) else {
			completionHandler(.unknownVersion)
			return nil
		}
		
		// Check if the user already answered for all vendors
		let vendorNames = Set(configuration.allVendors.map(\.name))
		guard !onlyFirstTime || !vendorNames.isSubset(of: self.consents.keys) else {
			completionHandler(nil)
			return nil
		}
		
		// Create main view
		let deckView = DeckView()
		deckView.cards = configuration.steps.enumerated().map({ i, step in
			let view = CookieStepView()
			view.configuration = configuration
			view.isLastStep = i == configuration.steps.count - 1
			view.step = step
			return view
		})
		
		// Add to view controller
		deckView.translatesAutoresizingMaskIntoConstraints = false
		viewController.view.addSubview(deckView)
		viewController.view.addConstraint(deckView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor))
		viewController.view.addConstraint(deckView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor))
		viewController.view.addConstraint(deckView.topAnchor.constraint(greaterThanOrEqualTo: viewController.view.topAnchor))
		let visibleConstraint = deckView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
		let hiddenConstraint = deckView.topAnchor.constraint(equalTo: viewController.view.bottomAnchor)
		
		// Set dismiss handler
		let dismissHandler = { [weak viewController, weak deckView] in
			UIView.animate(withDuration: 0.3) {
				visibleConstraint.isActive = false
				hiddenConstraint.isActive = true
				viewController?.view.layoutIfNeeded()
			} completion: { _ in
				deckView?.removeFromSuperview()
			}
		}
		deckView.dismissHandler = {
			// Save consents
			self.saveConsents()
			
			// Send to server
			if configuration.withSaveConsent == true, let url = URL(string: "https://api.axept.io/v1/app/consents/\(configuration.projectId)/cookies/\(configuration.identifier)") {
				var vendors: [String: Bool] = [:]
				for name in vendorNames {
					vendors[name] = self.consents[name]?.value
				}
				let config = Preferences.Config(identifier: configuration.identifier, name: configuration.name, language: configuration.language)
				let request = CreateConsentRequest(accept: vendors.allSatisfy({ $1 }), preferences: Preferences(vendors: vendors, config: config), token: self.deviceId)
				self.consentsUploadQueue.append(CreateConsentFullRequest(url: url, body: request))
				if self.consentsUploadQueue.count == 1 {
					self.processConsentsUploadQueue()
				}
			}
			
			// Hide view
			dismissHandler()
		}
		
		// Animate if needed
		if animated {
			hiddenConstraint.isActive = true
			viewController.view.layoutIfNeeded()
			UIView.animate(withDuration: 0.3) {
				hiddenConstraint.isActive = false
				visibleConstraint.isActive = true
				viewController.view.layoutIfNeeded()
			}
		} else {
			visibleConstraint.isActive = true
		}
		
		return dismissHandler
	}
}
