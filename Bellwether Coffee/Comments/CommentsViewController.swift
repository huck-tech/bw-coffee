//
//  CommentsViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 6/13/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class CommentsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var comments: [Comment] = []
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsTableViewCell.reuseIdentifier) as! CommentsTableViewCell
        cell.load(comment: comments[indexPath.row])
        return cell
    }
}

class CommentsTableViewCell: UITableViewCell {
    func load(comment: Comment) {
    }
}

class Comment {
    var userId: String
    var text: String
    var date: Date
    
    init(userId: String, text:String, date: Date) {
        self.userId = userId
        self.text  = text
        self.date = date
    }
}
