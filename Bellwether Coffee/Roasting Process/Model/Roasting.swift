//
//  Roasting.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/1/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Roasting: NSObject {
    
    static var editing = Roasting.init(isEditing: true)
    static var roasting = Roasting.init(isEditing: false)
    
    var isEditing: Bool
    
    init(isEditing: Bool) {
        self.isEditing = isEditing
    }

    private var current: RoastingProcess {
        return isEditing ? RoastingProcess.editing : RoastingProcess.roasting
    }
    var state: RoastingState {
        return current.state
    }
    
    var coffeeName: String? {
        return current.greenItem?._name
    }
    
    var profileName: String? {
        return current.roastProfile?.metadata?.name
    }
    
    override var description: String {
        guard let _ = current.greenItem?._id, let coffee = coffeeName, let profile = profileName else {return ""}
        return "\(coffee), \(profile)"
    }
}

extension Notification.Name {
    static let roastingChanged = Notification.Name("roastingChanged")
}


enum RoastingState {
    case none           //user has taken no action
    case requested      //user tapped 'start roast'
    case started        //roaster has been asked to preheat & roast when ready
    case roasting       //roaster has been asked to roast
    case finished       //roaster is now cycling back into ready (from cool) and user has not yet added roasted inventory
    case aborted        //unused at this time. means the user stopped the roast during preheat or roasting
}

extension RoastingState: BWStringValueRepresentable {
    var stringValue: String {
        switch self {
        case .none:
            return "None"
        case .requested:
            return "Requested"
        case .started:
            return "Started"
        case .roasting:
            return "Roasting"
        case .finished:
            return "Finished"
        case .aborted:
            return "Aborted"
        }
    }
}
