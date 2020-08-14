//
//  NecessaryNotificationView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/10/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

struct NecessaryNotification {
    let title: String?
    let subtitle: String?
}

class NecessaryNotificationView: ComponentView {
    
    var notification: NecessaryNotification? {
        didSet { updateNotification() }
    }
    
    var content: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 24)
        label.textColor = UIColor(white: 0.2, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 13)
        label.textColor = UIColor(white: 0.7, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        alpha = 0.0
        backgroundColor = UIColor(white: 0.952, alpha: 1.0)
        
        addSubview(content)
        
        content.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        content.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(subtitle)
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        subtitle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        subtitle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        guard let parent = superview else { return }
        
        topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func updateNotification() {
        guard let necessaryNotification = notification else { return }
        
        title.text = necessaryNotification.title
        subtitle.text = necessaryNotification.subtitle
    }
    
    func present(animated: Bool) {
        guard animated else { return alpha = 1.0 }
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.alpha = 1.0
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.alpha = 0.0
        }
    }
    
}
