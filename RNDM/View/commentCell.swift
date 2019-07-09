//
//  commentCell.swift
//  RNDM
//
//  Created by AHMED on 2/15/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Firebase


protocol CommentDelegate {
  func commentOptionTapped(comment: Comment)
}

class CommentCell: UITableViewCell {

  @IBOutlet weak var userNameTxt: UILabel!
  @IBOutlet weak var timeStampTxt: UILabel!
  @IBOutlet weak var commentTxt: UILabel!
  @IBOutlet weak var optionsMenu: UIImageView!
  
  
  private var comment: Comment!
  private var delegate: CommentDelegate?
  
  func configureCell(comment: Comment, delegate: CommentDelegate?){
    userNameTxt.text = comment.username
    commentTxt.text = comment.commentTxt
    optionsMenu.isHidden = true
    self.comment = comment
    self.delegate = delegate
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, hh:mm"
    let timestamp = formatter.string(from: comment.timestamp)
    timeStampTxt.text = timestamp
    
    if comment.userId == Auth.auth().currentUser?.uid{
      optionsMenu.isHidden = false
      optionsMenu.isUserInteractionEnabled = true
      let tap = UITapGestureRecognizer(target: self, action: #selector(commentOptionTapped))
      optionsMenu.addGestureRecognizer(tap)
    }
  }
  
  @objc func commentOptionTapped(){
    delegate?.commentOptionTapped(comment: comment)
  }

}
