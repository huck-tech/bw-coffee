//
//  OnboardingPageView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class OnboardingPageView: ComponentView {
    
    var image: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 20)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 17)
        label.textColor = UIColor(white: 1.0, alpha: 0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var page: OnboardingPage! {
        didSet {
            let title = page.title ?? ""
            setTitle(titleString: title)
            
            let description = page.description ?? ""
            setDescription(descriptionString: description)
            
            if let pageImage = page.image {
                image.image = UIImage(named: pageImage)
            }
        }
    }
    
    override func setupViews() {
        addSubview(image)
        
        image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60).isActive = true
        image.widthAnchor.constraint(equalToConstant: 160).isActive = true
        image.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 12).isActive = true
        title.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 26).isActive = true
        title.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -26).isActive = true
        
        addSubview(subtitle)
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
        subtitle.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 26).isActive = true
        subtitle.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -26).isActive = true
    }
    
    func setTitle(titleString: String) {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "OpenSans-Semibold", size: 19)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.spacing = 3
        renderer.appendText(string: titleString.uppercased())
        title.attributedText = renderer.renderedText
    }
    
    func setDescription(descriptionString: String) {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "OpenSans-Semibold", size: 17)
        renderer.color = UIColor(white: 1.0, alpha: 0.7)
        renderer.appendText(string: descriptionString)
        subtitle.attributedText = renderer.renderedText
    }
    
}

