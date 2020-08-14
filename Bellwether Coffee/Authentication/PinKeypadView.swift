//
//  PinKeypadView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class PinKeypadView: ComponentView {
    
    var lastRow: NSLayoutYAxisAnchor!
    
    override func setupViews() {
        lastRow = topAnchor
        
        addKeyViews(numbers: [1, 2, 3])
        addKeyViews(numbers: [4, 5, 6])
        addKeyViews(numbers: [7, 8, 9])
        addKeyViews(numbers: [nil, 0, nil])
    }
    
    func addKeyViews(numbers: [Int?]) {
        var rowViews = [UIView]()
        
        numbers.forEach { number in
            let keyView = PinKeyView(frame: .zero)
            keyView.number = number
            rowViews.append(keyView)
        }
        
        addRowViews(views: rowViews)
    }
    
    func addRowViews(views: [UIView]) {
        let row = UIStackView(arrangedSubviews: views)
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        
        row.topAnchor.constraint(equalTo: lastRow).isActive = true
        row.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        row.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        row.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        lastRow = row.bottomAnchor
    }
    
}
