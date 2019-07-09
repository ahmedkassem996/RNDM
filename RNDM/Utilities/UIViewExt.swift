//
//  UIViewExt.swift
//  breakPoint
//
//  Created by AHMED on 2/4/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

extension UIView {
  func bindToKeyboard(){
    NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(_:)), name:
      UIApplication.keyboardWillChangeFrameNotification
      , object: nil)
  }
  
  @objc func keyboardWillChange(_ notification: NSNotification) {
    
    let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
    let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
    let beginningFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let deltaY = endFrame.origin.y - beginningFrame.origin.y
    
    UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
      self.frame.origin.y += deltaY
    }, completion: nil)
  }
}

