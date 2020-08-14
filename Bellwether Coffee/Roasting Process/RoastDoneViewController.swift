//
//  RoastDoneViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/29/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation


class RoastingDoneViewController: RoastingStepController {
    @IBOutlet weak var doneWeight: UILabel!
    
    //start with zero as the final weight, and have the user hand-edit the amount
    var roastedQuantity:Double = 0.0
    
    var showedComments = false
    var showedWeight = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneWeight.onTap(target: self, selector: #selector(chooseWeight))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
        
        guard showedWeight == false else {return}
        
        DispatchQueue.main.async {[weak self] in
            self?.chooseWeight()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        self.view.backgroundColor = .white
    }
    
    @objc func chooseWeight(){
        
        showedWeight = true
        
        //choose the pounds
        let poundPicker = PoundPickerViewController.bw_instantiateFromStoryboard()
        let _ = poundPicker.view //force a load so that .load() below does not crash. 
        poundPicker.delegate = self
        poundPicker.closeOnTapOutside = false
        poundPicker.load("Bean Weight?", item: self)
        poundPicker.modalTransitionStyle = .crossDissolve
        poundPicker.modalPresentationStyle = .overCurrentContext
        self.present(poundPicker, animated: true)

    }
    
    override func load() {
        self.doneWeight.text = "\(roastedQuantity.formattedLbs(fractionDigits: 1)) lbs"
        
    }
    
    func createRoastedInventory() {
        guard let greenItemId = RoastingProcess.roasting.greenItem?._id, let profileId = RoastingProcess.roasting.roastProfile?.metadata?.id else {
            return print("no green bean for \(#function)")
        }
        let roast = RoastRequest(green: greenItemId, profile: profileId, loadedQuantity: RoastingProcess.roasting.inputWeight, roastedQuantity: roastedQuantity)
    
        BellwetherAPI.roasts.completeRoast(request: roast) {[weak self] success in
            if !success {
                self?.showNetworkError(message: "Error Adding Inventory")
            }
        }
    }
    
    @IBAction func addToRoastedInventory(_ sender: Any) {
        self.createRoastedInventory()
        
        //create roasted inventory
        RoastingProcess.reset()
        self.roastingStepDelegate?.stepDidComplete()
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let graphView = childController as? BWRoastProfileGraphViewController {
            graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: RoastingProcess.roasting.roastProfile ?? Mujeres.roastProfile,isEditable: false, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
        }
    }
}

extension RoastingDoneViewController:PoundPickerSource {
    var units: Double? {
        return 0.0
    }
    
    var increment: Double {
        return 0.1
    }
    
    func max(completion: @escaping DoubleHandler) {
        completion(6.0)
    }
}

extension RoastingDoneViewController:PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource){
        self.roastedQuantity = units
        
        //put it in the roast log
        RoastingProcess.roasting.roastLog?.outputWeight = roastedQuantity.asNumber
        
        self.load()
        
        if !showedComments  {
            showedComments = true
            RoastLogCommentsViewController.showComments(for: RoastingProcess.roasting.roastLog)
        }
    }
}
