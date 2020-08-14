//
//  BeanDetailViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 4/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import SwiftDate

class BeanDetailViewController: UIViewController {
    
    var bean: Bean? {
        didSet { updateDetail() }
    }
    
    var greenItem: GreenItem? {
        didSet { updateDetail() }
    }
    
    var roastProfiles = [RoastProfile]() {
        didSet { updateRoastProfiles() }
    }
    
    var roastProfileActions: [BeanDetailRoastProfileAction] = [
        BeanDetailRoastProfileAction(name: "Prepare") {
            
            guard !Roaster.shared.firmwareUpdating else {
                return RoastingProcessViewController.showRoasterUpdating()
            }
            
            guard RoastingProcess.roasting.state == .none else {
                return RoastingProcessViewController.showRoasterBusy()
            }
            
            guard Roaster.shared.isReadyForNewRoast else {
                return RoastingProcessViewController.showRoasterNotReady()
            }

            AppDelegate.navController?.showRoast(greenItem: RoastingProcess.editing.greenItem, profile: RoastingProcess.editing.roastProfile?.asRoastProfile)
        },
        
        BeanDetailRoastProfileAction(name: "Schedule") {
            RoastScheduleController.shared.scheduleRoast()
        },
        
        BeanDetailRoastProfileAction(name: "Edit") {
            let controller = RoastProfileEditorViewController.bw_instantiateFromStoryboard()
            controller.editMode = .edit
            AppDelegate.navController?.pushViewController(controller, animated: true)
        },
        
        BeanDetailRoastProfileAction(name: "Duplicate") {
            let controller = RoastProfileEditorViewController.bw_instantiateFromStoryboard()
            controller.editMode = .duplicate
            AppDelegate.navController?.pushViewController(controller, animated: true)
        },
        
        BeanDetailRoastProfileAction(name: "Copy to") {
            let pickerViewController = GreenItemPickerViewController.bw_instantiateFromStoryboard()
            pickerViewController.handler = {greenItem in
                guard let beanId = greenItem?.bean else {return}
                
                guard let profile = RoastingProcess.editing.roastProfile?.asRoastProfile(for: beanId, _id:RoastingProcess.editing.roastProfile?.metadata?.id) else {return print("Copy To: could not generate roast profile")}

                BellwetherAPI.roastProfiles.create(profile: profile) {success in
                    // invalidate the cache of roast profiles when a user deletes an existing profile
                    if let bean = profile.bean {
                        RoastLogDatabase.shared.beanProfiles[bean] = nil
                    }
                    guard success else {
                        return print ("Could not copy profile.")
                    }
                }
            }
            
            AppDelegate.visibleViewController?.definesPresentationContext = true
            pickerViewController.modalTransitionStyle = .crossDissolve
            pickerViewController.modalPresentationStyle = .overCurrentContext
            AppDelegate.visibleViewController?.present(pickerViewController, animated:true)
        },
        
        BeanDetailRoastProfileAction(name: "X") {
            guard let name = RoastingProcess.editing.roastProfile?.metadata?.name else {return}
            let alert = ConfirmActionAlert.build(title: "Are you sure you want to delete the \(name) roast profile?", ok: "Delete"){
                confirmed in
                
                guard confirmed else {return}
                
                guard let beanId = RoastingProcess.editing.greenItem?.bean,
                    let profile = RoastingProcess.editing.roastProfile?.asRoastProfile,
                    let profileId = profile._id else {
                        return print("could not generate roast profile")
                }

                BellwetherAPI.roastProfiles.delete(profile: profileId, completion: {success in
                    guard success else {return print("Could not edit roast profile.")}
                    let detail = AppDelegate.navController?.viewControllers.last as? BeanDetailViewController
                    detail?.reloadProfiles()
                })
            }
            AppDelegate.visibleViewController?.present(alert, animated: true)
        }
    ]
    
