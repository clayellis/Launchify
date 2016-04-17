//
//  UIViewExtensions.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// MARK: - UIView Extension
extension UIView {
    func setTranslatesAutoresizingMaskIntoConstraintsToFalse(views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func fillSuperview() {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activateConstraints([
            leftAnchor.constraintEqualToAnchor(superview.leftAnchor),
            rightAnchor.constraintEqualToAnchor(superview.rightAnchor),
            topAnchor.constraintEqualToAnchor(superview.topAnchor),
            bottomAnchor.constraintEqualToAnchor(superview.bottomAnchor)
            ])
    }
}
