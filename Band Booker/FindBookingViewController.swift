//
//  FindBookingViewController.swift
//  Band Booker
//
//  Created by Dirk Milotz on 4/13/17.
//  Copyright © 2017 DagApps. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseDatabase
import MessageUI
import FirebaseAuth

class FindBookingViewController: UIViewController, MFMailComposeViewControllerDelegate{
  
  var ref: FIRDatabaseReference!
  let locationManager = CLLocationManager()
  var bookings: [Booking] = []
  var searchBarClickedFlag: Bool = false
  
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  
  
  override func viewDidLoad(){
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()
    tableView.delegate = self
    tableView.dataSource = self
    searchBar.delegate = self
    ref = FIRDatabase.database().reference()
    bookings = []
    tableView.reloadData()
    self.locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    bookings = []
    tableView.reloadData()
  }
  
  func findBookings(text: String)->Void{
    let userId = FIRAuth.auth()?.currentUser?.uid
    
    bookings.removeAll()
    tableView.reloadData()
    ref.child("bookings").queryOrdered(byChild: "city").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").observe(.value, with: { snapshot in
      if (self.searchBarClickedFlag == true && !snapshot.exists()){
        DispatchQueue.main.async{
          self.searchBarClickedFlag = false
          self.displayAlert("No shows found for this city", title: "")
        }
      }
      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots
        {
          if let dict = snap.value! as? [String:Any]{
            print(dict)
            let venue = Venue(name: dict["venueName"] as! String, city: dict["city"] as! String, state: dict["state"] as! String, fullAddress: dict["fullAddress"] as! String, zipCode: dict["zipCode"] as! String, placeId: dict["venueId"] as! String)
            self.bookings.append(Booking(bookingId: dict["bookingId"] as! String, venue: venue, date: dict["date"] as! String, time: dict["time"] as! String, band1: dict["band1"] as! String, band2: dict["band2"] as! String, band3: dict["band3"] as! String, genre: dict["genre"] as! String, spotNeeded: dict["spotNeeded"] as! String, bookerEmail: dict["email"] as! String))
            DispatchQueue.main.async{
              self.tableView.reloadData()
            }
          }
        }
      }
    })
  }
  
  // MARK: - Email Delegate
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  func sendMail(_ booking: Booking){
    let mailVC = MFMailComposeViewController()
    mailVC.mailComposeDelegate = self
    mailVC.setToRecipients([booking.bookerEmail])
    mailVC.setSubject("Show at \(booking.venue.name)")
    mailVC.setMessageBody("Show date: \(booking.date)", isHTML: false)
    if(MFMailComposeViewController.canSendMail()){
      present(mailVC, animated: true, completion: nil)
    }
  }
  
  
  
}

// MARK: - UISearchBarDelegate
extension FindBookingViewController: UISearchBarDelegate{
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //searchActive = false
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
    searchBarClickedFlag = true
    findBookings(text: searchBar.text!.lowercased())
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if(!(searchBar.text?.isEmpty)!){
    findBookings(text: searchBar.text!.lowercased())
    }else{
      bookings = []
      tableView.reloadData()
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
  }
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
  }
}



//MARK: Location Manager

extension FindBookingViewController: CLLocationManagerDelegate{
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        if CLLocationManager.isRangingAvailable() {
          // do stuff
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let userLocation = locations.first{
      //      let minLat = userLocation.coordinate.latitude - (searchDistance / 69)
      //      let maxLat = userLocation.coordinate.latitude + (searchDistance / 69)
      //
      //      let minLon = userLocation.coordinate.longitude - searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
      //      let maxLon = userLocation.coordinate.longitude + searchDistance / fabs(cos(deg2rad(degrees: userLocation.coordinate.latitude))*69)
      //
      //      //searchByUserLocation(predicate: NSPredicate(format: "lat < %f AND lat > %f AND long < %f AND long > %f",maxLat, minLat, maxLon, minLon))
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
  }
}

//MARK : Table delegate

extension FindBookingViewController: UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chosenBooking = bookings[(indexPath as NSIndexPath).row]
    sendMail(chosenBooking)
  }
}

extension FindBookingViewController: UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    print(games.count)
    return bookings.count
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //let courses = try! Realm().objects(Course.self).filter("e_city CONTAINS %@ OR e_state CONTAINS %@ OR biz_name CONTAINS %@",search,search,search)
    let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell") as! BookingCell
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
