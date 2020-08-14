//
//  SidebarMenuHeader.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class SidebarMenuHeader: ComponentReusableView {
    
    var logo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "menu_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var profileInfo: SidebarProfileView = {
        let profile = SidebarProfileView(frame: .zero)
        profile.translatesAutoresizingMaskIntoConstraints = false
        return profile
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        addSubview(logo)
        
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        logo.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 220).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        addSubview(profileInfo)
        
        profileInfo.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 40).isActive = true
        profileInfo.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        profileInfo.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        profileInfo.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: profileInfo.bottomAnchor, constant: 20).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}

