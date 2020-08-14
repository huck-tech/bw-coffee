//
//  SidebarProfileView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class SidebarProfileView: ComponentView {
    
    var info: SidebarProfileInfo? {
        didSet {
            guard let profileInfo = info else { return }
            setProfile(info: profileInfo)
        }
    }
    
    var profilePhoto: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 19)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 15)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var action: (() -> Void)?
    
    override func setupViews() {
        addSubview(profilePhoto)
        
        profilePhoto.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profilePhoto.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
        profilePhoto.widthAnchor.constraint(equalToConstant: 56).isActive = true
        profilePhoto.heightAnchor.constraint(equalToConstant: 56).isActive = true
        profilePhoto.layer.cornerRadius = 56 / 2
        
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        title.leftAnchor.constraint(equalTo: profilePhoto.rightAnchor, constant: 14).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -28).isActive = true
        title.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        addSubview(subtitle)
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2).isActive = true
        subtitle.leftAnchor.constraint(equalTo: profilePhoto.rightAnchor, constant: 14).isActive = true
        subtitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -28).isActive = true
        subtitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setProfile(info: SidebarProfileInfo) {
        let titleString = info.title?.uppercased() ?? ""
        
        let titleRenderer = TextRenderer()
        titleRenderer.font = UIFont(name: "OpenSans-Semibold", size: 15)
        titleRenderer.color = UIColor(white: 1.0, alpha: 1.0)
        titleRenderer.spacing = 2
        titleRenderer.appendText(string: titleString)
        title.attributedText = titleRenderer.renderedText
        
        let subtitleString = info.subtitle?.uppercased() ?? ""
        
        let subtitleRenderer = TextRenderer()
        subtitleRenderer.font = UIFont(name: "OpenSans-Regular", size: 11)
        subtitleRenderer.color = UIColor(white: 1.0, alpha: 0.5)
        subtitleRenderer.spacing = 2
        subtitleRenderer.appendText(string: subtitleString)
        subtitle.attributedText = subtitleRenderer.renderedText
        
        // temporarily hidden, not sure what we will put here
        subtitle.isHidden = true
        
        guard let profilePhotoUrlString = info.profilePhoto else { return }
        guard let imageUrl = URL(string: profilePhotoUrlString) else { return }
        
        SpeedyNetworking.downloadImage(url: imageUrl) { image in
            self.profilePhoto.image = image
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
    
}

