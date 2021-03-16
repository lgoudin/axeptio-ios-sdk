//
//  CookieStepView.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 03/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

class CookieStepView: UIView, CardView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
	
	private func setup() {
		self.backgroundColor = Axeptio.shared.widgetColor
		self.layer.cornerRadius = Axeptio.shared.cornerRadius
		self.layer.shadowOpacity = 0.16
		self.layer.shadowOffset = CGSize(width: 0, height: 3)
		self.layer.shadowRadius = 20
		
		// Background image
		self.backgroundImageView.image = UIImage(named: "HalfCircle", in: Bundle(for: Self.self), compatibleWith: nil)
		self.backgroundImageView.tintColor = Axeptio.shared.mainColor
		self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(self.backgroundImageView)
		addConstraint(self.backgroundImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor))
		addConstraint(self.backgroundImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor))
		addConstraint(self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor))
		addConstraint(self.backgroundImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor))
		
		// Clip view
		let clipView = UIView()
		clipView.clipsToBounds = true
		addFillingSubview(clipView)
		
		// Main stack view
		self.mainStackView.axis = .vertical
		self.mainStackView.distribution = .fill
		self.mainStackView.alignment = .fill
		self.mainStackView.spacing = 8
		self.mainStackView.layoutMargins = UIEdgeInsets(top: 3, left: Axeptio.shared.padding, bottom: Axeptio.shared.padding, right: Axeptio.shared.padding)
		self.mainStackView.isLayoutMarginsRelativeArrangement = true
		self.mainStackView.translatesAutoresizingMaskIntoConstraints = false
		clipView.addSubview(self.mainStackView)
		clipView.addConstraint(self.mainStackView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor))
		clipView.addConstraint(self.mainStackView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor))
		self.mainStackViewTopConstraint = self.mainStackView.topAnchor.constraint(equalTo: clipView.topAnchor)
		clipView.addConstraint(self.mainStackViewTopConstraint)
		clipView.addConstraint(self.mainStackView.bottomAnchor.constraint(equalTo: clipView.bottomAnchor))
		
		// Image
		self.imageView.contentMode = .scaleAspectFit
		self.mainStackView.addArrangedSubview(self.imageView)
		self.mainStackView.setCustomSpacing(Axeptio.shared.padding, after: self.imageView)
		
		// Top title
		self.topTitleLabel.font = Axeptio.shared.titleFontProvider(16, .regular)
		self.topTitleLabel.textColor = Axeptio.shared.titleColor
		self.topTitleLabel.numberOfLines = 0
		self.mainStackView.addArrangedSubview(self.topTitleLabel)
		
		// Title
		self.titleLabel.font = Axeptio.shared.titleFontProvider(24, .medium)
		self.titleLabel.textColor = Axeptio.shared.titleColor
		self.titleLabel.numberOfLines = 0
		self.mainStackView.addArrangedSubview(self.titleLabel)
		
		// Sub title
		self.subTitleLabel.font = Axeptio.shared.titleFontProvider(16, .regular)
		self.subTitleLabel.textColor = Axeptio.shared.titleColor
		self.subTitleLabel.numberOfLines = 0
		self.mainStackView.addArrangedSubview(self.subTitleLabel)
		
		// Message
		self.messageLabel.font = Axeptio.shared.textFontProvider(12, .regular)
		self.messageLabel.textColor = Axeptio.shared.textColor
		self.messageLabel.numberOfLines = 0
		self.mainStackView.addArrangedSubview(self.messageLabel)
		
		// Vendors
		self.vendorsView.backgroundColor = Axeptio.shared.cardColor
		self.vendorsView.layer.cornerRadius = Axeptio.shared.cornerRadius
		self.mainStackView.addArrangedSubview(self.vendorsView)
		self.vendorsStackView.axis = .vertical
		self.vendorsStackView.distribution = .fill
		self.vendorsStackView.alignment = .fill
		self.vendorsStackView.spacing = 8
		self.vendorsView.addFillingSubview(self.vendorsStackView)
		
		// Buttons
		self.buttonsStackView.axis = .horizontal
		self.buttonsStackView.distribution = .fillEqually
		self.buttonsStackView.alignment = .fill
		self.buttonsStackView.spacing = 20
		self.mainStackView.addArrangedSubview(self.buttonsStackView)
		
		// Left button
		self.leftButtonTitleLabel.font = Axeptio.shared.textFontProvider(12, .regular)
		self.leftButtonTitleLabel.textColor = Axeptio.shared.buttonTextColor
		self.leftButtonTitleLabel.highlightedTextColor = Axeptio.shared.buttonHighlightedTextColor
		
		// Center button
		self.centerButtonTitleLabel.font = Axeptio.shared.textFontProvider(12, .regular)
		self.centerButtonTitleLabel.textColor = Axeptio.shared.buttonTextColor
		self.centerButtonTitleLabel.highlightedTextColor = Axeptio.shared.buttonHighlightedTextColor
		
		// Right button
		self.rightButtonTitleLabel.font = Axeptio.shared.textFontProvider(12, .regular)
		self.rightButtonTitleLabel.textColor = Axeptio.shared.buttonTextColor
		self.rightButtonTitleLabel.highlightedTextColor = Axeptio.shared.buttonHighlightedTextColor
		
		// Group buttons with their title labels
		for (button, titleLabel) in [(self.leftButton, self.leftButtonTitleLabel), (self.centerButton, self.centerButtonTitleLabel), (self.rightButton, self.rightButtonTitleLabel)] {
			button.bottomLabel = titleLabel
			titleLabel.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
			let stackView = UIStackView()
			stackView.axis = .vertical
			stackView.distribution = .fill
			stackView.alignment = .center
			stackView.addArrangedSubview(button)
			stackView.addArrangedSubview(titleLabel)
			self.buttonsStackView.addArrangedSubview(stackView)
		}
		
		// Pan gesture
		// Disabled for now
		//addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan)))
	}
	
	weak var deckView: DeckView?
	
	var configuration: Cookie?
	var isLastStep = false
	var step: Cookie.Step? {
		didSet {
			// Image
			self.imageView.image = UIImage(named: "Cookie", in: Bundle(for: Self.self), compatibleWith: nil)
			
			// Top title
			self.topTitleLabel.attributedText = self.step?.topTitle?.HTMLAttributedString(defaultFont: self.topTitleLabel.font, defaultTextColor: self.topTitleLabel.textColor)
			self.topTitleLabel.isHidden = self.topTitleLabel.attributedText == nil
			self.mainStackView.setCustomSpacing(3, after: self.topTitleLabel)
			
			// Title
			self.titleLabel.attributedText = self.step?.title?.HTMLAttributedString(defaultFont: self.titleLabel.font, defaultTextColor: self.titleLabel.textColor)
			self.titleLabel.isHidden = self.titleLabel.attributedText == nil
			self.mainStackView.setCustomSpacing(3, after: self.titleLabel)
			
			// Sub title
			self.subTitleLabel.attributedText = self.step?.subTitle?.HTMLAttributedString(defaultFont: self.subTitleLabel.font, defaultTextColor: self.subTitleLabel.textColor)
			self.subTitleLabel.isHidden = self.subTitleLabel.attributedText == nil
			self.mainStackView.setCustomSpacing(3, after: self.subTitleLabel)
			
			// Spacing between titles and message
			if !self.subTitleLabel.isHidden {
				self.mainStackView.setCustomSpacing(UIStackView.spacingUseDefault, after: self.subTitleLabel)
			} else if !self.titleLabel.isHidden {
				self.mainStackView.setCustomSpacing(UIStackView.spacingUseDefault, after: self.titleLabel)
			} else if !self.topTitleLabel.isHidden {
				self.mainStackView.setCustomSpacing(UIStackView.spacingUseDefault, after: self.topTitleLabel)
			}
			
			// Message
			self.messageLabel.attributedText = self.step?.message?.HTMLAttributedString(defaultFont: self.messageLabel.font, defaultTextColor: self.messageLabel.textColor)
			self.messageLabel.isHidden = self.messageLabel.attributedText == nil
			
			// Vendors
			for view in self.vendorsStackView.arrangedSubviews {
				view.removeFromSuperview()
			}
			if let vendors = self.step?.vendors {
				for vendor in vendors {
					let view = CookieVendorView()
					view.vendor = vendor
					view.userConsent = Axeptio.shared.getUserConsent(forVendor: vendor.name) == true
					self.vendorsStackView.addArrangedSubview(view)
				}
			}
			self.vendorsView.isHidden = self.step?.vendors?.count ?? 0 == 0
			
			// Buttons
			switch self.step?.layout {
			case .welcome:
				// Left button
				self.leftButton.action = { [weak self] in
					self?.applyChoiceForAllCookies(false)
				}
				self.leftButton.setImage(UIImage(named: "LeftArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.leftButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
				self.leftButton.tintColor = #colorLiteral(red: 1, green: 0.1753531694, blue: 0.1439309716, alpha: 1)
				self.leftButtonTitleLabel.text = localizedString("dismiss")
				
				// Center button
				self.centerButton.action = { [weak self] in
					self?.deckView?.showNextCard()
				}
				self.centerButton.setImage(UIImage(named: "TopArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.centerButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
				self.centerButton.tintColor = #colorLiteral(red: 0.6430723071, green: 0.6431827545, blue: 0.6430577636, alpha: 1)
				self.centerButtonTitleLabel.text = localizedString("configure")
				
				// Right button
				self.rightButton.action = { [weak self] in
					self?.applyChoiceForAllCookies(true)
				}
				self.rightButton.setImage(UIImage(named: "RightArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.rightButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
				self.rightButton.tintColor = #colorLiteral(red: 0.4954230189, green: 0.746818006, blue: 0, alpha: 1)
				self.rightButtonTitleLabel.text = localizedString("acceptAll")
				
			case .category:
				// Left button
				self.leftButton.action = { [weak self] in
					self?.deckView?.showPreviousCard()
				}
				self.leftButton.setImage(UIImage(named: "BottomArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.leftButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
				self.leftButton.tintColor = #colorLiteral(red: 0.6430723071, green: 0.6431827545, blue: 0.6430577636, alpha: 1)
				self.leftButtonTitleLabel.text = localizedString("prevStep")
				
				// Center button
				self.centerButton.action = { [weak self] in
					self?.saveCurrentChoices()
					if self?.isLastStep == true {
						self?.deckView?.dismiss()
					}
				}
				self.centerButton.setImage(UIImage(named: "TopArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.centerButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
				self.centerButton.tintColor = #colorLiteral(red: 0.6430723071, green: 0.6431827545, blue: 0.6430577636, alpha: 1)
				self.centerButtonTitleLabel.text = localizedString(self.isLastStep ? "lastStep" : "nextStep")
				
				// Right button
				self.rightButton.action = { [weak self] in
					self?.toggleAllSwitches() {
						self?.saveCurrentChoices()
					}
				}
				self.rightButton.setImage(UIImage(named: "RightArrow", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
				self.rightButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
				self.rightButton.tintColor = Axeptio.shared.mainColor
				self.rightButtonTitleLabel.text = localizedString("toggleAll")
				
			default:
				self.leftButton.action = nil
				self.centerButton.action = nil
				self.rightButton.action = nil
			}
		}
	}
	
	private func localizedString(_ key: String) -> String? {
		return self.step?.strings?[key] ?? self.configuration?.strings?[key]
	}
	
	private func applyChoiceForAllCookies(_ userConsent: Bool) {
		if let vendors = self.configuration?.allVendors {
			for vendor in vendors {
				Axeptio.shared.setUserConsent(userConsent, forVendor: vendor.name)
			}
		}
		self.deckView?.dismiss()
	}
	
	private func saveCurrentChoices() {
		for view in self.vendorsStackView.arrangedSubviews {
			if let view = view as? CookieVendorView, let name = view.vendor?.name {
				if Axeptio.shared.getUserConsent(forVendor: name) != view.userConsent {
					Axeptio.shared.setUserConsent(view.userConsent, forVendor: name)
				}
			}
		}
		self.deckView?.showNextCard()
	}
	
	private func toggleAllSwitches(completionHandler: @escaping () -> Void) {
		let duration: TimeInterval = 0.3
		let delay: TimeInterval = 0.1
		var totalDelay: TimeInterval = 0
		for view in self.vendorsStackView.arrangedSubviews {
			if let view = view as? CookieVendorView, !view.userConsent {
				DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
					view.setUserConsent(true, animated: true)
				}
				totalDelay += delay
			}
		}
		if totalDelay > 0 {
			self.isUserInteractionEnabled = true
			DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + duration) { [weak self] in
				self?.isUserInteractionEnabled = true
				completionHandler()
			}
		} else {
			completionHandler()
		}
	}
	
	private let backgroundImageView = UIImageView()
	private let mainStackView = UIStackView()
	private var mainStackViewTopConstraint: NSLayoutConstraint!
	var canBeShrinked = false {
		didSet {
			self.mainStackViewTopConstraint.priority = self.canBeShrinked ? .fittingSizeLevel - 1 : .required
		}
	}
	private let imageView = UIImageView()
	private let topTitleLabel = UILabel()
	private let titleLabel = UILabel()
	private let subTitleLabel = UILabel()
	private let messageLabel = UILabel()
	private let vendorsView = UIView()
	private let vendorsStackView = UIStackView()
	private let buttonsStackView = UIStackView()
	private let leftButton = CircleButton()
	private let leftButtonTitleLabel = UILabel()
	private let centerButton = CircleButton()
	private let centerButtonTitleLabel = UILabel()
	private let rightButton = CircleButton()
	private let rightButtonTitleLabel = UILabel()
	
	@objc private func handlePan(_ sender: UIPanGestureRecognizer) {
		let translation = sender.translation(in: self.superview)
		self.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
			.rotated(by: min(max(translation.x / self.frame.width, -1), 1) * .pi / 3)
		if sender.state == .ended {
			UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
				self.transform = .identity
			})
		}
	}
}
