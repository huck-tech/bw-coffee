//
//  SpeedyImageCache.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/28/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class SpeedyImageCache {
    
    static let shared = SpeedyImageCache()
    
    var cachedImages = [URL: Data]()
    
    func prefetchURLStrings(urls: [String]) {
        urls.forEach { url in
            let imageUrl = SpeedyConfiguration.shared.defaultAppUrl?.appendingPathComponent(url)
            let download = SpeedyDownload(url: imageUrl)
            
            download?.execute { imageData in
                // do something later
            }
        }
    }
    
}
