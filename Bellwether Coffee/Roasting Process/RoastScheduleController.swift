//
//  RoastScheduleController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 8/11/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import DatePickerDialog
import Parse
import NotificationBannerSwift

class RoastScheduleController: NSObject {
    static let shared = RoastScheduleController()
    
    var scheduledRoast = ScheduledRoast()
    
    private func chooseDate(completion: DateHandler? = nil){
        /*Enable scheduling up to a one year in advance (31,557,600 seconds)*/
        DatePickerDialog().show("Schedule a Roast", doneButtonTitle: "Schedule",
                                cancelButtonTitle: "Cancel", defaultDate: Date(), minimumDate: Date(),
                                maximumDate: Date().addingTimeInterval(31557600), datePickerMode: .dateAndTime)
            {date  in
            completion?(date)
        }
    }

    
    func scheduleRoast(greenItem: GreenItem? = nil, roastProfile: RoastProfile? = nil) {
        guard let item = greenItem ?? RoastingProcess.editing.greenItem else {return}
        guard let profile = roastProfile ?? RoastingProcess.editing.roastProfile?.asRoastProfile else {return}
        
        self.scheduledRoast = ScheduledRoast()
        self.scheduledRoast.cafe = BellwetherAPI.auth.cafe
        self.scheduledRoast.green = item._id
        self.scheduledRoast.profile = profile._id
        self.scheduledRoast.prepared = NSNumber(value: false)

        self.chooseDate {[weak self] date in
            guard let _self = self, let date = date else {return}//cancelled
           _self.scheduledRoast.date = date
            
            //choose the pounds
            let poundPicker = PoundPickerViewController.bw_instantiateFromStoryboard()
            poundPicker.delegate = _self
            poundPicker.load(item: _self.scheduledRoast)
            poundPicker.modalTransitionStyle = .crossDissolve
            poundPicker.modalPresentationStyle = .overCurrentContext
            AppDelegate.visibleViewController?.present(poundPicker, animated: true)
        }
    }
}


extension RoastScheduleController: PoundPickerDelegate {
    func didSelect(units: Double, for item: PoundPickerSource){
        self.scheduledRoast.quantity = units.asNumber
        self.scheduledRoast.saveInBackground {success, error in
            guard success else {
                AppDelegate.visibleViewController?.showNetworkError(message: error.debugDescription)
                return
            }
            
            let banner = NotificationBanner(title: "Roast Scheduled", subtitle: "", style: .success, colors: BWColors())
            banner.dismissOnTap = true
            banner.show()
        }
    }
}

class ScheduledRoast: PFObject {
    @NSManaged var cafe: String?            //cafe id
    @NSManaged var green: String?            //green item id
    @NSManaged var profile: String?         //profile id
    @NSManaged var date: Date?
    @NSManaged var quantity: NSNumber?
    @NSManaged var prepared: NSNumber?
    
    enum Fields: String {
        case cafe = "cafe"
        case bean = "bean"
        case profile = "profile"
        case date = "date"
        case quantity = "quantity"
        case prepared = "prepared"
        
        static var all: [Fields] = [.cafe, .bean, .profile, .date, .quantity, .prepared]
    }
}

extension ScheduledRoast: PoundPickerSource {
    var units: Double? {return self.quantity?.doubleValue ?? 0}
    var increment: Double {return 0.1}
    func max(completion: @escaping DoubleHandler) {return completion(-1.0)}
}

extension ScheduledRoast: PFSubclassing {static func parseClassName() -> String {return "ScheduledRoast"}}
