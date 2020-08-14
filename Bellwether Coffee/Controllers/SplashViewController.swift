//
//  SplashViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/26/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit
import Parse

protocol SplashViewControllerDelegate: class {
    func splashDidLogin()
}

class SplashViewController: UIViewController {
    
    weak var delegate: SplashViewControllerDelegate?
    
    var logo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "menu_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateEntrance()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) { [unowned self] in
            self.presentLogin()
        }
    }
    
    func presentLogin() {
        let authFlowController = AuthFlowViewController.bw_instantiateFromStoryboard()
        authFlowController.delegate = self
        authFlowController.modalPresentationStyle = .overCurrentContext
        authFlowController.modalTransitionStyle = .crossDissolve
        self.present(authFlowController, animated: false){
            authFlowController.authenticate()
        }
    }

}

extension SplashViewController: AuthViewControllerDelegate {
    
    func loginDidAuthenticateSuccessfully() {
        animateExit()
        delegate?.splashDidLogin()
        self.registerLaunch()
    }
 
    
    private func registerLaunch(){
        let launch = PFObject.init(className: "AppLaunch")
        launch["build"] = Bundle.main.buildVersionNumber
        launch["email"] = BellwetherAPI.auth.currentProfileInfo?.subtitle
        launch["device_name"] = UIDevice.current.name
        launch["system_version"] = UIDevice.current.systemVersion
        launch.saveInBackground()
    }
}

// MARK: Layout

extension SplashViewController {
    
    func setupAppearance() {
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.brandBackground
    }
    
    func setupLayout() {
        view.addSubview(logo)
        
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 280).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        logo.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        logo.alpha = 0.0
    }
    
}

extension SplashViewController {
    
    func animateEntrance() {
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.logo.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.logo.alpha = 1.0
        })
    }
    
    func animateExit() {
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.logo.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.logo.alpha = 0.0
        }, completion: { [unowned self] finished in
            self.dismiss(animated: true)
        })
    }
    
}
