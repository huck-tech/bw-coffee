//
//  RoasterDiscovery.swift
//  Roaster
//
//  Created by Marcos Polanco on 2/28/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoveryDelegate {
    func didSelect(device: RoasterBLEDevice)
    func devicesDidChange()
}

class DiscoveryViewController: UITableViewController {
    
    var delegate: DiscoveryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RoasterBLEDeviceDatabase.shared.delegate  = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return RoasterBLEDeviceDatabase.shared.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let device = RoasterBLEDeviceDatabase.shared.devices[indexPath.row]
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 22.0)!
        cell.textLabel?.text = device.roasterID
        cell.textLabel?.textColor = device.seenRecently ? .white : .lightText
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = RoasterBLEDeviceDatabase.shared.devices[indexPath.row]
        guard device.seenRecently, let roasterID = device.roasterID else {return}

        self.delegate?.didSelect(device: device)
    }
}

extension DiscoveryViewController: RoasterBLEDeviceDatabaseDelegate {
    func devicesDidChange() {
        self.delegate?.devicesDidChange()
        self.tableView.reloadData()
    }
}
