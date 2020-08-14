//
//  ViewSnapshot.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/1/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

extension UIView {
    
    func createSnapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { layer.render(in: $0.cgContext) }
    }
    
}
