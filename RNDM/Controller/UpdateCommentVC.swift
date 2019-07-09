//
//  UpdateCommentVC.swift
//  RNDM
//
//  Created by AHMED on 2/20/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentVC: UIViewController {

  @IBOutlet weak var commentTxt: UITextView!
  @IBOutlet weak var updateButton: UIButton!
  
  var commentData: (comment: Comment, thought: Thought)!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    commentTxt.layer.cornerRadius = 10
    updateButton.layer.cornerRadius = 10
    commentTxt.text = commentData.comment.commentTxt
    }

  @IBAction func updateTapped(_ sender: Any) {
    Firestore.firestore().collection(THOUGHT_REF).document(commentData.thought.documentId).collection(COMMENTS_REF).document(commentData.comment.documentId).updateData([COMMENT_TXT: commentTxt.text]) { (error) in
      if let error = error{
        debugPrint("Unable to update comment: \(error.localizedDescription)")
      }else{
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
}
