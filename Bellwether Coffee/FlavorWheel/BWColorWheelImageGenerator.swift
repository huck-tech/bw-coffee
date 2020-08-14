//
//  BWColorWheelImageGenerator.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/7/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit


protocol BWColorWheelImageGenerator {
    func backgroundImage() -> UIImage?
    func generateImageWithColorWheel(_ colorWheel: BWColorWheel) -> UIImage?
}
