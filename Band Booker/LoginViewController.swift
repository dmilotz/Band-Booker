//
//  LoginViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/7/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate{
  //MARK: Properties
  
  var ref: FIRDatabaseReference!
  
  // MARK: Outlets
  
}

// MARK : Lifecycle
extension LoginViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    GIDSignIn.sharedInstance().uiDelegate = self
    ref = FIRDatabase.database().reference()
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      if user != nil {
          print(user?.displayName)
              var vals = ["userName": user?.displayName, "email": user?.email] as [String : Any]
              self.ref.child("users").child((user?.uid)!).updateChildValues(vals)
            DispatchQueue.main.async{
              self.performSegue(withIdentifier: "TabController", sender: nil)
              
            }
      }
      }
  }
}
