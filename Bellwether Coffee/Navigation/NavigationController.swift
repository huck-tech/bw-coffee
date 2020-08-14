//
//  NavigationController.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit
import OneSignal

class NavigationController: UINavigationController {
    
    var navigationViewControllers: [UIViewController]!
    
    lazy var dashboard: DashboardViewController = {
        let dashboardController = DashboardViewController()
        dashboardController.title = "Dashboard"
        return dashboardController
    }()
    
    lazy var cart: CartViewController = {
        let cartController = CartViewController()
        cartController.title = "Cart"
        return cartController
    }()
    
    lazy var market: MarketViewController = {
        let marketController = MarketViewController()
        marketController.title = "Market"
        return marketController
    }()
    
    lazy var inventory: InventoryViewController = {
        let inventoryController = InventoryViewController()
        inventoryController.title = "Inventory"
        return inventoryController
    }()
    
    lazy var roasting: RoastingProcessViewController = {
        let roastingViewController = RoastingProcessViewController.bw_instantiateFromStoryboard()
        roastingViewController.title = "Roast"
        return roastingViewController
    }()
    
    lazy var roastLog: RoastLogBrowserViewController = {
        let roastLogViewController = RoastLogBrowserViewController.bw_instantiateFromStoryboard()
        roastLogViewController.title = "Roast Log"
        return roastLogViewController
    }()
    
    lazy var orderHistory: OrderHistoryViewController = {
        let orderHistoryViewController = OrderHistoryViewController.bw_instantiateFromStoryboard()
        orderHistoryViewController.title = "Order History"
        return orderHistoryViewController
    }()
    
    lazy var settings: AdminSettingsViewController = {
        let settingsController = AdminSettingsViewController.bw_instantiateFromStoryboard()
        settingsController.title = "Settings"
        let _ = settingsController.view
        
        return settingsController
    }()
    
    var loginCompletion: (() -> Void)?
    
    lazy var sidebar: SidebarViewController = {
        let sidebarController = SidebarViewController()
        sidebarController.modalTransitionStyle = .crossDissolve
        sidebarController.modalPresentationStyle = .overCurrentContext
        return sidebarController
    }()
    
