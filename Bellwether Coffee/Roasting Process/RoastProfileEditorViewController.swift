//
//  RoastProfileEditorViewController.swift
//  RoastProfileEditorViewController
//
//  Created by Marcos Polanco on 2/22/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import UIKit

enum EditMode {
    case create
    case edit
    case duplicate
}

class RoastProfileEditorViewController: UIViewController {
    
    weak var graphView: BWRoastProfileGraphViewController!
    @IBOutlet weak var graphBox: UIView!
    weak var infoBox: RoastingInformationViewController?
    
    var editMode = EditMode.edit
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if editMode != .edit {
            //automatically request a new name since we are duplicating the profile
            self.infoBox?.requestProfileName()
        }
    }
    private func loadGraph(/*for roastProfile: BWRoastProfile? = nil*/) {        
        guard let bwRoastProfile = RoastingProcess.editing.roastProfile else {return /*print("configure() failed to obtain a roast profile")*/}
        graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: bwRoastProfile,isEditable: true, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
        graphView.roastProfileDataSource.editingDelegate = self
    }
    
    private var roastProfileSteps: [BWRoastProfileStep]? {
        return graphView?.roastProfileDataSource.buildRoastProfile().steps
    }
    
    @IBAction func saveProfile(_sender: Any) {
        
        guard let bwRoastProfile = graphView?.roastProfileDataSource.buildRoastProfile() else {
            return print("buildRoastProfile() failed")
        }
        
        //take the steps, which is all we want from the graph
        RoastingProcess.editing.roastProfile?.steps = bwRoastProfile.steps
        guard let beanId = RoastingProcess.editing.greenItem?.bean,
            let profile = RoastingProcess.editing.roastProfile?.asRoastProfile(for: beanId, _id:bwRoastProfile.metadata?.id) else {
            return print("could not create roast profile")
        }
        // invalidate the cache of roast profiles when a user creates a new profile or edits an existing profile
        if let bean = profile.bean {
            RoastLogDatabase.shared.beanProfiles[bean] = nil
        }
        if editMode != .edit ||  profile._id == nil || profile._id == "" {
            
            //even out the intervals upong first save //@uncommit - evenIntervals() is specified below
            guard let profile = profile.asBWRoastProfile?/*.evenIntervals(count: 25)*/.asRoastProfile else {return print("could not evenIntervals")}
            BellwetherAPI.roastProfiles.create(profile: profile) {[weak self] success in
                self?.navigationController?.popViewController(animated: true)
                
                guard success else {
                    return print ("Could not create roast profile.")
                }
//                self?.delegate?.roastProfileUpdated(roastProfile: bwRoastProfile, reload: true)
           }
        } else {
            guard let profileId = profile._id else {return print("update.profile failed. profile._id == nil")}

            BellwetherAPI.roastProfiles.update(profile: profileId, update: profile, completion: {[weak self] success in
                self?.navigationController?.popViewController(animated: true)
                guard success else {
                    return print("Could not edit roast profile.")
                }
//                self?.delegate?.roastProfileUpdated(roastProfile: bwRoastProfile, reload: true)
            })
        }
    }
    
    @IBAction func cancel(_sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        delegate?.roastProfileUpdateCancelled()
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        //capture the roasting info box
        if let child = childController as? RoastingInformationViewController {
            self.infoBox = child
            self.infoBox?.isEditable = true
            self.infoBox?.delegate = self
        } else if let child = childController as? BWRoastProfileGraphViewController {
            self.graphView = child
            self.loadGraph()
        }
    }
}

protocol RoastProfileEditingDelegate: class {
    func roastProfileUpdated(roastProfile: BWRoastProfile?, reload: Bool)
    func roastProfileUpdateCancelled()
}

//from embedded graphView
extension RoastProfileEditorViewController: BWRoastProfileEditingDelegate {
    
    private func updateMetadata(roastProfile: BWRoastProfile) {
        //grab the starting temperature
        let startTemp = roastProfile.steps[0].temperature
        RoastingProcess.editing.roastProfile?.steps[0].update(temperature: startTemp)
        
        //grab the ending time
        if var step = RoastingProcess.editing.roastProfile?.steps.last,
            let lastTime = roastProfile.steps.last?.time {
            step.update(time: lastTime)
            RoastingProcess.editing.roastProfile?.duration = lastTime
        } else {
            print("NO LAST STEP FOR lastTime to work with")
        }
        
        NotificationCenter.default.post(name: .roastProfileUpdated, object: nil)
    }
    
    func roastProfileChanged(roastProfile: BWRoastProfile) {
        self.updateMetadata(roastProfile: roastProfile)
    }
}

//this is for infobox events
extension RoastProfileEditorViewController: RoastProfileEditingDelegate {
    func roastProfileUpdated(roastProfile: BWRoastProfile?, reload: Bool = true) {
        
        //the reference steps are in the graph, so we update those
        if reload, let steps = self.roastProfileSteps {
            RoastingProcess.editing.roastProfile?.steps = steps
        }
        self.loadGraph(/*for: roastProfile*/)
    }
    
    func roastProfileUpdateCancelled() {
        //do nothing
    }
}

