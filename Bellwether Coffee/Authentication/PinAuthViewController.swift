//
//  PinAuthViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class PinAuthViewController: UIViewController {
    @IBOutlet weak var pinpad: PinpadView!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var indicators: IndicatorView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {return UIStatusBarStyle.default}
    override var prefersStatusBarHidden: Bool {return true}

    var delegate: PinAuthViewControllerDelegate? {
        didSet{
            self.setupInstructions(text: delegate?.instructions)
        }
    }
    
    var digits = Array<Int?>(repeating: nil, count: 4){
        didSet{print(digits)}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinpad.setup(delegate: self)
        indicators.setup()
        instructions.onTap(target: self, selector: #selector(takeAction))
        view.backgroundColor = UIColor.brandBackground
    }
    
    @objc private func takeAction(){
        delegate?.takeAction()
    }
    
    private func clear(){
        //all nils
        self.digits = Array<Int?>(repeating: nil, count: 4)
        
        //load the indicators
        indicators.load(digits: digits)
    }
    
    private func finish(){
        guard let delegate = delegate else {return print("guard.fail \(#function)")}
        DispatchQueue.main.async{[weak self] in
            guard let _self = self else {return}
            if !delegate.finished(digits: _self.digits){
                _self.confirm(title: "Error", message: delegate.failure, cancellable: false) {_ in
                    delegate.didFail()
                }
            }
        }
    }
    
    func setupInstructions(text: NSAttributedString?){
        instructions.attributedText = text
    }
}

extension PinAuthViewController: PinKeyViewDelegate {
    func tapped(pin: Int?){
        
        //find the current digit the user is tapping by finding the first nil
        //if there are none, the user has finished typing, so we move on to that
        guard let index = digits.index(of: nil) else {return print("tapping beyond capacity is an error. should not be possible")}
        
        //assign the digit
        digits[index] = pin
        
        //update the indicators
        indicators.load(digits: digits)
        
        //are all digits entered? in that case call finish
        if digits.index(of: nil) == nil {finish()}
    }
}

protocol PinAuthViewControllerDelegate {
    var instructions: NSAttributedString {get}
    var failure: String? {get}
    func finished(digits: [Int?])  -> Bool
    func didFail()
    func takeAction()
}

extension PinAuthViewControllerDelegate {
    func takeAction(){}
}

protocol PinKeyViewDelegate {
    func tapped(pin: Int?)
}

class IndicatorView: UIView {
    
    //create slots for each of the digits
    var slots = Array<UIImageView?>(repeating: nil, count: 4)

    fileprivate func setup(){
        //load the images in the correct place in the array
        self.subviews.forEach{
            //ensure the tags are in the range
            guard $0.tag <= slots.count else {return}
            slots[$0.tag] = $0 as? UIImageView
        }
    }
    
    fileprivate func load(digits: [Int?]){
        slots.enumerated().forEach { (index, slot) in
            //fill the slots with empty or filled indicators depending on whether the digit is specified
            slot?.image = UIImage(named: digits[index] == nil ? "indicator" : "indicator_filled")
        }
    }
}


class PinpadView: UIView {
    fileprivate func setup(delegate: PinKeyViewDelegate){
        self.subviews.forEach{
            
            //hide the view if it is not in the proper range or is not a PinKeyView
            guard $0.tag < 10, let view = $0 as? PinKeyView else {return $0.isHidden = true}
            view.number = $0.tag
            view.delegate  = delegate
        }
    }
}
