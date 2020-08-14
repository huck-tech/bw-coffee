//
//  SpeedyDownload.swift
//  Networking
//
//  Created by Gabe The Coder on 10/4/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class SpeedyDownload {
    
    var downloadURL: URL!
    
    init?(url: URL?) {
        if let preparedUrl = url {
            downloadURL = preparedUrl
        } else {
            return nil
        }
    }
    
    init?(string: String) {
        if let stringUrl = URL(string: string) {
            downloadURL = stringUrl
        } else {
            return nil
        }
    }
    
    static private func save(url: URL, data: Data?) {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
        let result = try? data?.write(to: fileURL)
        print("data.write result:\(result != nil) for \(url.lastPathComponent)")
    }
    
    static private func fetch(url: URL) -> Data? {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(url.lastPathComponent)
        return try? Data.init(contentsOf: fileURL)
    }
    
    
    func execute(completion: @escaping (Data?) -> Void) {
        guard let cachedImage = SpeedyImageCache.shared.cachedImages[self.downloadURL] else {
            guard let savedImage = SpeedyDownload.fetch(url: self.downloadURL) else {
                URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                    SpeedyImageCache.shared.cachedImages[self.downloadURL] = data
                    if let url = response?.url {
                        SpeedyDownload.save(url: url, data: data)
                    }
                    DispatchQueue.main.async { completion(data) }
                }.resume()
                
                return
            }
            
            return DispatchQueue.main.async { completion(savedImage) }
        }
        
        DispatchQueue.main.async { completion(cachedImage) }
    }
    
    func executeImage(completion: @escaping (UIImage?) -> Void) {
        execute { data in
            guard let imageData = data else { return completion(nil) }
            guard let downloadedImage = UIImage(data: imageData) else { return completion(nil) }
            
            completion(downloadedImage)
        }
    }
    
}
