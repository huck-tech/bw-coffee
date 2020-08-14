//
//  CheckoutProcessScrollView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutProcessScrollView: View, CheckoutProcessStepViewDelegate {
    
    var stepViews = [CheckoutProcessStepView]() {
        didSet { updateStepViews() }
    }
    
    var accessoryViews = [CheckoutProcessAccessoryView]()
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var stepContainerViews = [UIView]()
    var accessoryContainerViews = [UIView]()
    
    var activeStep: Int = 0
    var inactiveHeight: CGFloat = CheckoutProcessStepHeaderView.headerHeight
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    func setupLayout() {
        addSubview(scrollView)
        scrollView.anchorIn(view: self)
    }
    
    func updateStepViews() {
        layoutSteps()
    }
    
    func checkoutProcessDidSelectStep(stepIndex: Int) {
        expand(step: stepIndex, animated: true)
    }
    
    func refreshData() {
        expand(step: 0)
    }
    
}

// MARK: Step Configuration

extension CheckoutProcessScrollView {
    
    func layoutSteps() {
        calculateLayout()
        
        stepViews.forEach { stepView in
            stepView.stepDelegate = nil
            stepView.removeFromSuperview()
        }
        
        accessoryViews.forEach { accessoryView in
            accessoryView.removeFromSuperview()
        }
        
        stepContainerViews.forEach { $0.removeFromSuperview() }
        stepContainerViews.removeAll()
        
        accessoryContainerViews.forEach { $0.removeFromSuperview() }
        accessoryContainerViews.removeAll()
        
        stepViews.enumerated().forEach { index, stepView in
            stepView.stepDelegate = self
            stepView.step = index
            
            let container = UIView(frame: .zero)
            container.clipsToBounds = true
            scrollView.addSubview(container)
            
            container.addSubview(stepView)
            stepView.translatesAutoresizingMaskIntoConstraints = false
            
            stepView.addAnchors(anchors: [
                .top: container.topAnchor,
                .left: container.leftAnchor,
                .right: container.rightAnchor
            ])

            stepContainerViews.append(container)
        }
        
        accessoryViews.forEach { accessoryView in
            let container = UIView(frame: .zero)
            container.clipsToBounds = true
            scrollView.addSubview(container)
            
            container.addSubview(accessoryView)
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            
            accessoryView.addAnchors(anchors: [
                .top: container.topAnchor,
                .left: container.leftAnchor,
                .right: container.rightAnchor
            ])
            
            accessoryContainerViews.append(container)
        }
        
        expand(step: activeStep)
    }
    
    override func layoutSubviews() {
        expand(step: activeStep)
    }
    
    func performUIUpdates(updates: (() -> Void)? = nil) {
        updates?()
        
        let step = activeStep
        
        Speedy.main.executeAfterUIUpdate { [weak self] in
            self?.expand(step: step)
        }
    }
    
    func proceed(animated: Bool) {
        guard activeStep < stepViews.count - 1 else { return }
        expand(step: activeStep + 1, animated: animated)
    }
    
    func expand(step: Int, animated: Bool = false) {
        activeStep = step
        
        let calculatedAttributes = calculateAttributes()
        let containerAttributes = calculatedAttributes.containers
        let accessoryAttributes = calculatedAttributes.accessories
        
        let translation = { [unowned self] in
            self.stepContainerViews.enumerated().forEach { index, container in
                let attribute = containerAttributes[index]
                container.frame = attribute.frame
                container.alpha = attribute.alpha
            }
            
            self.accessoryContainerViews.enumerated().forEach { index, container in
                let attribute = accessoryAttributes[index]
                container.frame = attribute.frame
            }
        }
        
        let scrollHeight = stepContainerViews.last?.frame.maxY ?? 0
        scrollView.contentSize = CGSize(width: bounds.width, height: scrollHeight)
        
        guard animated else { return translation() }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.0,
                       options: .allowUserInteraction,
                       animations: translation)
    }
    
}

// MARK: Calculations

struct ContainerAttribute {
    let frame: CGRect
    let alpha: CGFloat
}

struct AccessoryAttribute {
    let frame: CGRect
}

extension CheckoutProcessScrollView {
    
    func calculateAttributes() -> (containers: [ContainerAttribute], accessories: [AccessoryAttribute]) {
        var containerAttributes = [ContainerAttribute]()
        var accessoryAttributes = [AccessoryAttribute]()
        
        var positionY = CGFloat(0.0)
        
        let headers = accessoryViews.filter { accessoryView -> Bool in
            return accessoryView.type == .header
        }
        
        let footers = accessoryViews.filter { accessoryView -> Bool in
            return accessoryView.type == .footer
        }
        
        let nones = accessoryViews.filter { accessoryView -> Bool in
            return accessoryView.type == .none
        }
        
        headers.forEach { header in
            let frame = CGRect(x: 0, y: positionY, width: bounds.width, height: header.bounds.height)
            
            let attribute = AccessoryAttribute(frame: frame)
            accessoryAttributes.append(attribute)
            
            positionY = frame.maxY
        }
        
        stepViews.enumerated().forEach { index, step in
            let isActive = index == activeStep
            let height = isActive ? step.bounds.height : inactiveHeight
            
            let frame = CGRect(x: 0, y: positionY, width: bounds.width, height: height)
            let alpha: CGFloat = isActive ? 1.0 : 0.5
            
            let attribute = ContainerAttribute(frame: frame, alpha: alpha)
            containerAttributes.append(attribute)
            
            positionY = frame.maxY
        }
        
        footers.forEach { footer in
            let frame = CGRect(x: 0, y: positionY, width: bounds.width, height: footer.bounds.height)
            
            let attribute = AccessoryAttribute(frame: frame)
            accessoryAttributes.append(attribute)
            
            positionY = frame.maxY
        }
        
        nones.forEach { none in
            let attribute = AccessoryAttribute(frame: .zero)
            accessoryAttributes.append(attribute)
        }
        
        return (containerAttributes, accessoryAttributes)
    }
    
}
