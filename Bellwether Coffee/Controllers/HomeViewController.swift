//
//  HomeViewController.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/5/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var presentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Present Test Controller", for: .normal)
        button.addTarget(self, action: #selector(presentTestController), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var text: DynamicTextView = {
        let text = DynamicTextView(frame: .zero)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        view.addSubview(text)
        
        text.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        text.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        text.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
//        view.addSubview(presentButton)
        
//        presentButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        presentButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        presentButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        presentButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func presentTestController() {
        let testController = MarketViewController()
        present(testController, animated: true)
    }
    
}
