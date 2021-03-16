//
//  DeckView.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 02/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

private let insets = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
private let spacingBetweenCards: CGFloat = 10
private let scalingFactor: CGFloat = 0.1

protocol CardView: UIView {
	var deckView: DeckView? { get set }
	var canBeShrinked: Bool { get set }
}

class DeckView: UIView {
	var cards: [CardView] = [] {
		didSet {
			// Remove previous cards
			for card in oldValue {
				card.removeFromSuperview()
				card.deckView = nil
			}
			
			// Add new cards and set default constraints
			for (i, card) in self.cards.enumerated() {
				// Add
				card.translatesAutoresizingMaskIntoConstraints = false
				insertSubview(card, at: 0)
				addConstraint(card.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: insets.left))
				addConstraint(card.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right))
				addConstraint(card.topAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.topAnchor, constant: insets.top))
				addConstraint(card.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -(insets.bottom + CGFloat(self.cards.count - 1 - i) * spacingBetweenCards)))
				card.deckView = self
			}
			
			// Select first card
			self.selectedCard = self.cards.first
		}
	}
	
	var selectedCard: UIView? {
		didSet {
			// Align the view to the top of the selected card
			self.selectedCardConstraint = self.selectedCard?.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: insets.top)
			
			updateCards()
		}
	}
	private var selectedCardConstraint: NSLayoutConstraint? {
		didSet {
			oldValue?.isActive = false
			self.selectedCardConstraint?.isActive = true
		}
	}
	
	func showPreviousCard() {
		guard let selectedCardIndex = self.cards.firstIndex(where: { $0 == self.selectedCard }), selectedCardIndex > 0 else {
			return
		}
		UIView.animate(withDuration: 0.3) {
			self.selectedCard = self.cards[selectedCardIndex - 1]
			self.superview?.layoutIfNeeded()
		}
	}
	func showNextCard() {
		guard let selectedCardIndex = self.cards.firstIndex(where: { $0 == self.selectedCard }), selectedCardIndex < self.cards.count - 1 else {
			return
		}
		UIView.animate(withDuration: 0.3) {
			self.selectedCard = self.cards[selectedCardIndex + 1]
			self.superview?.layoutIfNeeded()
		}
	}
	
	private func updateCards() {
		// Ensure selected card belongs to our cards
		guard let selectedCardIndex = self.cards.firstIndex(where: { $0 == self.selectedCard }) else {
			for card in self.cards {
				card.canBeShrinked = false
				card.transform = .identity
				card.alpha = 1
			}
			return
		}
		
		// Update transform and mask for each card
		for (index, card) in self.cards.enumerated() {
			card.canBeShrinked = index > selectedCardIndex
			let factor = 1 + CGFloat(selectedCardIndex - index) * scalingFactor
			card.transform = CGAffineTransform(translationX: 0, y: card.bounds.height * (1 - factor) / 2).scaledBy(x: factor, y: factor)
			card.alpha = (index >= selectedCardIndex ? 1 : 0)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		updateCards()
	}
	
	var dismissHandler: (() -> Void)? = nil
	func dismiss() {
		self.dismissHandler?()
	}
}
