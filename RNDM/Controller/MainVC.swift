//
//  ViewController.swift
//  RNDM
//
//  Created by AHMED on 2/8/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit
import Firebase


enum ThoughtCategory: String{
  case serious =  "serious"
  case funny = "funny"
  case crazy = "crazy"
  case popular = "popular"
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ThoughtDelegate {
 
  @IBOutlet private weak var segmentControl: UISegmentedControl!
  @IBOutlet private weak var tableView: UITableView!
  
  private var thoughts = [Thought]()
  private var thoughtsCollectionRef: CollectionReference!
  private var thoughtsListener: ListenerRegistration!
  private var selectedCategory = ThoughtCategory.funny.rawValue
  private var handel: AuthStateDidChangeListenerHandle?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableView.automaticDimension
    
    thoughtsCollectionRef = Firestore.firestore().collection(THOUGHT_REF)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    handel = Auth.auth().addStateDidChangeListener({ (auth, user) in
      if user == nil{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
        self.present(loginVC, animated: true, completion: nil)
      }else{
        self.setListner()
      }
    })
   
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if thoughtsListener != nil{
      thoughtsListener.remove()
    }
  }
  
  func thoughtOptionsTapped(thought: Thought) {
    let alert = UIAlertController(title: "Delete", message: "Do you want to delete your thought?", preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete Thought", style: .default) { (action) in
      
      self.delete(collection: Firestore.firestore().collection(THOUGHT_REF).document(thought.documentId).collection(COMMENTS_REF), completion: { (error) in
        if let error = error{
          debugPrint("Could not delete subcollection: \(error.localizedDescription)")
        }else{
          Firestore.firestore().collection(THOUGHT_REF).document(thought.documentId).delete(completion: { (error) in
            if let error = error{
              debugPrint("Could not delete thought: \(error.localizedDescription)")
            }else{
              alert.dismiss(animated: true, completion: nil)
            }
          })
        }
      })
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  func delete(collection: CollectionReference, batcgSize: Int = 100, completion: @escaping(Error?) -> ()){
    collection.limit(to: batcgSize).getDocuments { (docset, error) in
      guard let docset = docset else {
        completion(error)
        return
      }
      
      guard docset.count > 0 else {
        completion(nil)
        return
      }
      
      let batch = collection.firestore.batch()
      docset.documents.forEach{batch.deleteDocument($0.reference)}
      
      batch.commit(completion: { (batchError) in
        if let batchError = batchError{
          completion(batchError)
        }else{
          self.delete(collection: collection, batcgSize: batcgSize, completion: completion)
        }
      })
    }
  }
  
//  func delete(collection: CollectionReference, batchSize: Int = 100) {
//    // Limit query to avoid out-of-memory errors on large collections.
//    // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
//    collection.limit(to: batchSize).getDocuments { (docset, error) in
//      // An error occurred.
//      let docset = docset
//
//      let batch = collection.firestore.batch()
//      docset?.documents.forEach { batch.deleteDocument($0.reference) }
//
//      batch.commit {_ in
//        self.delete(collection: collection, batchSize: batchSize)
//      }
//    }
//  }
  
  @IBAction func categoryChanged(_ sender: Any) {
    switch segmentControl.selectedSegmentIndex {
    case 0:
      selectedCategory = ThoughtCategory.funny.rawValue
    case 1:
      selectedCategory = ThoughtCategory.serious.rawValue
    case 2:
      selectedCategory = ThoughtCategory.crazy.rawValue
    default:
      selectedCategory = ThoughtCategory.popular.rawValue
    }
    thoughtsListener.remove()
    setListner()
  }
  
  @IBAction func logoutTapped(_ sender: Any) {
    let firebaseAuth = Auth.auth()
    do{
      try firebaseAuth.signOut()
    }catch let signoutError as NSError{
      debugPrint("Error signing out: \(signoutError)")
    }
  }
  
  func setListner(){
    
    if selectedCategory == ThoughtCategory.popular.rawValue{
      thoughtsListener = thoughtsCollectionRef
        .order(by: NUM_LIKES, descending: true)
        .addSnapshotListener {  (snapshot, error) in
          if let err = error{
            debugPrint(" Error fetching docs: \(err)")
          }else{
            self.thoughts.removeAll()
            self.thoughts = Thought.parseData(snapshot: snapshot)
            self.tableView.reloadData()
          }
      }
    }else{
      
          thoughtsListener = thoughtsCollectionRef
            .whereField(CATEGORY, isEqualTo: selectedCategory)
            .order(by: TIMESTAMP, descending: true)
            .addSnapshotListener {  (snapshot, error) in
            if let err = error{
              debugPrint(" Error fetching docs: \(err)")
            }else{
              self.thoughts.removeAll()
              self.thoughts = Thought.parseData(snapshot: snapshot)
              self.tableView.reloadData()
            }
          }
      }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return thoughts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as? ThoughtCell {
      cell.configureCell(thought: thoughts[indexPath.row], delegate: self)
      return cell
    }else{
      return UITableViewCell()
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "toComments", sender: thoughts[indexPath.row])
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toComments"{
      if let destinationVC = segue.destination as? commentsVC{
        if let thought = sender as? Thought{
          destinationVC.thought = thought
        }
      }
    }
  }
  
  
  
  
  
  
  
  

}

