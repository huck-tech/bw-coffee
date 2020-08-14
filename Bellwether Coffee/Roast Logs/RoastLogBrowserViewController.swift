//
//  RoastLogBrowserViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Parse
import SwiftyJSON
import SwiftDate

class RoastLogDatabase {
    static let shared = RoastLogDatabase()
    
    var beans =    [String:Bean]()
    var profiles = [String:RoastProfile]()
    var beanProfiles = [String:[RoastProfile]]()

    //one-time migration for roasts without serial numbers
    private func updateSerialNumbers(){
        let translate = [
            "Gladys":"I000000",
            "Bellwether One":"P000010",
            "Hive":"P000020",
            "Bellwether Three":"P000030",
            "Sweet Bar":"P000040",
            "Bellwether Four":"P000040",
            "Bellwether Five":"P000050",
            "Bellwether Six":"P000060",
            ]
        let q = RoastLog.query()
        q?.whereKeyDoesNotExist("serialNumber")
//        q?.whereKey("firmware", contains: "P1-")
        q?.limit = 1000
        q?.findObjectsInBackground(block: {results, error in
            guard let logs = results as? [RoastLog] else {return print("guard.fail \(#function)")}

            logs.forEach {log in
                if let machine = log.machine {
                    log.serialNumber = translate[machine]
                    log.saveInBackground()
                }
            }
        })
    }
    
    private func migrateRoastData(){
        let q = RoastLog.query()
        q?.whereKeyDoesNotExist("migrated")
        q?.limit = 300
        q?.findObjectsInBackground {results, error in
            guard let logs = results as? [RoastLog] else {return print("guard.fail \(#function)")}
            logs.forEach {log in
                let data = RoastData()
                data.log = log
                data.measurements = log.measurements
                data.saveInBackground()
                log.setValue(true, forKey: "migrated")
                log.saveInBackground()
            }
            print("--------------f--------------i-----------nished \(logs.count) logs")
        }
    }
    
    func load() {
        self.updateSerialNumbers()
//        self.migrateRoastData()

        self.buildBeanLookup{[weak self] in
            self?.buildRoastProfileLookup {
            }
        }
    }
    
    private func buildBeanLookup(completion: @escaping VoidHandler) {
        BellwetherAPI.beans.getBeans {[weak self] beans in
            beans?.forEach{bean in
                guard let beanId = bean._id else {return}
                self?.beans[beanId] = bean
            }
            completion()
        }
    }
    
    private func buildRoastProfileLookup(completion: @escaping VoidHandler) {
        beans.keys.forEach{beanId in
            BellwetherAPI.roastProfiles.getRoastProfiles(bean: beanId, completion: {[weak self] profiles in
                if let profiles = profiles {
                    self?.beanProfiles[beanId] = profiles
                }
                profiles?.forEach{profile in
                    guard let profileId = profile._id else {return}
                    self?.profiles[profileId] = profile
                }
                completion() //this gets called once for each bean
            })
        }
    }
}

class RoastLogBrowserViewController: UIViewController {

    
    let MAX_RESULTS = 50
    
    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadRoastLogs()
        //register as the delegate to the RoastLog database
        RoastLog.delegate = self
    }
    

    

        
    func loadRoastLogs() {
        let query = RoastLog.query()?.order(byDescending: "createdAt")
        
        //limit the results to the max number for up to max days
        //...only for real machines (not gladys), for the current cafe, and only
        //those that got past preheat.
        query?.limit = MAX_RESULTS
        query?.whereKey("cafe", equalTo: BellwetherAPI.auth.cafe ?? "")
        query?.whereKey("machine", notEqualTo: "Gladys")
        query?.whereKey("state", greaterThan: BWRoasterDeviceRoastState.preheat.rawValue)
        query?.whereKey("createdAt", greaterThan: RoastLog.maxDays.day.ago())
        let start = ProcessInfo.processInfo.systemUptime
        query?.findObjectsInBackground {results, error in
            let end = ProcessInfo.processInfo.systemUptime
            print("RoastLog.findObjectsInBackground(\(end - start))")
            
            guard let roastLogs = results as? [RoastLog] else {
                return print("\(#function) error: \(error.debugDescription)")
            }
            
            RoastLog.roastLogs = roastLogs.filter {
                guard let bean = $0.bean, let profile = $0.profile else {return false}
                return !(bean.isEmpty || profile.isEmpty)
            }
        }
    }
}

