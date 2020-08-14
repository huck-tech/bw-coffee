//
//  FlavorWheelFilterController.swift
//  Bellwether-iOS
//
//  Created by Marcos Polanco on 2/19/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import Foundation
import UIKit

class FlavorWheelFilterController: UIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var shader1: UIImageView!
    @IBOutlet weak var shader2: UIImageView!
    
    weak var delegate: MarketListFilterDelegate?
    
    var isEnabled = true

    //starting point in percentage terms of each circle starting from the center
    let circle0: CGFloat = 0.036
    let circle1: CGFloat = 0.06
    let circle2: CGFloat = 0.1
    let circle3: CGFloat = 0.2

    var imageGenerator: BWColorWheelImageGenerator?
    var beans: [Bean] = []

    //start with an empty wheel
    var flavorWheel = BWColorWheel.init(circle1Values: [BWColorWheel.Circle1](), circle2Values: [BWColorWheel.Circle2](), circle3Values: [BWColorWheel.Circle3]())

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.beans = self.delegate?.beans ?? []
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.foregroundImage.onTap(target: self, selector: #selector(wheelTapped(_:)))
        self.imageGenerator = colorWheelImageGenerator()
        
        self.shader1.onTap(target: self, selector: #selector(close))
        self.shader2.onTap(target: self, selector: #selector(close))
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    @objc func wheelTapped(_ recognizer: UITapGestureRecognizer) {
        
        //if editing is disabled, tapping just closes the whole thing
        guard isEnabled else {
            return self.close()
        }
        
        //identify where the user tapped
        let point = recognizer.location(in: backgroundImage)
        
        //identify the center of the circle
        let center = CGPoint(x: backgroundImage.bounds.width/2.0, y: backgroundImage.bounds.height/2.0 - 18.0)
        
        //distance is a percentage of the radius and the angle of the touch relative the center
        let distance = center.distanceToPoint(p: point) / backgroundImage.bounds.width/2.0
        let angle = center.angleToPoint(pointOnCircle: point)
        let degrees = 360.0 - (360.0 * angle/(2 * CGFloat.pi))

        let flavor: Circle?

        //find the flavor for the given circle
        if distance < circle0 {
            flavor = nil
        } else if distance < circle1 {
            flavor = self.flavor(for: BWColorWheel.Circle1.angles, degrees: degrees)
        } else if distance < circle2 {
            flavor = self.flavor(for: BWColorWheel.Circle2.angles, degrees: degrees)
        } else if distance < circle3 {
            flavor = self.flavor(for: BWColorWheel.Circle3.angles, degrees: degrees)
        } else {
            //user tapped a corner, so we do nothing
            return self.close()
        }
        
        guard let _flavor = flavor else {return}
        
        //toggle the tapped flavor on the wheel
        self.flavorWheel.toggle(_flavor)
        self.redraw()
        
        //sort search results based on the match between the query and the cupping notes
        self.beans.sort{prev,next in prev.flavorWheel.match(other: self.flavorWheel) > next.flavorWheel.match(other: self.flavorWheel)}
        
        self.delegate?.didSort(beans: self.beans)
    }
    
    func redraw() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let _self = self else {return}
            let image = _self.imageGenerator?.generateImageWithColorWheel(_self.flavorWheel)
            DispatchQueue.main.async {
                _self.foregroundImage.image = image
            }
        }
    }
    
    func flavor(for angles: [FlavorAngle<BWColorWheel.Circle1>], degrees: CGFloat) -> Circle? {
        for flavor in angles {
            if flavor.angle  < degrees {continue}
            return flavor.circle
        }
        return nil
    }
    
    func flavor(for angles: [FlavorAngle<BWColorWheel.Circle2>], degrees: CGFloat) -> Circle? {
        for flavor in angles {
            if flavor.angle  < degrees {continue}
            return flavor.circle
        }
        return nil
    }

    func flavor(for angles: [FlavorAngle<BWColorWheel.Circle3>], degrees: CGFloat) -> Circle? {
        for flavor in angles {
            if flavor.angle  < degrees {continue}
            return flavor.circle
        }
        return nil
    }

    
    fileprivate func colorWheelImageGenerator() -> BWColorWheelImageGenerator? {
        let bundle = Bundle.main
        
        guard let path = bundle.path(forResource: "ColorWheelImageMapping", ofType: "plist"),
            let dict = bw_dictionaryWithContentsOfFile(path),
            let colorWheelImageNames = BWColorWheelImageNames(json: dict) else {return nil}
        let imageProvider = BWColorWheelValueImageProviderBase(imageNames: colorWheelImageNames)
        
        return BWColorWheelImageGeneratorMerger(imageProvider: imageProvider)
    }
}

class BeanFlavorWheelViewController: FlavorWheelFilterController {
    func set(bean: Bean) {
        self.flavorWheel = bean.flavorWheel
        self.redraw()
    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.isEnabled = false
//    }
}

extension CGPoint {
    func distanceToPoint(p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
    
    func angleToPoint(pointOnCircle: CGPoint) -> CGFloat {
        
        let originX = pointOnCircle.x - self.x
        let originY = pointOnCircle.y - self.y
        var radians = atan2(originY, originX)
        
        while radians < 0 {
            radians += CGFloat(2 * Double.pi)
        }
        
        return radians
    }
}

