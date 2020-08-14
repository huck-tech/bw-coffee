//
//  ViewLayout.swift
//  LayoutEngine
//
//  Created by Gabriel Pierannunzi on 2/16/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import UIKit

enum LayoutAnchor {
    case top
    case left
    case right
    case bottom
    
    case width
    case height
    
    case centerX
    case centerY
}

// MARK: Manage Anchors

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }
    
    func addAnchors(anchors: [LayoutAnchor: Any], constant: CGFloat = 0.0, insetConstant: CGFloat? = nil) {
        anchors.forEach { anchor, value in
            let constant = insetConstant ?? constant
            let constraint = determineAnchorConstraint(layoutAnchor: anchor, value: value, constant: constant)
            constraint?.isActive = true
        }
    }
    
    func addAnchor(anchor: LayoutAnchor, value: Any, constant: CGFloat = 0.0, insetConstant: CGFloat? = nil) -> NSLayoutConstraint? {
        let constant = insetConstant ?? constant
        let constraint = determineAnchorConstraint(layoutAnchor: anchor, value: value, constant: constant)
        constraint?.isActive = true
        
        return constraint
    }
    
}

// MARK: Templates

extension UIView {
    
    func anchorIn(view: UIView) {
        addAnchors(anchors: [.top: view.topAnchor, .left: view.leftAnchor, .right: view.rightAnchor, .bottom: view.bottomAnchor])
    }
    
    func centerIn(view: UIView) {
        addAnchors(anchors: [.centerX: view.centerXAnchor, .centerY: view.centerYAnchor])
    }
    
    func anchorSize(view: UIView) {
        addAnchors(anchors: [.width: view.widthAnchor, .height: view.heightAnchor])
    }
    
}

// MARK: Mapping

extension UIView {
    
    func determineAnchorConstraint(layoutAnchor: LayoutAnchor, value: Any, constant: CGFloat = 0) -> NSLayoutConstraint? {
        if layoutAnchor == .top {
            return getYAxisConstraint(layoutAnchor: layoutAnchor, anchor: topAnchor, anchorValue: value, constant: constant)
        }
        
        if layoutAnchor == .left {
            return getXAxisConstraint(layoutAnchor: layoutAnchor, anchor: leftAnchor, anchorValue: value, constant: constant)
        }
        
        if layoutAnchor == .right {
            return getXAxisConstraint(layoutAnchor: layoutAnchor, anchor: rightAnchor, anchorValue: value, constant: constant)
        }
        
        if layoutAnchor == .bottom {
            return getYAxisConstraint(layoutAnchor: layoutAnchor, anchor: bottomAnchor, anchorValue: value, constant: constant)
        }
        
        if layoutAnchor == .width {
            return getDimensionConstraint(layoutAnchor: layoutAnchor, anchor: widthAnchor, anchorValue: value)
        }
        
        if layoutAnchor == .height {
            return getDimensionConstraint(layoutAnchor: layoutAnchor, anchor: heightAnchor, anchorValue: value)
        }
        
        if layoutAnchor == .centerX {
            return getXAxisConstraint(layoutAnchor: layoutAnchor, anchor: centerXAnchor, anchorValue: value, constant: constant)
        }
        
        if layoutAnchor == .centerY {
            return getYAxisConstraint(layoutAnchor: layoutAnchor, anchor: centerYAnchor, anchorValue: value, constant: constant)
        }
        
        return nil
    }
    
}

// MARK: Axis Constraints

extension UIView {
    
    func getXAxisConstraint(layoutAnchor: LayoutAnchor, anchor: NSLayoutXAxisAnchor, anchorValue: Any, constant: CGFloat = 0) -> NSLayoutConstraint? {
        guard let anchoredValue = anchorValue as? NSLayoutXAxisAnchor else { return nil }
        
        let constraint = anchor.constraint(equalTo: anchoredValue, constant: constant)
        return constraint
    }
    
    func getYAxisConstraint(layoutAnchor: LayoutAnchor, anchor: NSLayoutYAxisAnchor, anchorValue: Any, constant: CGFloat = 0) -> NSLayoutConstraint? {
        guard let anchoredValue = anchorValue as? NSLayoutYAxisAnchor else { return nil }
        
        let constraint = anchor.constraint(equalTo: anchoredValue, constant: constant)
        return constraint
    }
    
}

// MARK: Dimension Constraints

extension UIView {
    
    func getDimensionConstraint(layoutAnchor: LayoutAnchor, anchor: NSLayoutDimension, anchorValue: Any) -> NSLayoutConstraint? {
        if let anchoredValue = anchorValue as? CGFloat {
            let constraint = anchor.constraint(equalToConstant: anchoredValue)
            return constraint
        }
        
        if let anchoredValue = anchorValue as? NSLayoutDimension {
            let constraint = anchor.constraint(equalTo: anchoredValue)
            return constraint
        }
        
        return nil
    }
    
}

// MARK: Helpers

extension UIView {
    
    func calculateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