    var navBar: NavigationBar = {
        let navigationBar = NavigationBar(frame: .zero)
        navigationBar.menu.isHidden = true
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    var header: BeanDetailHeaderView = {
        let headerView = BeanDetailHeaderView(frame: .zero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var profileList: BeanDetailRoastProfileListView = {
        let profileListView = BeanDetailRoastProfileListView(frame: .zero)
        profileListView.delegate = self
        profileListView.translatesAutoresizingMaskIntoConstraints = false
        return profileListView
    }()
    
    var profileGraph: RoastProfileGraphViewController = {
        let graphController = RoastProfileGraphViewController.bw_instantiateFromStoryboard()
        graphController.view.translatesAutoresizingMaskIntoConstraints = false
        return graphController
    }()
    
    lazy var profileActions: BeanDetailRoastProfileActionView = {
        let actionView = BeanDetailRoastProfileActionView(frame: .zero)
        actionView.actions = roastProfileActions
        actionView.translatesAutoresizingMaskIntoConstraints = false
        return actionView
    }()
    
    var belowFoldPlaceholder: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let learnMore = BeanLearnMoreViewController.bw_instantiateFromStoryboard()
    
    //support going back to where we were upon viewWillAppear(), since items might have changed in the meantime
    var lastSelectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Learn More"
        navBar.titleText = title
        
        setupAppearance()
        setupLayout()
        setupNavBar()
        setupLearnMore()
    }
    
    func setupNavBar() {
        navBar.rightNavButton = NavigationButton(image: UIImage(named: "close")) { [unowned self] in
            self.dismiss(animated: true)
        }
    }
    
    func updateDetail() {
        if let updatedGreenItem = greenItem {
            header.name = updatedGreenItem._name
            header.lbsAvailable = updatedGreenItem.quantity
            
            loadGreenProfiles()
            loadLearnMore()

        }
    }
    func setupLearnMore() {
        let _ = learnMore.view
        learnMore.showHeader = false
    }
    func loadLearnMore() {

        if let bean = self.bean {
            return self.learnMore.set(bean: bean)
        }
        
        guard let beanId = self.greenItem?.bean else {return print("empty bean")}
        BellwetherAPI.beans.getBean(id: beanId, completion: {[weak self] bean in
            guard let bean = bean else {return print("no bean")}
            self?.learnMore.set(bean: bean)
        })
    }
    
    func updateRoastProfiles() {
        profileList.profileList.collectionItems = roastProfiles
    }
    
    func loadGreenProfiles() {
        guard let updatedBean = greenItem?.bean else { return }
        loadProfiles(bean: updatedBean)
    }
    
    func reloadProfiles() {
        guard let beanId = self.greenItem?.bean else {return print("guard.fail @ \(#function)")}
        self.loadProfiles(bean: beanId)
    }
    
    func loadProfiles(bean: String) {
        BellwetherAPI.roastProfiles.getRoastProfiles(bean: bean) {[weak self] profiles in
            guard let _self = self, var fetchedProfiles = profiles else { return print("guard.fail @1 \(#function)")}
            
            //this is the '+ Create new profile' slot
            fetchedProfiles.insert(Defaults.shared.defaultRoastProfile, at: 0)
            
            _self.roastProfiles = fetchedProfiles
            
            //skp the 'create' profile if there is any alternative
            let defaultIndex = fetchedProfiles.count > 1 ? 1 : 0
            var index = _self.lastSelectedIndex ?? defaultIndex
            index = _self.roastProfiles.count > index ? index : 0 // just go to zero if we might overrun
            guard let profile = _self.roastProfiles[index].asBWRoastProfile else {return print("guard.fail @2 \(#function)")}
            
            _self.profileList.selectIndexListItem(index: index)
            _self.profileGraph.set(roastProfile: profile, isEditable: false)
            if index == 0 {
                _self.profileActions.isUserInteractionEnabled = false
                _self.profileActions.alpha = 0.5
            } else {
                _self.beanDetailDidSelectProfile(index: index)
           }
        }
    }
}

extension BeanDetailViewController: BeanDetailRoastProfileListViewDelegate {
    
    func beanDetailDidSelectProfile(index: Int) {
        guard let profile = self.roastProfiles[index].asBWRoastProfile else { return }
        
        //disable buttons if the user is creating a profile.
        profileActions.isUserInteractionEnabled = true
        profileActions.alpha = 1.0

        RoastingProcess.editing.greenItem = self.greenItem
        RoastingProcess.editing.roastProfile = profile
        
        //if we are actually looking at the 'Create New Profile' slot, then create instead
        guard index > 0 else {
            
            //only bw can create profiles at this time
            guard BellwetherAPI.auth.isBellwetherUser else {return}
            RoastingProcess.editing.roastProfile?.metadata?.name = "New Roast Profile"
            let controller = RoastProfileEditorViewController.bw_instantiateFromStoryboard()
            controller.editMode = .create
            AppDelegate.navController?.pushViewController(controller, animated: true)
            return
        }
        
        profileGraph.set(roastProfile: profile, isEditable: false)
        self.lastSelectedIndex = index
    }
}

// MARK: Layout

extension BeanDetailViewController {
    
    func setupAppearance() {
        view.backgroundColor = .white
    }
    
    func setupLayout() {
        view.addSubview(navBar)
        
        navBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navBar.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        view.addSubview(header)
        
        header.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(contentScrollView)
        
        contentScrollView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        contentScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentScrollView.addSubview(profileList)
        
        profileList.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        profileList.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        profileList.widthAnchor.constraint(equalToConstant: 400).isActive = true
        profileList.heightAnchor.constraint(equalToConstant: 428).isActive = true
        
//        addViewController(profileGraph)
        addChildViewController(profileGraph)
        
        contentScrollView.addSubview(profileGraph.view)
        profileGraph.didMove(toParentViewController: self)
        
        profileGraph.view.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 8).isActive = true
        profileGraph.view.leftAnchor.constraint(equalTo: profileList.rightAnchor, constant: 8).isActive = true
        profileGraph.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        profileGraph.view.heightAnchor.constraint(equalToConstant: 360).isActive = true
        
        contentScrollView.addSubview(profileActions)
        
        profileActions.topAnchor.constraint(equalTo: profileGraph.view.bottomAnchor, constant: 12).isActive = true
        profileActions.leftAnchor.constraint(equalTo: profileList.rightAnchor, constant: 36).isActive = true
        profileActions.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        profileActions.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        contentScrollView.addSubview(belowFoldPlaceholder)
        
        belowFoldPlaceholder.topAnchor.constraint(equalTo: profileList.bottomAnchor, constant: 36).isActive = true
        belowFoldPlaceholder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        belowFoldPlaceholder.widthAnchor.constraint(equalToConstant: 1024).isActive = true
        belowFoldPlaceholder.heightAnchor.constraint(equalToConstant: 1650).isActive = true
        belowFoldPlaceholder.alpha = 0.2
        
        learnMore.willMove(toParentViewController: self)
        learnMore.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(learnMore)
        contentScrollView.addSubview(learnMore.view)
        learnMore.didMove(toParentViewController: self)

        learnMore.view.topAnchor.constraint(equalTo: belowFoldPlaceholder.topAnchor).isActive = true
        learnMore.view.leftAnchor.constraint(equalTo: belowFoldPlaceholder.leftAnchor).isActive = true
        learnMore.view.rightAnchor.constraint(equalTo: belowFoldPlaceholder.rightAnchor).isActive = true
        learnMore.view.bottomAnchor.constraint(equalTo: belowFoldPlaceholder.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadGreenProfiles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentScrollView.contentSize = CGSize(width: view.bounds.width, height: belowFoldPlaceholder.frame.maxY)
    }
    
}

