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

class FindBookingViewController: UIViewController{
  
  var ref: FIRDatabaseReference!
  let locationManager = CLLocationManager()
  var bookings: [Booking] = []
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  
  

    override func viewDidLoad(){
      super.viewDidLoad()
//      hideKeyboardWhenTappedAround()
      tableView.delegate = self
      tableView.dataSource = self
      searchBar.delegate = self
      ref = FIRDatabase.database().reference()
      
      self.locationManager.requestWhenInUseAuthorization()
      if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      }
    }
  
//  func getDict()->[String:Any]{
//    return ["venueId": venue.placeId, "date": date, "time": time, "band1": band1 ?? "none", "band2": band2 ?? "none", "band3":band3 ?? "none","genre": genre, "spotNeeded": spotNeeded, "city": venue.city.lowercased(), "venueName" : venue.name, "fullAddress": venue.fullAddress, "state"]
//  }
  
  func findBookings(text: String)->Void{
   bookings = []
    ref.child("bookings").queryOrdered(byChild: "city").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").observe(.value, with: { snapshot in

      if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
        
        for snap in snapshots
        {
          if let dict = snap.value! as? [String:Any]{
            print(dict)
            let venue = Venue(name: dict["venueName"] as! String, city: dict["city"] as! String, state: dict["state"] as! String, fullAddress: dict["fullAddress"] as! String, zipCode: dict["zipCode"] as! String, placeId: dict["venueId"] as! String)
            self.bookings.append(Booking(bookingId: dict["bookingId"] as! String, venue: venue, date: dict["date"] as! String, time: dict["time"] as! String, band1: dict["band1"] as! String, band2: dict["band2"] as! String, band3: dict["band3"] as! String, genre: dict["genre"] as! String, spotNeeded: dict["spotNeeded"] as! String))
            DispatchQueue.main.async{
              self.tableView.reloadData()
            }
          }
        }
      }
  
      })
  }
}

// MARK: - UISearchBarDelegate
extension FindBookingViewController: UISearchBarDelegate{
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //searchActive = false
    searchBar.endEditing(true)
    searchBar.resignFirstResponder()
    
    findBookings(text: searchBar.text!.lowercased())
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    findBookings(text: searchBar.text!.lowercased())
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
//    performSegue(withIdentifier: "gameChosen", sender: self)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    
//    if segue.identifier! == "gameChosen" {
//      
//      if let gameVc = segue.destination as? GameViewController {
//        gameVc.game = chosenGame
//      }
//    }
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
    cell.genre.text = booking.genre
    cell.headlinerBand.text = booking.band1
    cell.supportBand.text = booking.band2
    cell.opener.text = booking.band3
    cell.venueName.text = "name"
    return cell
  }
  
  
  
}
