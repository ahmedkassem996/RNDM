//
//  AddThoughVC.swift
//  RNDM
//
//  Created by AHMED on 2/9/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Firebase

class AddThoughVC: UIViewController, UITextViewDelegate {

  @IBOutlet private weak var categorySegment: UISegmentedControl!
  @IBOutlet private weak var userNameTxt: UITextField!
  @IBOutlet private weak var thoughtText: UITextView!
  @IBOutlet private weak var postBtn: UIButton!
  
  private var selectedCategory = ThoughtCategory.funny.rawValue
  
  override func viewDidLoad() {
        super.viewDidLoad()
    postBtn.layer.cornerRadius = 4
    thoughtText.layer.cornerRadius = 4
    thoughtText.text = "My random Though..."
    thoughtText.textColor = UIColor.lightGray
    thoughtText.delegate = self
    }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.text = ""
    textView.textColor = UIColor.darkGray
  }

  @IBAction func postBtnTapped(_ sender: Any) {
    Firestore.firestore().collection(THOUGHT_REF).addDocument(data: [CATEGORY : selectedCategory,
          NUM_COMMENTS : 0,
          NUM_LIKES : 0,
          THOUGHT_TXT : thoughtText.text,
          TIMESTAMP : FieldValue.serverTimestamp(),
          USERNAME : Auth.auth().currentUser?.displayName ?? "",
          USER_ID: Auth.auth().currentUser?.uid ?? ""
      
      
    ]) { (err) in
      if let err = err{
        debugPrint("Error adding document \(err)")
      }else{
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  @IBAction func categoryChanged(_ sender: Any) {
    switch categorySegment.selectedSegmentIndex {
    case 0:
      selectedCategory = ThoughtCategory.funny.rawValue
    case 1:
      selectedCategory = ThoughtCategory.serious.rawValue
    default:
      selectedCategory = ThoughtCategory.crazy.rawValue
    }

  }
  
}