    var navBar: NavigationBar = {
        let navigationBar = NavigationBar(frame: .zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    var loadingView: UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.brandBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isAppeared = false
    
    var rightNavigationButton: NavigationButton? {
        didSet { updateRightNavigationButton() }
    }
    
    var contactNavigationButton: NavigationButton? {
        didSet { updateContactNavigationButton() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        addLoadingScreen()
        
        //make sure that we can connect to RPis with invalid certs, because they lack a domain name
        self.acceptInvalidSSLCerts()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshAuth(showsLoginIfNeeded: true)
        showSplash()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleCartUpdate),
                                               name:  .shouldUpdateCart,
                                               object: nil)
    }
    
    func setupNavigation() {
        setupNavigationBar()
        
        addControllers()
        addSidebarItems()
    }
    
    func addLoadingScreen() {
        view.addSubview(loadingView)
        
        loadingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setupNavigationBar() {
        delegate = self
        isNavigationBarHidden = true
        
        view.addSubview(navBar)
        
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        navBar.menuAction = { self.present(self.sidebar, animated: false) }
        
        rightNavigationButton = NavigationButton(image: UIImage(named: "nav_cart"), action: { [unowned self] in
            self.showCart()
        })
        
        contactNavigationButton = NavigationButton(image: UIImage(named: "nav_contact"), action: { [unowned self] in
            self.showContact()
        })
    }
    
    func addControllers() {
        var controllers = [UIViewController]()
        
        controllers.append(dashboard)
        controllers.append(market)
        controllers.append(inventory)
        controllers.append(roasting)
        controllers.append(roastLog)
        controllers.append(orderHistory)
        controllers.append(settings)
        
        let logout: UIViewController = {
            let logout = LogoutViewController()
            logout.title = "Logout"
            return logout
        }()

        
        controllers.append(logout)
        
        navigationViewControllers = controllers
    }
    
    func addSidebarItems() {
        sidebar.items = navigationViewControllers.map { viewController in
            let controllerTitle = viewController.title ?? ""
            
            return SidebarItem(name: controllerTitle) { [unowned self] in
                
                if let logoutViewController = viewController as? LogoutViewController {
                    return logoutViewController.logout()
                }
                
                self.navBar.titleText = controllerTitle
                self.setViewControllers([viewController], animated:true) {
                }
            }
        }
        
        // select the first item by default
        sidebar.items.first?.action?()
    }
    
    func setupSidebarItems() {
        refreshAuth(showsLoginIfNeeded: true)
    }
    
    // TODO: These are getting innefiecient. implement Gabe's magic view controller stack
    
    func showCart() {
        let controllerTitle = cart.title ?? ""
        self.navBar.titleText = controllerTitle
        self.setViewControllers([cart], animated: true)
    }
    
    func showContact() {
        let contactController = ContactViewController()
        contactController.modalPresentationStyle = .overCurrentContext
        contactController.modalTransitionStyle = .crossDissolve
        present(contactController, animated: true)
    }
    
    func showDashboard() {
        let controllerTitle = dashboard.title ?? ""
        self.navBar.titleText = controllerTitle
        self.setViewControllers([dashboard], animated: true)
    }
    
    func showMarket(index: Int) {
        let controllerTitle = market.title ?? ""
        self.navBar.titleText = controllerTitle
        self.setViewControllers([market], animated: true)
        
        market.selectListBean(index: index)
    }
    
    func showInventory(_ tab: InventoryTab) {
        let controllerTitle = inventory.title ?? ""
        self.navBar.titleText = controllerTitle
        self.setViewControllers([inventory], animated: true)
        
        switch tab {
        case .green:
            inventory.tabs.selectGreen()
        case .order:
            inventory.tabs.selectOrder()
        case .roasted:
            inventory.tabs.selectRoasted()
        }
    }
    
    func showRoast(greenItem: GreenItem? = nil, profile: RoastProfile? = nil) {
        let controllerTitle = roasting.title ?? ""
        self.navBar.titleText = controllerTitle
        
        //optionally go into the roasting screens with a pre-loaded roast profile, but only if we are not already roasting
        if Roasting.roasting.state == .none, let greenItem = greenItem, let profile = profile {
            roasting.set(greenItem: greenItem, profile: profile)
        }
        
        self.setViewControllers([roasting], animated: true)
    }
    
    func showSplash() {
        guard !isAppeared else { return }
        isAppeared = true
        
        let onboardingController = SplashViewController()
        onboardingController.delegate = self
        onboardingController.modalTransitionStyle = .crossDissolve
        onboardingController.modalPresentationStyle = .overCurrentContext
        present(onboardingController, animated: false, completion: { [unowned self] in
            self.loadingView.isHidden = true
        })
    }
    
    func showOnboarding() {
        let onboardingController = OnboardingViewController()
        onboardingController.delegate = self
        onboardingController.modalTransitionStyle = .crossDissolve
        onboardingController.modalPresentationStyle = .overCurrentContext
        present(onboardingController, animated: true)
    }
    
    func refreshAuth(showsLoginIfNeeded: Bool) {
        sidebar.profileInfo = BellwetherAPI.auth.currentProfileInfo
    }
    
    func updateRightNavigationButton() {
        navBar.rightNavButton = rightNavigationButton
    }
    
    func updateContactNavigationButton() {
        navBar.contactNavButton = contactNavigationButton
    }
    
    func updateDashboard() {
        dashboard.inventory.loadGreen()
    }
    
    func updateCart() {
        BellwetherAPI.orders.getCart { orderItems in
            guard let cartItems = orderItems else { return self.showNetworkError(message: "Cannot get your shopping cart.") }
            self.cart.cart = cartItems
            self.navBar.rightBadgeNumber = cartItems.count
        }
    }
    
    @objc func handleCartUpdate() {
        updateCart()
    }
    
    fileprivate func registerForRemoteNotifications(){
        OneSignal.promptForPushNotifications(userResponse: {accepted in
            if accepted {
                //save install information
                AppInstall.save()
            }
        })
    }
    
}

extension NavigationController: SplashViewControllerDelegate {
    
    func splashDidLogin() {
        updateDashboard()
        updateCart()
        self.dashboard.roast.loadRoastSchedule()
//        RoasterBLEDeviceDatabase.shared.startGladys()
        RoastLogDatabase.shared.load()
        self.registerForRemoteNotifications()
        
        //save an app install record. note that this will
        AppInstall.save()
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationAnimator()
    }
    
}

extension NavigationController: AuthViewControllerDelegate {
    
    func loginDidAuthenticateSuccessfully() {
        refreshAuth(showsLoginIfNeeded: false)
        
        updateDashboard()
        updateCart()
    }
}

extension NavigationController: OnboardingViewControllerDelegate {
    
    func onboardingDidFinish(_ onboarding: OnboardingViewController) {
        refreshAuth(showsLoginIfNeeded: true)
    }
    
}

extension UINavigationController {
    func setViewControllers(_ controllers: [UIViewController], animated:Bool, completion: @escaping VoidHandler) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {completion()}
        self.setViewControllers(controllers, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, _ completion: @escaping VoidHandler) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
}
