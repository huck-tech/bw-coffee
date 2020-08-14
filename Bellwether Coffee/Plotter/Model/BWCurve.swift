//
//  BWCurve.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.02.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation

typealias BWReal = Double

struct BWPoint {
    var x: BWReal
    var y: BWReal
}


protocol BWCurve {
    func f(_ x: BWReal) -> BWReal
}
