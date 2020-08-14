//
//  RoastLogCommentsViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 6/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import MessengerKit
import SwiftDate
import Parse
import Alamofire
import SwiftyJSON

struct Commenter: MSGUser {
    
    var displayName: String
    var avatar: UIImage?
    var avatarUrl: URL?
    var isSender: Bool
    
}

class RoastLogCommentsContainerViewController: UIViewController {
    @IBOutlet weak var closeTapper: UIImageView!
    
    weak var controller: RoastLogCommentsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.closeTapper.onTap(target: self, selector: #selector(close))
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let child = childController as? RoastLogCommentsViewController {
            self.controller = child
        }
    }
}

class RoastLogCommentsViewController: MSGMessengerViewController {
    
    static func showComments(for roastLog: RoastLog? = nil) {
        let container = RoastLogCommentsContainerViewController.bw_instantiateFromStoryboard()
        let _ = container.view //force load
        container.controller?.roastLog = roastLog
        
        container.modalTransitionStyle = .crossDissolve
        container.modalPresentationStyle = .overCurrentContext
        AppDelegate.visibleViewController?.present(container, animated: true)
    }
    
    var comments: [RoastLogComment] = [] {
        didSet {
            var messages = self.comments.enumerated().map {(arg: (offset: Int, element: RoastLogComment)) -> MSGMessage in
                
                let (index, comment) = arg
                let user = self.commenterFor(fullname: comment.roaster, email: comment.roasterId)
                let sentAt = (comment.sentAt ?? comment.createdAt) ?? Date()
                return MSGMessage.init(id: index, body: .text(comment.comment ?? ""), user: user, sentAt: sentAt)
                }.map {[$0]}
            messages.insert([initialMessage], at: 0) //always start the convo with a prompt
            self.messages = messages.filter {$0.count > 0} //remove empty lists
            self.collectionView.reloadData(){[weak self] in
                self?.collectionView.scrollToBottom(animated: false)
            }
        }
    }
    
    var roastLog: RoastLog?
    
    override var style: MSGMessengerStyle {
        return MessengerKit.Styles.iMessage
    }
    
    var commenters = [String: Commenter]()
    
    fileprivate var bellwetherLogo: UIImage? {
        return UIImage.init(named: "Bellwether_Logo")
    }
    
    /*  Returns whether the email corresponds to the currently logged-in user
     */
    private func isCurrentUser(_ email: String) -> Bool {
        return BellwetherAPI.auth.currentProfileInfo?.subtitle == email
    }
    
    /*  Backup anonymous user if there are any nil fields
     */
    private lazy var anonymous: Commenter = {
        return Commenter.init(displayName: "The Team", avatar: bellwetherLogo, avatarUrl: nil, isSender: false)
    } ()
    
    /*  Create commenter with the given fullname and email; assumes it does not already exist
     */
    fileprivate func createCommenter(for fullname: String, email: String) -> Commenter {
        let commenter = Commenter.init(displayName: fullname, avatar: nil, avatarUrl: nil, isSender: isCurrentUser(email))
        self.commenters[email] = commenter
    
        return commenter
    }
    
    
    /*  Returns the currently logged-in commenter
     */
    fileprivate func currentCommenter() -> Commenter {
        guard let fullname = BellwetherAPI.auth.currentProfileInfo?.title,
            let email = BellwetherAPI.auth.currentProfileInfo?.subtitle else {
            return anonymous
        }
        
        return commenterFor(fullname: fullname, email: email)
    }
    
    fileprivate func commenterFor(fullname: String?, email: String?) -> Commenter {
        guard let fullname = fullname, let email = email else {return anonymous}
        
        guard let commenter = commenters[email] else {
            //if we do not have this commenter yet, add them to our hash table and return a new one
            return createCommenter(for: fullname, email:email)
        }
        
        return commenter
    }
    
    private var initialMessage: MSGMessage  {
        return MSGMessage.init(id: 0, body: .text("How did it go?"), user: anonymous, sentAt: Date())
    }
    
    lazy var messages : [[MSGMessage]] = [[initialMessage]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
    }
    
