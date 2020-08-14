//
//  RoastProfileGraphViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/26/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastProfileGraphViewController: UIViewController {
    private weak var graphView: BWRoastProfileGraphViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.parent == nil {
            self.set(roastProfile: Mujeres.roastProfile, isEditable: true)
        }
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let graphView = childController as? BWRoastProfileGraphViewController {
            self.graphView = graphView
        }
    }
    
    var roastProfile: BWRoastProfile?

    public func set(roastProfile: BWRoastProfile, isEditable: Bool) {
        self.roastProfile = roastProfile
        graphView?.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: roastProfile,isEditable: isEditable, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
    }
}
