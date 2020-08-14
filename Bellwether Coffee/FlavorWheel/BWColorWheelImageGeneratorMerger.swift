//
//  BWColorWheelImageGeneratorMerger.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/8/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit


protocol BWColorWheelValueImageProvider {
    func backgroundImage() -> UIImage?
    func circle1ValueImage(_ value: BWColorWheel.Circle1) -> UIImage?
    func circle2ValueImage(_ value: BWColorWheel.Circle2) -> UIImage?
    func circle3ValueImage(_ value: BWColorWheel.Circle3) -> UIImage?
}


class BWColorWheelImageGeneratorMerger: BWColorWheelImageGenerator {
    
    init(imageProvider: BWColorWheelValueImageProvider) {
        self.imageProvider = imageProvider
    }
    
    // MARK: BWColorWheelImageGenerator
    
    func backgroundImage() -> UIImage? {
        return imageProvider.backgroundImage()
    }
    
    func generateImageWithColorWheel(_ colorWheel: BWColorWheel) -> UIImage? {
        guard let backgroundImage = imageProvider.backgroundImage() else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height)
        
        // Draw
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        backgroundImage.draw(in: rect)
        
        if !drawColorWheelSegments(colorWheel, rect: rect) {
            UIGraphicsEndImageContext()
            return nil
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    // MARK: Private
    
    fileprivate let imageProvider: BWColorWheelValueImageProvider
    
    fileprivate func drawColorWheelSegments(_ colorWheel: BWColorWheel, rect: CGRect) -> Bool {
        for value in colorWheel.circle1Values.keys {
            guard let image = imageProvider.circle1ValueImage(value) else {
                return false
            }
            
            image.draw(in: rect)
        }
        
        for value in colorWheel.circle2Values.keys {
            guard let image = imageProvider.circle2ValueImage(value) else {
                return false
            }
            
            image.draw(in: rect)
        }

        for value in colorWheel.circle3Values.keys {
            guard let image = imageProvider.circle3ValueImage(value) else {
                return false
            }
            
            image.draw(in: rect)
        }
        
        return true
    }
}

class BWColorWheelValueImageProviderBase: BWColorWheelValueImageProvider {
    
    fileprivate let imageNames: BWColorWheelImageNames
    
    init(imageNames: BWColorWheelImageNames, bundle: Bundle = Bundle.main) {
        self.imageNames = imageNames
    }
    
    // MARK: BWColorWheelValueImageProvider
    
    func backgroundImage() -> UIImage? {
        return UIImage(named: "ColorWheelBackground")
    }
    
    func circle1ValueImage(_ value: BWColorWheel.Circle1) -> UIImage? {
        guard let imageName = imageNames.circle1ValueToFileName[value] else {
            return nil
        }
        
        return imageWithName(imageName)
    }
    
    func circle2ValueImage(_ value: BWColorWheel.Circle2) -> UIImage? {
        guard let imageName = imageNames.circle2ValueToFileName[value] else {
            return nil
        }
        
        return imageWithName(imageName)
    }
    
    func circle3ValueImage(_ value: BWColorWheel.Circle3) -> UIImage? {
        guard let imageName = imageNames.circle3ValueToFileName[value] else {
            return nil
        }
        
        return imageWithName(imageName)
    }
    
    // MARK: Private
    
    fileprivate func imageWithName(_ name: String) -> UIImage? {
        if name.count <= 4 {
            return nil
        }
        
        let nameWithoutType = name.bw_stringByDeletingPathExtension()
        
        guard let path = Bundle.main.path(forResource: nameWithoutType, ofType: "png") else {
            return nil
        }
        
        return UIImage(contentsOfFile: path)
    }
}
