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
    
    func subviewWithClassName(className: String) -> UIView? {
        for subview in subviews {
//            print(subview.dynamicType.description())
            if subview.dynamicType.description() == className {
                return subview
            }
            subview.subviewWithClassName(className)
        }
        return nil
    }
    
    func subviewWithClassType(classType: AnyClass) -> UIView? {
        for subview in subviews {
            if subview.isKindOfClass(classType) {
                return subview
            }
            subview.subviewWithClassType(classType)
        }
        return nil
    }
}
