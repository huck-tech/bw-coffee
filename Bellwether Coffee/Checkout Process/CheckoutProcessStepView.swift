//
//  CheckoutProcessStepView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutProcessStepViewDelegate: class {
    func checkoutProcessDidSelectStep(stepIndex: Int)
}

class CheckoutProcessStepView: View {
    
    weak var stepDelegate: CheckoutProcessStepViewDelegate?
    
    lazy var header: CheckoutProcessStepHeaderView = {
        let headerView = CheckoutProcessStepHeaderView(frame: .zero)
        headerView.actionButton.addTarget(self, action: #selector(selectHeader), for: .touchUpInside)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    var step: Int = 0
    var stepTitle: String? {
        didSet { header.title.text = stepTitle }
    }
    
    override func setupViews() {
        backgroundColor = .white
        
        addSubview(header)
        header.addAnchors(anchors: [.top: topAnchor, .left: leftAnchor, .right: rightAnchor])
    }
    
    override func layoutSubviews() {
        
    }
    
    func alignBottom(toView view: UIView, offset: CGFloat = 0.0) {
        addAnchors(anchors: [.bottom: view.bottomAnchor], constant: offset)
    }
    
    @objc func selectHeader() {
        stepDelegate?.checkoutProcessDidSelectStep(stepIndex: step)
    }
    
}
