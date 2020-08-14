//
//  SidebarViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/27/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class SidebarViewController: UIViewController {
    
    var profileInfo: SidebarProfileInfo? {
        didSet { menu.reload() }
    }
    
    var items = [SidebarItem]() {
        didSet { menu.reload() }
    }
    
    lazy var menu: SidebarMenuView = {
        let menu = SidebarMenuView(frame: .zero)
        menu.delegate = self
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        profileInfo = BellwetherAPI.auth.currentProfileInfo
        
        BellwetherAPI.auth.profileUpdateHandler.listen { updatedProfileInfo in
            self.profileInfo = updatedProfileInfo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        present()
    }
    
    func setupAppearance() {
        view.isOpaque = false
        view.backgroundColor = UIColor(white: 0.1, alpha: 0.0)
        view.backgroundColor = false ? UIColor.brandJolt : UIColor(white: 0.1, alpha: 0.0)
    }
    
    func present() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.3, options: [], animations: {
            self.view.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
            self.menu.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.3, options: [.curveEaseIn], animations: {
            self.view.backgroundColor = UIColor(white: 0.1, alpha: 0.0)
            self.menu.transform = CGAffineTransform(translationX: -380, y: 0)
        }, completion: { [unowned self] finished in
            self.dismiss(animated: false)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss()
    }
    
}

extension SidebarViewController: SidebarMenuViewDelegate {
    
    func sidebarProfileInfo() -> SidebarProfileInfo {
        return profileInfo ?? defaultProfileInfo
    }
    
    func sidebarDidSelectProfileInfo() {
        profileInfo?.action?()
        dismiss()
    }
    
    func sidebarMenuItemForIndex(index: Int) -> SidebarItem {
        return items[index]
    }
    
    func sidebarMenuItemsCount() -> Int {
        return items.count
    }
    
    func sidebarMenuDidSelectItem(index: Int) {
        items[index].action?()
        dismiss()
    }
    
}

// MARK: Layout

extension SidebarViewController {
    
    func setupLayout() {
        view.addSubview(menu)
        
        menu.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menu.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menu.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menu.widthAnchor.constraint(equalToConstant: 280).isActive = true
        
        menu.transform = CGAffineTransform(translationX: -380, y: 0)
    }
    
}
