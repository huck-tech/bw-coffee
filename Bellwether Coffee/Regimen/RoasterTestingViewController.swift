//
//  RoasterTestingViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 12/10/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit

class RoasterTestingViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        RoasterTest.delegate = self
        RoasterTest.run {[weak self] tests, error in
            self?.confirm(title: "\(tests ?? 0) completed.", cancellable:false){_ in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

class RoasterTestingViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UIImageView!
    
    func load(test: RoasterTest){
        self.title.text = test.name
        switch test.status {
        case .none: status.image = nil
        case .working:
            status.image = UIImage.init(named: "processing.png")
            UIView.animate(withDuration: 4) {
                //rotate two radians
                self.status.transform = CGAffineTransform(rotationAngle: CGFloat(3*CGFloat.pi))
            }
        case .skipped: status.image = UIImage.init(named: "skipped.png")
        case .failure: status.image = UIImage.init(named: "failure.png")
        case .success: status.image = UIImage.init(named: "success.png")
        }
        
        //undo the rotation at the end of the test
        if test.status == .skipped || test.status == .failure || test.status == .success {
            self.status.transform = CGAffineTransform(rotationAngle: 0)
        }
    }
}

extension RoasterTestingViewController:TestDelegate {
    func statusDidChange(index: Int?, status: TestStatus) {
        guard let index = index else {return}
        
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension RoasterTestingViewController: UITableViewDelegate {}
extension RoasterTestingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoasterTest.working.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoasterTestingViewCell.reuseIdentifier) as! RoasterTestingViewCell
        cell.load(test: RoasterTest.working[indexPath.row])
        return cell
    }
}
