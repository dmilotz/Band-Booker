//
//  ManageViewController.swift
//  Band Booker
//
//  Created by Dirk Milotz on 4/13/17.
//  Copyright © 2017 DagApps. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import FirebaseAuth
import FirebaseDatabase

class ManageViewController: UITableViewController{
  var ref: FIRDatabaseReference!
  var bookings: [Booking] = []
  
  
  override func viewDidLoad(){
    super.viewDidLoad()
    ref = FIRDatabase.database().reference()
    findBookings()
    self.tableView.allowsMultipleSelectionDuringEditing = false;
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    bookings = []
    findBookings()
  }
  
  @IBAction func logout(_ sender: Any) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
    UIApplication.shared.keyWindow?.rootViewController = loginViewController
  }
  
  func findBookings(){
    let userId = FIRAuth.auth()?.currentUser?.uid
    NetworkClient.getUserInfo(userId: userId!) { (dict, error) in
      if let bookingDict = dict?["currentBookings"] as? [String:String]{
        print (bookingDict)
        for bookingId in bookingDict.keys{
          print(bookingId)
          self.ref.child("bookings").child(bookingId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
              let venue = Venue(name: dict["venueName"] as! String, city: dict["city"] as! String, state: dict["state"] as! String, fullAddress: dict["fullAddress"] as! String, zipCode: dict["zipCode"] as! String, placeId: dict["venueId"] as! String)
              let booking = Booking(bookingId: dict["bookingId"] as! String, venue: venue, date: dict["date"] as! String, time: dict["time"] as! String, band1: dict["band1"] as! String, band2: dict["band2"] as! String, band3: dict["band3"] as! String, genre: dict["genre"] as! String, spotNeeded: dict["spotNeeded"] as! String, bookerEmail: dict["email"] as! String)
              if !self.bookings.contains(booking){
                
                self.bookings.append(booking)
                DispatchQueue.main.async{
                  self.tableView.reloadData()
                }
              }
            }
          })
        }
      }
      
    }
  }
}

//MARK : Table delegate

extension ManageViewController{
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if(editingStyle == UITableViewCellEditingStyle.delete){
      let booking = self.bookings[(indexPath as NSIndexPath).row]
      let uid = FIRAuth.auth()?.currentUser?.uid
      let ref = FIRDatabase.database().reference()
      ref.child("users").child(uid!).child("currentBookings").child(booking.bookingId).removeValue()
      ref.child("bookings").child(booking.bookingId).removeValue()
      ref.child("cities").child("currentBookings").child(booking.bookingId).removeValue()
      bookings.remove(at: (indexPath as NSIndexPath).row)
      tableView.reloadData()
    }
  }
}

extension ManageViewController{
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return bookings.count
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
    let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell2") as! BookingCell
    let booking = self.bookings[(indexPath as NSIndexPath).row]
    cell.date.text = booking.date
    cell.genre.text = "Genre: \(booking.genre)"
    cell.headlinerBand.text = booking.band1
    cell.supportBand.text = booking.band2
    cell.opener.text = booking.band3
    cell.venueName.text = booking.venue.name
    cell.spotNeeded.text = "Spot Needed: \(booking.spotNeeded)"
    return cell
  }
  
  
  
}

