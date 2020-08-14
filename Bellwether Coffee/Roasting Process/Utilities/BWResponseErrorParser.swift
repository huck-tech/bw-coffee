//
//  BWResponseErrorParser.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/13/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation

protocol BWResponseErrorParser {
    func parse(json: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> NSError?
    func parse(data: Data?, error: NSError?, response: HTTPURLResponse?) -> NSError?
}
