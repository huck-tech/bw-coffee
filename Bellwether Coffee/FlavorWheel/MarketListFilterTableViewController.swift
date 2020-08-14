//
//  MarketListFilterTableViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class MarketListFilterTableViewController: UIViewController {    
    weak var delegate: MarketListFilterDelegate?
    
    static var filters = [MarketFilter:[String:Bool]]()
    
    let origins = ["Africa", "Central America", "South America",
                   "North America", "Pacific / Oceania"]
    let profiles = ["Light", "Cold Brew", "Medium", "Blend", "Dark",
                    "Decaf", "Espresso"]
    let certifications = ["Conventional", "Organic", "Fair Trade",
                          "Biodynamic", "Rainforest Alliance"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var triangle: UIView!
    @IBOutlet weak var tapAbove: UIView!
    @IBOutlet weak var tapOutside: UIView!
    @IBOutlet weak var applyFiltersBtn: UIButton!
    
    var filters: [MarketFilter:[String:Bool]] {return MarketListFilterTableViewController.filters}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        triangle.transform = CGAffineTransform(rotationAngle: /*CGFloat.pi*/0.785398)
        self.tapAbove.onTap(target: self, selector: #selector(close))
        self.tapOutside.onTap(target: self, selector: #selector(close))
        tableView.tableFooterView = UIView(frame: .zero) //remove empty cells
        self.applyFiltersBtn.isEnabled = false
        self.applyFiltersBtn.backgroundColor = .brandDisabled
  }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //nothing has changed, so disable
    }

    private var appliedFilters: [MarketFilter : String] {
        var applied = [MarketFilter : String]()
        for (filter, value) in filters {
            applied[filter] = value.first?.key //there is at most just one
        }
        return applied
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        self.delegate?.didFilter(filters: appliedFilters)
        self.reload(canApply: false)
        self.dismiss(animated: true)
    }
    
    func reload(canApply: Bool) {
        self.applyFiltersBtn.backgroundColor = canApply ? UIColor.brandPurple : UIColor.brandDisabled
        self.applyFiltersBtn.isEnabled = canApply
        self.tableView.reloadData()
    }
    
    @objc func close(recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}

protocol FiltersDelegate: class {
    var filters: [MarketFilter:[String:Bool]] {get}
    func isActive(type:MarketFilter, value: String) -> Bool
    func reload(canApply: Bool)
}

extension MarketListFilterTableViewController: FiltersDelegate {
    func isActive(type:MarketFilter, value: String) -> Bool {
        return self.filters[type]?[value] != nil
    }
}

extension MarketListFilterTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return origins.count
        case 1: return profiles.count / 2 + 1 //2 per row
        default: return certifications.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: MarketListFilterHeaderViewCell.reuseIdentifier) as! MarketListFilterHeaderViewCell
        
        cell.label.text = ["Origin", "Roast Profile", "Certification"][section]

        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketListFilterTableViewCell.reuseIdentifier) as! MarketListFilterTableViewCell
            cell.delegate = self
            cell.load(type: .origin, name: origins[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketListFilterDualTableViewCell.reuseIdentifier) as! MarketListFilterDualTableViewCell
            
            let first =  profiles[indexPath.row * 2]
            let second = (indexPath.row * 2 + 1) < profiles.count ? profiles[indexPath.row * 2 + 1] : nil
            cell.delegate = self
            cell.load(first: first, second: second)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MarketListFilterTableViewCell.reuseIdentifier) as! MarketListFilterTableViewCell
            cell.delegate = self
            cell.load(type: .certification, name: certifications[indexPath.row])
            return cell
        }
    }
    

}

class MarketListFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    weak var delegate: FiltersDelegate!
    var value: String?
    var type: MarketFilter = .origin
    
    override func awakeFromNib() {
        self.label.onTap(target: self, selector: #selector(toggle))
    }

    func load(type: MarketFilter, name: String?) {
        self.type = type
        self.value = name
        self.label.text = name
        
        if let value = self.value
        {self.label.textColor = self.delegate.isActive(type: type, value: value) ? UIColor.brandJolt : UIColor.white}

    }
    
    @objc func toggle() {
        self._toggle(type:type, value: self.value, delegate: self.delegate)
    }
}
//
class MarketListFilterHeaderViewCell: MarketListFilterTableViewCell {
}

class MarketListFilterDualTableViewCell: UITableViewCell {
    
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UILabel!
    
    weak var delegate: FiltersDelegate!
    
    var value: (String?, String?)

    override func awakeFromNib() {
        self.first.onTap(target: self, selector: #selector(toggle1))
        self.second.onTap(target: self, selector: #selector(toggle2))
    }

    func load(first: String?, second: String?) {
        self.value = (first, second)
        self.first.text = first
        self.second.text = second
        
        if let value1 = self.value.0
        {self.first.textColor = self.delegate.isActive(type: .profile, value: value1) ? UIColor.brandJolt : UIColor.white}
        
        if let value2 = self.value.1
        {self.second.textColor = self.delegate.isActive(type: .profile, value: value2) ? UIColor.brandJolt : UIColor.white}

    }
    
    @objc func toggle1() {
        self._toggle(type: .profile, value: self.value.0, delegate: self.delegate)
    }
    @objc func toggle2() {
        self._toggle(type: .profile, value: self.value.1, delegate: self.delegate)
    }
}

extension UITableViewCell {
    func _toggle(type:MarketFilter, value: String?, delegate: FiltersDelegate?) {
        guard let value = value, let delegate = delegate else {return }
        if delegate.filters[type]?[value] == nil{
            //first, blow away competitors. then set ourselves
            MarketListFilterTableViewController.filters[type] = [String:Bool]()
            MarketListFilterTableViewController.filters[type]?[value] = true
        } else {
            MarketListFilterTableViewController.filters[type]?.removeValue(forKey: value)
        }
        delegate.reload(canApply: true)
    }
}
