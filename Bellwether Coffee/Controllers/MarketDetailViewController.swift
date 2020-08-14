//
//  MarketDetailViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketDetailViewController: UIViewController {
    
    var bean: Bean? {
        didSet { updateBean() }
    }
    
    lazy var detailHeader: MarketDetailHeaderView = {
        let detailHeader = MarketDetailHeaderView(frame: .zero)
        detailHeader.actionHandler = handleMarketHeaderAction
        detailHeader.translatesAutoresizingMaskIntoConstraints = false
        return detailHeader
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var descriptionText: DynamicTextView = {
        let textView = DynamicTextView(frame: .zero)
        textView.delegate = self
        textView.textView.textContainer.lineFragmentPadding = 0
        textView.textView.textContainerInset = .zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var more: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        button.setTitleColor(.brandPurple, for: .normal)
        button.setTitle("Learn more about this coffee.", for: .normal)
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(learnMore), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    func loadContent() {
        guard let updatedBean = bean else { return }
        view.isHidden = false
        
        detailHeader.name.text =  updatedBean._name
        
        let renderer = MarketDetailsRenderer()
        renderer.addDetail(name: "Farm Story", content: updatedBean.story)
        renderer.addDetail(name: "Grower", content: updatedBean.grower)
        renderer.addDetail(name: "Tasting Notes", content: updatedBean.readableCuppingNotes)
        
        descriptionText.attributedText = renderer.renderedDetails
    }
    
    func loadPhoto() {
        guard let photo = bean?.photos?.first else { return }
        
        SpeedyNetworking.downloadImage(path: photo) { [weak self] image in
            guard photo == self?.bean?.photos?.first ?? "" else { return }
            
            self?.detailHeader.photo.image = image
        }
    }
    
    @objc func learnMore() {
        guard let bean = self.bean else {return}
        let learnMore = LearnMoreContainerViewController.bw_instantiateFromStoryboard()
        let _ = learnMore.view //force it to load; otherwise set(bean:) & dead
        learnMore.set(bean: bean)
        learnMore.learnMore?.showHeader = true
        learnMore.learnMore?.flavorWheel.isEnabled = false


        AppDelegate.navController?.pushViewController(learnMore, animated: true)
    }
    
    func orderBean() {
        guard let orderedBean = bean else { return }
        
        let addToCartController = MarketAddToCartViewController()
        addToCartController.delegate = self
        addToCartController.bean = orderedBean
        addToCartController.modalTransitionStyle = .crossDissolve
        addToCartController.modalPresentationStyle = .overCurrentContext
        present(addToCartController, animated: true)
    }
    
    func favoriteBean() {
        
    }
    
    func updateBean() {
        loadContent()
        loadPhoto()
    }
    
    func handleMarketHeaderAction(action: MarketDetailHeaderAction) {
        if action == .favorite { favoriteBean() }
        if action == .addToCart { orderBean() }
        if action == .learnMore { learnMore() }
    }
    
}

extension MarketDetailViewController: MarketAddToCartViewControllerDelegate {
    
    func marketCartAddedSuccessfully() {
        let navigation = navigationController as? NavigationController
        navigation?.updateCart()
    }
    
}

// MARK: Layout

extension MarketDetailViewController: DynamicTextViewDelegate {
    
    func setupAppearance() {
        view.isHidden = true
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(contentScrollView)
        
        contentScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(detailHeader)
        
        detailHeader.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        detailHeader.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        detailHeader.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        contentScrollView.addSubview(descriptionText)
        
        descriptionText.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        descriptionText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        descriptionText.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14).isActive = true
        
        contentScrollView.addSubview(more)
        
        more.topAnchor.constraint(equalTo: descriptionText.bottomAnchor).isActive = true
        more.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        more.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14).isActive = true
        
//        contentScrollView.addSubview(map)
//
//        map.topAnchor.constraint(equalTo: descriptionText.bottomAnchor).isActive = true
//        map.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
//        map.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14).isActive = true
//        map.heightAnchor.constraint(equalToConstant: 280).isActive = true
    }
    
    func textViewDidResize(newSize: CGSize) {
        let headerHeight = detailHeader.bounds.height
        
        let contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        contentScrollView.contentInset = contentInset
        contentScrollView.scrollIndicatorInsets = contentInset
        
        contentScrollView.contentSize = CGSize(width: view.bounds.width, height: more.frame.maxY + 20)
        contentScrollView.contentOffset = CGPoint(x: 0, y: -headerHeight)
    }
    
}
