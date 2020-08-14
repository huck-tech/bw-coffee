//
//  BeanLearnMoreViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/10/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Pages
import SnapKit
//import SwiftCSV
import SwiftyAttributes
import UIView_draggable

class Database {
    static let shared = Database()
    
    func build() {
//        guard let url = Bundle.main.url(forResource: "export", withExtension: "") else {return print("Bundle.main.url failed")}
//        guard let csv = try? CSV.init(url: url) else {return print("try? failed")}
//        csv.enumeratedRows.forEach{row in
//
//        }
    }
    
    private var _beans = [Bean]()
    
    var beans: [Bean] {
        return self._beans
    }
    var bean: Bean? {
        return self.beans.first
    }

    func coordinates(for bean: Bean?) -> (CGFloat, CGFloat)? {
        guard let name = bean?.name else {return nil}
        return nil
    }
}
class BeanLearnMoreViewController: UIViewController {
    @IBOutlet weak var pageContainer: UIView!

    var photoController: PagesController?
    weak var flavorWheel: BeanFlavorWheelViewController!
    
    @IBOutlet weak var whyWeLoveIt: UITextView!
    @IBOutlet weak var socialImpact: UITextView!
    @IBOutlet weak var cuppingNotes: UITextView!
    @IBOutlet weak var farmStory: UITextView!
    @IBOutlet weak var details1: UITextView!
    @IBOutlet weak var details2: UITextView!

    @IBOutlet weak var impactMetric1: UIView!
    @IBOutlet weak var impactMetric2: UIView!
    @IBOutlet weak var impactMetric3: UIView!
    @IBOutlet weak var ping: UIImageView!
    
    @IBOutlet weak var coffeName: UILabel!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var coffeeDetails: UILabel!
    @IBOutlet weak var dismissBtn: UIImageView!
    
