//
//  MarketPhotoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/30/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketPhotoView: View {
    
    var image: UIImage? {
        didSet { updateImage() }
    }
    
    var photo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func setupViews() {
        backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        
        addSubview(photo)
        
        photo.topAnchor.constraint(equalTo: topAnchor).isActive = true
        photo.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        photo.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        photo.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func updateImage() {
        photo.alpha = 0.0
        photo.image = image
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.photo.alpha = 1.0
        }
    }
    
}

