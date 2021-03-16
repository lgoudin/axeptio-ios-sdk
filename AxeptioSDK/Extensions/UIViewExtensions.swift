//
//  UIViewExtensions.swift
//  AxeptioSDK
//
//  Created by Cyril Anger on 04/03/2021.
//  Copyright © 2021 Axeptio. All rights reserved.
//

import UIKit

extension UIView {
	func insertFillingSubview(_ view: UIView, at index: Int, withInsets insets: UIEdgeInsets = .zero, relativeToSafeArea: Bool = false) {
		view.translatesAutoresizingMaskIntoConstraints = false
		insertSubview(view, at: index)
		if relativeToSafeArea {
			addConstraint(view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: insets.left))
			addConstraint(view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right))
			addConstraint(view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: insets.top))
			addConstraint(view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom))
		} else {
			addConstraint(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left))
			addConstraint(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right))
			addConstraint(view.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top))
			addConstraint(view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom))
		}
	}
	
	func addFillingSubview(_ view: UIView, withInsets insets: UIEdgeInsets = .zero, relativeToSafeArea: Bool = false) {
		insertFillingSubview(view, at: self.subviews.count, withInsets: insets, relativeToSafeArea: relativeToSafeArea)
	}
}
