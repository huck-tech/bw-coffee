//
//  OnboardingViewController.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate {
    func onboardingDidFinish(_ onboarding: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    
    var delegate: OnboardingViewControllerDelegate?
    
    var pages: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var pageIndicator: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 1
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    var previousPage: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: 17)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .normal)
        button.contentHorizontalAlignment = .center
        button.setTitle("PREV", for: .normal)
        button.addTarget(self, action: #selector(selectPrevious), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var nextPage: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: 17)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .normal)
        button.contentHorizontalAlignment = .center
        button.setTitle("NEXT", for: .normal)
        button.addTarget(self, action: #selector(selectNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onboardingPages = [OnboardingPage]()
    var onboardingPageViews = [OnboardingPageView]()
    
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        
        setupLayout()
        loadOnboardingData()
    }
    
    func loadOnboardingData() {
        guard let onboardingUrl = Bundle.main.url(forResource: "OnboardingData", withExtension: "json") else { return }
        
        do {
            let onboardingData = try Data(contentsOf: onboardingUrl)
            onboardingPages = try JSONDecoder().decode([OnboardingPage].self, from: onboardingData)
        } catch {
            // handle however unlikely of an error
        }
        
        pageIndicator.numberOfPages = onboardingPages.count
        
        reloadOnboarding()
        updateToggleButtons()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //        layoutOnboarding(size: size)
        
        coordinator.animate(alongsideTransition: { context in
            self.layoutOnboarding(size: size)
            self.updateScrollPosition()
        }, completion: nil)
    }
    
    @objc func selectPrevious() {
        if currentPage <= 0 { return }
        
        currentPage -= 1
        updateScrollPosition()
    }
    
    @objc func selectNext() {
        if currentPage >= onboardingPages.count - 1 {
            dismiss(animated: true) { [unowned self] in
                self.delegate?.onboardingDidFinish(self)
            }
            
            return
        }
        
        currentPage += 1
        updateScrollPosition()
    }
    
    func updateToggleButtons() {
        if currentPage == 0 {
            previousPage.alpha = 0.5
        } else {
            previousPage.alpha = 1.0
        }
        
        if currentPage == onboardingPages.count - 1 {
            nextPage.setTitle("DONE", for: .normal)
        } else {
            nextPage.setTitle("NEXT", for: .normal)
        }
    }
    
}

// MARK: Layout

extension OnboardingViewController {
    
    func setupLayout() {
        pages.delegate = self
        view.addSubview(pages)
        
        pages.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pages.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pages.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pages.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [previousPage, pageIndicator, nextPage])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        stack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
}

// MARK: Layout Helpers

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateIndex()
        updateToggleButtons()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            calculateIndex()
            updateToggleButtons()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculateIndex()
        updateToggleButtons()
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        self.pages.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func calculateIndex() {
        currentPage = Int(round(pages.contentOffset.x / view.bounds.width))
        
        let page = onboardingPages[currentPage]
        pageIndicator.currentPage = currentPage
        
        guard let backgroundColor = page.backgroundColor else { return }
        
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(hex: backgroundColor)
        }
    }
    
    func updateScrollPosition() {
        let offset = view.bounds.width * CGFloat(currentPage)
        pages.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
}

extension OnboardingViewController {
    
    func reloadOnboarding() {
        onboardingPageViews.forEach { $0.removeFromSuperview() }
        onboardingPageViews.removeAll()
        
        onboardingPages.enumerated().forEach { index, page in
            let pageView = OnboardingPageView(frame: .zero)
            pageView.page = page
            pages.addSubview(pageView)
            
            onboardingPageViews.append(pageView)
        }
        
        layoutOnboarding(size: view.bounds.size)
        calculateIndex()
    }
    
    func layoutOnboarding(size: CGSize) {
        var endPoint = size.width
        
        onboardingPageViews.enumerated().forEach { index, pageView in
            let positionX = size.width * CGFloat(index)
            pageView.frame = CGRect(x: positionX, y: 0, width: size.width, height: size.height)
            endPoint = pageView.frame.maxX
        }
        
        pages.contentSize = CGSize(width: endPoint, height: size.height)
    }
    
}