    private func load(log: RoastLog){
        let query = RoastLogComment.query()?.whereKey("roastLog", equalTo: roastLog as Any)
        query?.whereKey("cafe", equalTo: BellwetherAPI.auth.cafe ?? "")
        query?.order(byAscending: "createdAt")
        query?.whereKey("createdAt", greaterThan: RoastLog.maxDays.day.ago() as Any)

        
        
        let start = ProcessInfo.processInfo.systemUptime
        query?.findObjectsInBackground {[weak self] results, error in
            let end = ProcessInfo.processInfo.systemUptime
            print("RoastLogComment.findObjectsInBackground(\(end - start))")
            
            guard let results = results as? [RoastLogComment] else {return print("failed to retrieve comments")}
            
            self?.comments = results //this will cause a UI reload
        }
    }
    
    
    private func loadRoastEvents() {
        
        //we start by turning the roast log nto a family of comments
        var comments: [RoastLogComment] = RoastLog.roastLogs.map{roastLog in
            guard let beanId = roastLog.bean, let bean = RoastLogDatabase.shared.beans[beanId]?.name,
                let roastProfileId = roastLog.profile, let profile = RoastLogDatabase.shared.profiles[roastProfileId]?.name else {return nil}
            let comment = RoastLogComment()
            comment.roaster = roastLog.roaster
            comment.roasterId = roastLog.roaster
            let onRoaster: String
            if let name = roastLog.machine {onRoaster = " on \(name)"} else {onRoaster = ""}
            comment.comment = "Roast \(bean) with the \(profile) profile\(onRoaster)."
            comment.sentAt = roastLog.date ?? roastLog.createdAt
            return comment
        } .compactMap{$0} //remove the nils
        
        /// get the comments over the past five days
        guard let commentsQ = RoastLogComment.query()?.order(byAscending: "createdAt")
            .whereKey("cafe", equalTo: BellwetherAPI.auth.cafe ?? "")
            .whereKey("createdAt", greaterThan: RoastLog.maxDays.day.ago() as Any) else {return print("could not build query(1)")}
        
        guard let eventsQ = RoastEvent.query()?.order(byAscending: "createdAt")
            .whereKey("cafe", equalTo: BellwetherAPI.auth.cafe ?? "")
            .whereKey("createdAt", greaterThan: RoastLog.maxDays.day.ago() as Any) else {return print("could not build query(2)")}

        commentsQ.findObjectsInBackground {objects, error in
            guard let objects = objects as? [RoastLogComment] else {return print("could not retrieve roast comments")}
            
            //add in all the comments
            comments.append(contentsOf: objects)
            eventsQ.findObjectsInBackground(block: {[weak self] events, error in
                guard let  events = events as? [RoastEvent] else {return print("could not retrieve roast events")}
                //convert all the events into comments
                let eventComments: [RoastLogComment] = events.map {event in
                    guard let code = event.state?.intValue, let state = BWRoasterDeviceRoastState.init(rawValue: code),
                        let roaster = event.roaster else {return nil}
                    
                    let comment = RoastLogComment()
                    comment.roaster = roaster
                    comment.roasterId = roaster
                    comment.comment = "Started \(state)."
                    comment.sentAt = event.createdAt
                    return comment
                    } .compactMap{$0}
                
                //merge them and sort them into a single timeline
                comments.append(contentsOf: eventComments)
                
                comments = comments.sorted(by: {prev, next in
                    guard let pDate = prev.sentAt ?? prev.createdAt, let nDate = next.sentAt ?? next.createdAt else {return false}
                    //order the elements by their creation date
                    return pDate.compare(nDate) == .orderedAscending
                })
                
                self?.comments = comments
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let roastLog = self.roastLog {
            //we are presenting comments for just one log
            self.load(log: roastLog)
        } else {
            self.loadRoastEvents()
        }
    }

    override func inputViewPrimaryActionTriggered(inputView: MSGInputView) {
        guard let roasterId = BellwetherAPI.auth.currentProfileInfo?.subtitle, let roaster = BellwetherAPI.auth.currentProfileInfo?.title else {return print("failed to authenticate user")}
        
        let comment = RoastLogComment()
        comment.roastLog = self.roastLog    //this can be nil, and that is ok; presented againt last roast event
        comment.roaster = roaster
        comment.roasterId = roasterId
        comment.comment = inputView.message
        comment.cafe = BellwetherAPI.auth.cafe
        
        comment.saveInBackground {[weak self] success, error in
            guard let _self = self, success else {return print("error creating message")}
            
            let message = MSGMessage(id: _self.messages.count, body: .text(inputView.message),
                                     user: _self.currentCommenter(), sentAt: Date())
            _self.insert(message)
        }
        
        //also post the comment to Asana
        if !BellwetherAPI.auth.isBellwetherUser {
            Asana.createTask(comment: inputView.message)
        }
    }
    
    override func insert(_ message: MSGMessage) {
        
        collectionView.performBatchUpdates({
            if let lastSection = self.messages.last, let lastMessage = lastSection.last, lastMessage.user.displayName == message.user.displayName {
                self.messages[self.messages.count - 1].append(message)
                
                let sectionIndex = self.messages.count - 1
                let itemIndex = self.messages[sectionIndex].count - 1
                self.collectionView.insertItems(at: [IndexPath(item: itemIndex, section: sectionIndex)])
                
            } else {
                self.messages.append([message])
                let sectionIndex = self.messages.count - 1
                self.collectionView.insertSections([sectionIndex])
            }
        }, completion: { (_) in
            self.collectionView.scrollToBottom(animated: true)
            self.collectionView.layoutTypingLabelIfNeeded()
        })
        
    }
}

// MARK: - MSGDataSource

extension RoastLogCommentsViewController: MSGDataSource {
    
    func numberOfSections() -> Int {
        return messages.count
    }
    
    func numberOfMessages(in section: Int) -> Int {
        return messages[section].count
    }
    
    func message(for indexPath: IndexPath) -> MSGMessage {
        return messages[indexPath.section][indexPath.item]
    }
    
    func footerTitle(for section: Int) -> String? {
        let colloquial = messages[section].last?.sentAt.colloquial(to: Date())
        print("message:\(colloquial ?? "<no date>")")
        return messages[section].last?.sentAt.colloquial(to: Date())
    }
    
    func headerTitle(for section: Int) -> String? {
        return messages[section].first?.user.displayName
    }
    
}

// MARK: - MSGDelegate

extension RoastLogCommentsViewController: MSGDelegate {
    
    func linkTapped(url: URL) {
        print("Link tapped:", url)
    }
    
    func avatarTapped(for user: MSGUser) {
        print("Avatar tapped:", user)
    }
    
    func tapReceived(for message: MSGMessage) {
        print("Tapped: ", message)
    }
    
    func longPressReceieved(for message: MSGMessage) {
        print("Long press:", message)
    }
    
    func shouldDisplaySafari(for url: URL) -> Bool {
        return false
    }
    
    func shouldOpen(url: URL) -> Bool {
        return false
    }
    
}

extension UICollectionView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

struct Asana {
    static let workspace = "451289238582849"
    static let token = "0/a987b780a620b355dceb29a7304f9390"
    static let ricardo = "451379681893198"
    static let michelle = "765778487316358"
    static let tag = "731933302896768"
    static let project = "737071449352396"
    
    static var assignee: String {
        return michelle
    }
    
    static func createTask(comment: String){
        
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + Asana.token]
        let params: Parameters = ["workspace":Asana.workspace, "assignee":Asana.assignee, "projects":"737071449352396",
                                  "name":comment,"notes":Roaster.shared.notes, "tag":Asana.tag]
        
        Alamofire.request("https://app.asana.com/api/1.0/tasks", method:.post, parameters:params, encoding: URLEncoding.default, headers:headers).responseJSON() {
            response in
//            switch response.result {
//            case .success(let data):
//                print(JSON(data))
//            case .failure(let error):
//                print(error)
//            }
        }
        
    }
    
}

struct ArrayEncoding: ParameterEncoding {
    static let shared = ArrayEncoding()
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try URLEncoding().encode(urlRequest, with: parameters)
        request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))
        return request
    }
}