protocol RoastLogInformationDelegate {
    func bean(for id: String?) -> Bean?
    func profile(for id:String?, completion: @escaping (RoastProfile?) -> Void)

}

extension RoastLogBrowserViewController: RoastLogInformationDelegate {
    func bean(for id: String?) -> Bean? {
        guard let id = id else {return nil}
        return RoastLogDatabase.shared.beans[id]
    }
    func profile(for id:String?, completion: @escaping (RoastProfile?) -> Void){
        guard let id = id else {return completion(nil)}
        
        if let profile = RoastLogDatabase.shared.profiles[id] {
            //we have it cached, so execute completion
            completion(profile)
        } else {
            //we need to fetch it
            BellwetherAPI.roastProfiles.getRoastProfile(profile: id) {profile in
                completion(profile)
            }
        }
    }
}

extension RoastLogBrowserViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "Header")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoastLog.roastLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoastLogTableViewCell.reuseIdentifier) as! RoastLogTableViewCell
        
        cell.load(roastLog: RoastLog.roastLogs[indexPath.row], delegate: self, isEven: indexPath.row % 2 == 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = RoastLog.roastLogs[indexPath.row]
        
        let controller = RoastLogViewController.bw_instantiateFromStoryboard()
        self.profile(for: log.profile){[weak self] profile in
            controller.bwRoastProfile = profile?.asBWRoastProfile
            controller.roastLog = log
            controller.infoDelegate = self
            self?.navigationController?.pushViewController(controller, animated: true)
        }

    }
}

class RoastLogTableSortViewCell: UITableViewCell {
    @IBOutlet weak var when: UILabel!
    @IBOutlet weak var who: UILabel!
    @IBOutlet weak var coffee: UILabel!
    @IBOutlet weak var profile: UILabel!
    @IBOutlet weak var green: UILabel!
    @IBOutlet weak var charge: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var roast: UILabel!
    @IBOutlet weak var loss: UILabel!
    @IBOutlet weak var comments: UIImageView!
    @IBOutlet weak var favorite: UIImageView!

    
    var headers: [UIView] = []
    
