//
//  OrderHistoryViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SwiftDate

class OrderHistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var orders = [Order](){
        didSet {tableView.reloadData()}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func load(){
        let endpoint = "/orders/history" //BellwetherAPI.auth.isBellwetherUser ? "/orders/all" : "/orders/history"
        SpeedyNetworking.get(route: endpoint) { response in
            guard let responseOrders = response.jsonResults(model: [[String:Any]].self) else { return }
            self.orders = responseOrders.map {dict in
                let rawItems: [[String:Any]]? = dict["items"] as? [[String:Any]]
                let items: [OrderItem] = rawItems?.map {itemDict in
                        return OrderItem(_id: itemDict["_id"] as? String, bean: itemDict["bean"] as? String, name: itemDict["name"] as? String, price: itemDict["price"] as? Double, quantity: itemDict["quantity"] as? Double, totalPrice: itemDict["totalPrice"] as? Double/*, createdDate: itemDict["createdDate"] as? String, orderNumber: itemDict["orderNumber"] as? String, imported: itemDict["imported"] as? Int*/)
                    } ?? []
                return Order(_id: dict["_id"] as? String, orderNumber: dict["orderNumber"] as? Int, status: dict["status"] as? String, items: items, totalPrice: dict["totalPrice"] as? Double, shipment: dict["shipment"] as? String, paymentType: dict["paymentType"] as? String, paymentDescription: dict["paymentDescription"] as? String, createdBy: dict["createdBy"] as? String, createdDate: dict["createdDate"] as? String)
                }.compactMap {$0} . filter{$0.status != "carted"} .  limit(max: 40) . reversed()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.load()
    }
}

extension Array {
    //alternative to the prefix method that returns an array, not a slice
    func limit(max: Int) -> Array {
        guard max > self.count else {return self}
        return self.enumerated().filter{(arg) -> Bool in let (index, _) = arg; return index < max}.map{$1}
    }
}

class OrderHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var orderState: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var orderNum: UILabel!
    @IBOutlet weak var coffee: UILabel!
    @IBOutlet weak var pounds: UILabel!
    @IBOutlet weak var perpound: UILabel!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var payment: UILabel!
    
    func load(order: Order, isEven: Bool){
        self.backgroundColor = isEven ? UIColor.bw_color09 : UIColor.white
        
        if let status = order.status { //
            let orderStatus = OrderStatus(rawValue: status)
            self.orderState.text = orderStatus?.translation
            self.orderState.textColor = UIColor.black   //orderStatus == .ordered ? UIColor.black : UIColor.brandPurple
            self.orderState.font = UIFont.brandPlain    // orderStatus == .ordered ? UIFont.brandPlain : UIFont.brandBold
        } else {
            self.orderState.text = ""
        }
        
        self.date.text = order.createdDate?.date(format: .iso8601Auto)?.string(dateStyle: .short, timeStyle: .none)
        self.orderNum.text = order.orderNumber?.description
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        
        if let items = order.items {
            self.coffee.numberOfLines = items.count
            self.pounds.numberOfLines = items.count
            self.perpound.numberOfLines = items.count
            
            self.coffee.text = items.compactMap{$0.name}.map{"\($0)\n"}.reduce("", +)
            self.pounds.text = items.compactMap{$0.quantity?.asInt.description}.map{"\($0)\n"}.reduce("", +)
            
            
            self.perpound.text = items.map{item -> Double? in
                //get price per pound for each item
                guard let quantity = item.quantity, let price = item.totalPrice else {return nil}
                return price / quantity
                }.compactMap{priceFormatter.string(for: $0)}.map{"\($0)\n"}.reduce("", +)
        }
        
        self.orderTotal.text = priceFormatter.string(for: order.totalPrice)
        self.payment.text = "\(order.paymentType ?? "") \(order.paymentDescription ?? "")"
    }
}

extension OrderHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "Header")
    }
}

extension OrderHistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewCell.reuseIdentifier) as! OrderHistoryTableViewCell
        cell.load(order: orders[indexPath.row], isEven: indexPath.row % 2 == 0)
        return cell
    }
}

