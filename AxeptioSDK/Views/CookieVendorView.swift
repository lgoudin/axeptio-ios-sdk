//
//  CookieVendorView.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 06/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit
import SafariServices
import Kingfisher

class CookieVendorView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		// Main stack view
		self.mainStackView.axis = .horizontal
		self.mainStackView.distribution = .fill
		self.mainStackView.alignment = .center
		self.mainStackView.spacing = 8
		addFillingSubview(self.mainStackView)
		
		// Image
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.addConstraint(self.imageView.widthAnchor.constraint(equalToConstant: 24))
		self.imageView.addConstraint(self.imageView.heightAnchor.constraint(equalToConstant: 24))
		self.mainStackView.addArrangedSubview(self.imageView)
		
		// Content
		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.distribution = .fill
		contentStackView.alignment = .fill
		contentStackView.spacing = 3
		self.mainStackView.addArrangedSubview(contentStackView)
		
		// Title
		self.titleLabel.font = Axeptio.shared.titleFontProvider(10, .medium)
		self.titleLabel.textColor = Axeptio.shared.titleColor
		self.titleLabel.numberOfLines = 0
		self.titleLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
		contentStackView.addArrangedSubview(self.titleLabel)
		
		// Short description
		self.shortDescriptionLabel.font = Axeptio.shared.titleFontProvider(9, .regular)
		self.shortDescriptionLabel.textColor = Axeptio.shared.textColor
		self.shortDescriptionLabel.numberOfLines = 0
		self.shortDescriptionLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
		let shortDescriptionLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toggleDescription))
		shortDescriptionLabelGestureRecognizer.numberOfTapsRequired = 1
		self.shortDescriptionLabel.addGestureRecognizer(shortDescriptionLabelGestureRecognizer)
		self.shortDescriptionLabel.isUserInteractionEnabled = true
		contentStackView.addArrangedSubview(self.shortDescriptionLabel)
		
		// Long description
		self.longDescriptionLabel.font = Axeptio.shared.titleFontProvider(9, .regular)
		self.longDescriptionLabel.textColor = Axeptio.shared.textColor
		self.longDescriptionLabel.numberOfLines = 0
		self.longDescriptionLabel.setContentCompressionResistancePriority(.defaultHigh - 1, for: .horizontal)
		let longDescriptionLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toggleDescription))
		longDescriptionLabelGestureRecognizer.numberOfTapsRequired = 1
		self.longDescriptionLabel.addGestureRecognizer(longDescriptionLabelGestureRecognizer)
		self.longDescriptionLabel.isUserInteractionEnabled = true
		contentStackView.addArrangedSubview(self.longDescriptionLabel)
		
		// Switch
		self.switch.tintColor = Axeptio.shared.toggleOffColor
		self.switch.onTintColor = Axeptio.shared.mainColor
		self.mainStackView.addArrangedSubview(self.switch)
		
		if #available(iOS 13.0, *) {
			addInteraction(UIContextMenuInteraction(delegate: self))
		}
	}
	
	var vendor: Cookie.Step.Vendor? {
		didSet {
			// Image
			if let domain = self.vendor?.domain {
				var components = URLComponents()
				components.scheme = "https"
				components.host = "www.google.com"
				components.path = "/s2/favicons"
				components.queryItems = [URLQueryItem(name: "domain", value: domain)]
				self.imageView.kf.setImage(with: components.url)
			} else {
				self.imageView.image = nil
			}
			
			// Title
			self.titleLabel.attributedText = self.vendor?.title?.HTMLAttributedString(defaultFont: self.titleLabel.font, defaultTextColor: self.titleLabel.textColor)
			self.titleLabel.isHidden = self.titleLabel.attributedText == nil
			
			// Short description
			self.shortDescriptionLabel.attributedText = self.vendor?.shortDescription?.HTMLAttributedString(defaultFont: self.shortDescriptionLabel.font, defaultTextColor: self.shortDescriptionLabel.textColor)
			self.shortDescriptionLabel.isHidden = self.shortDescriptionLabel.attributedText == nil
			
			// Long description
			self.longDescriptionLabel.attributedText = self.vendor?.longDescription?.HTMLAttributedString(defaultFont: self.longDescriptionLabel.font, defaultTextColor: self.longDescriptionLabel.textColor)
			self.longDescriptionLabel.isHidden = self.longDescriptionLabel.attributedText == nil || !self.shortDescriptionLabel.isHidden
		}
	}
	
	var userConsent: Bool {
		get {
			return self.switch.isOn
		}
		set {
			self.switch.isOn = newValue
		}
	}
	func setUserConsent(_ userConsent: Bool, animated: Bool) {
		self.switch.setOn(userConsent, animated: animated)
	}
	
	private let mainStackView = UIStackView()
	private let imageView = UIImageView()
	private let titleLabel = UILabel()
	private let shortDescriptionLabel = UILabel()
	private let longDescriptionLabel = UILabel()
	private let `switch` = UISwitch()
	
	@objc private func toggleDescription(_ sender: UIGestureRecognizer) {
		guard sender.state == .ended else {
			return
		}
		var revealedLabel: UILabel?
		switch sender.view {
		case self.shortDescriptionLabel: revealedLabel = self.longDescriptionLabel
		case self.longDescriptionLabel: revealedLabel = self.shortDescriptionLabel
		default: break
		}
		if revealedLabel?.attributedText != nil {
			UIView.animate(withDuration: 0.3) {
				sender.view?.isHidden = true
				revealedLabel!.isHidden = false
				self.layoutIfNeeded()
			}
		}
	}
}

@available(iOS 13.0, *)
extension CookieVendorView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard let url = self.vendor?.policyUrl else {
			return nil
		}
		return UIContextMenuConfiguration(identifier: url as NSURL, previewProvider: {
			return SFSafariViewController(url: url)
		}, actionProvider: nil)
	}
	
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let url = configuration.identifier as? URL else {
			return
		}
		UIApplication.shared.open(url)
	}
}