    override func awakeFromNib() {
        self.headers = [when, who, coffee, profile, green, charge, time, roast, loss, favorite] as! [UIView]
        self.headers.forEach {$0.onTap(target: self, selector: #selector(sort))}
        self.load()
        
        self.comments.onTap(target: self, selector: #selector(showComments))
    }
    
    @objc func showComments(){
        RoastLogCommentsViewController.showComments(for: nil)
    }
    
    @objc func sort(sender: UITapGestureRecognizer){
        guard let index = sender.view?.tag else {return print("not sortable sender")}
        guard let field = RoastLog.Fields.init(rawValue: index) else {return print("could not sort by \(index)")}
        RoastLog.sort(key: field)
        self.load()
    }
    
    private func load() {
        self.headers.enumerated().forEach{($0.element as? UILabel)?.textColor = $0.offset == RoastLog.lastSortKey.rawValue ? UIColor.brandPurple : UIColor.white}
        favorite.image = UIImage(named: RoastLog.lastSortKey.rawValue == favorite.tag ? "heart_lighted" : "heart")
    }
    
}

extension UITableViewCell {
    static var reuseIdentifier: String {return "\(self)"}
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {return "\(self)"}
}

class RoastLogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var roaster: UILabel!
    @IBOutlet weak var bean: UILabel!
    @IBOutlet weak var profile: UILabel!
    @IBOutlet weak var inputWeight: UILabel!
    @IBOutlet weak var preheat: UILabel!
    @IBOutlet weak var dropTime: UILabel!
    @IBOutlet weak var outputWeight: UILabel!
    @IBOutlet weak var shrinkage: UILabel!
    @IBOutlet weak var comments: UIView!
    @IBOutlet weak var favorite: UIView!
    @IBOutlet weak var favoriteImg: UIImageView!

    weak var roastLog: RoastLog?
    
    override func awakeFromNib() {
        comments.onTap(target: self, selector: #selector(commentsTapped))
        favorite.onTap(target: self, selector: #selector(favoriteTapped))
    }

    func load(roastLog: RoastLog, delegate: RoastLogInformationDelegate, isEven: Bool) {
        self.backgroundColor = isEven ? UIColor.bw_color09 : UIColor.white

        if let firmware = roastLog.firmware, BellwetherAPI.auth.isBellwetherUser {
            if firmware.contains("BW_RC_P1") {
                self.backgroundColor = UIColor.init(hex: "E8EBC2")
            } else if firmware.contains("BW_RC_P2") {
                self.backgroundColor = UIColor.init(hex: "D4A656")
            } else if firmware.contains("BW_RC_P3") {
                self.backgroundColor = UIColor.init(hex: "EEADB4")
            } else if firmware.contains("BW_RC_P5") {
                self.backgroundColor = UIColor.init(hex: "B4EEAD")
            } else if firmware.contains("P6") {
                self.backgroundColor = UIColor.init(hex: "FFC966")
            } else if firmware.contains("P7") {
                self.backgroundColor = UIColor.init(hex: "9999FF")
            }
        }

        self.roastLog = roastLog
        self.date.text = roastLog.date?.string() ?? roastLog.createdAt?.string()
        self.roaster.text = roastLog.roaster?.components(separatedBy: " ").first
        self.bean.text = delegate.bean(for: roastLog.bean)?._name ?? "-"
        
        delegate.profile(for: roastLog.profile){[weak self] profile in
            self?.profile.text = profile?.name ?? "-"

            if let temp = profile?.asBWRoastProfile?.steps[0].temperature {
                self?.preheat.text = "\(temp.asFahrenheit.asInt)°"
            } else {
                self?.preheat.text = "-°"
            }
        }
        
        let input = roastLog.inputWeight?.doubleValue ?? 0.0
        self.inputWeight.text = "\(input.asComparable.display) lbs"
        

        
        let output = roastLog.outputWeight?.doubleValue ?? 0.00
        
        self.dropTime.text = roastLog.dropTime?.doubleValue.displayMinSec()
        self.outputWeight.text = "\(output.asComparable.display) lbs"
        self.shrinkage.text = "\(((input - output) * 100 / input).asComparable.display)%"
        self.favoriteImg.image = UIImage(named: roastLog.isFavorite ? "heart_filled" : "heart")
    }
    
    @objc func favoriteTapped() {
        
        //toggle the value
        self.roastLog?.favorite = NSNumber(value: !(self.roastLog?.isFavorite ?? false))
        self.roastLog?.saveInBackground {success, error in
            guard success else {return print("failed to save the roast log favoriting")}
            
            //reload the entire table to reflect the change
            (AppDelegate.visibleViewController as? RoastLogBrowserViewController)?.tableView.reloadData()
        }
    }
    
    @objc func commentsTapped() {
        RoastLogCommentsViewController.showComments(for: self.roastLog)
    }
}

extension UIViewController {
    static var storyboardID: String {return "\(self)"}
}

protocol RoastLogDatabaseDelegate {
    func roastLogDidChange()
}

extension RoastLogBrowserViewController: RoastLogDatabaseDelegate {
    func roastLogDidChange() {
        self.tableView.reloadData()
    }
}