    var metricImageViews = [UIView]()
    var showHeader: Bool = true {
        didSet {
            header.snp.remakeConstraints {make in make.height.equalTo(showHeader ? 44.0 : 1.0) }
            coffeeDetails.snp.remakeConstraints {make in make.height.equalTo(showHeader ? 0.0 : 36.0)}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textViews.forEach{$0.contentOffset = .zero}
    }

    private var bean: Bean?
    
    func set(bean: Bean) {
        self.bean = bean
        self.load()
    }
    
    func loadImpactMetrics(bean: Bean) {
        guard let name = bean.name else {return}
        
        metricImageViews.forEach{$0.alpha = 0}        //clear the images
        if name.contains("Mujeres") {
            metricImageViews.forEach {$0.alpha = 1} //all
        } else if name.contains("Maraba") {
            metricImageViews.forEach {$0.alpha = 1} // all
        } else if name.contains("Desta") {
            metricImageViews[0].alpha = 1 //environmental
        }
        
    }
    
    func loadImages(bean: Bean) {
        var _images: [UIImage]?
        
        if bean.photos != nil {
            guard let baseURL = SpeedyConfiguration.shared.defaultAppUrl else {return}
            _images = bean.photos?
                .map {"\(baseURL)\($0)"}
                .map {URL.init(string: $0)} .compactMap {$0}
                .map {try? Data(contentsOf: $0)} .compactMap {$0}
                .map {UIImage.init(data: $0)} .compactMap {$0}
        }
        
        guard let images = _images else {return}
        
        //get rid of whatever was there
        self.photoController?.bw_removeFromContainerView()
        let pages = images.map{image -> ImageViewController in
            let page = ImageViewController.bw_instantiateFromStoryboard()
            let _ = page.view
            page.imageView.image = image
            return page
        }
        self.photoController = PagesController(pages)
        self.photoController?.showPageControl = true
        self.photoController?.enableSwipe = true
        self.bw_addViewController(photoController, toContainerView: pageContainer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ping.setDraggable(true)
        self.ping.enableDragging()
        self.ping.draggingMovedBlock = {view in
            print("2.\(view?.frame.origin.debugDescription ?? "<ping.moving>")")
        }
        self.flavorWheel.isEnabled = false
        self.metricImageViews = [impactMetric1,impactMetric2,impactMetric3]

        self.ping.snp.makeConstraints {make  in
            make.top.equalTo(ping.superview!.snp.top).offset(0)
            make.left.equalTo(ping.superview!.snp.left).offset(0)
        }
        
        header.snp.makeConstraints {make in make.height.equalTo(showHeader ? 44.0 : 0.0) }
        coffeeDetails.snp.makeConstraints {make in make.height.equalTo(showHeader ? 0.0 : 36.0)}
        dismissBtn.onTap(target: self, selector: #selector(close))
        coffeName.onTap(target: self, selector: #selector(close))
    }
    
    private func loadPing() {
        ping.alpha = 0.0
        guard let coordinates = Database.shared.coordinates(for: self.bean) else {return}
        self.ping.snp.remakeConstraints {make  in
            make.top.equalTo(ping.superview!.snp.top).offset(coordinates.0)
            make.left.equalTo(ping.superview!.snp.left).offset(coordinates.1)
        }
    }
    
    private var textViews: [UITextView] {
        return [farmStory, cuppingNotes, whyWeLoveIt, socialImpact, details1, details2]
    }
    private func loadInfo() {
        guard let bean = self.bean, let beanId = bean._id else {return}
        
        self.coffeName.text = self.bean?._name
        farmStory.attributedText = "Farm Story: ".withFont(UIFont.brandBold) + (bean.story ?? "").withFont(UIFont.brandPlain)
        
        let readableCuppingNotes = bean.readableCuppingNotes ?? ""
        BellwetherAPI.roastProfiles.getRoastProfiles(bean: beanId) {[weak self] profiles in
            guard let _self = self, let profiles = profiles else {return print("no roast profiles")}
            
            let readableProfiles = "\n" + profiles.map{$0.name}.flatMap{$0}.joined(separator: ", ")
            self?.cuppingNotes.attributedText = "Roast profiles + cupping notes: \n".withFont(UIFont.brandBold)
                + readableCuppingNotes.withFont(UIFont.brandPlain)
                + readableProfiles.withFont(UIFont.brandPlain)
        }
        
        whyWeLoveIt.attributedText = "Why we love it: ".withFont(UIFont.brandBold) + (bean.whyWeLoveIt ?? "").withFont(UIFont.brandPlain)
        socialImpact.attributedText = "Impact: ".withFont(UIFont.brandBold) + (bean.impact ?? "").withFont(UIFont.brandPlain)
    
        
        details1.attributedText = render(keyValues: [("Grower", bean.grower),
                                                     ("Certification", bean.certification?.readableSet()),
                                                     ("Variety", bean.variety),
                                                     ("Process", bean.process)])
        details2.attributedText = render(keyValues: [("Region", bean.location),
                                                     ("Elevation", "\(bean.elevation ?? "")")])
        textViews.forEach{$0.contentOffset = .zero}
    }
    
    private func render(keyValues: [(String,String?)]) -> NSAttributedString? {
        let components = keyValues.map {"\($0.0): ".withFont(UIFont.brandBold) + "\($0.1 ?? "")\n".withFont(UIFont.brandPlain)}
        let result = NSMutableAttributedString.init()
        components.forEach{result.append($0)}
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8.0
        
        return result.withParagraphStyle(style)
    }
    
    func load() {
        let _ = view //ensure the outlets are filled out. Why is this necessary? @fixme
        guard let bean = bean else {return print("BeanLearnMoreViewController.load() with bean == nil")}
        self.loadInfo()
        self.flavorWheel.set(bean: bean)
        self.loadImpactMetrics(bean: bean)
        self.loadImages(bean: bean)
        self.loadPing()
        self.loadInfo()
    }

    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)

        if let child = childController as? BeanFlavorWheelViewController {
            self.flavorWheel = child
        }
    }
    
    @objc func close() {
        //this only applies when we are presented full-screen
        self.navigationController?.popViewController(animated: true)
    }
}

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @objc func close() {self.dismiss(animated: true)}
}

extension UITextView {
    func setContent(title: String, text: String) {
        
    }
}

extension UIFont {
    static let brandBold = UIFont(name: "AvenirNext-Medium", size: 16.0)!
    static let brandPlain = UIFont(name: "AvenirNext-Regular", size: 16.0)!

}
