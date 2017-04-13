//
//  NetworkClient.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 4/3/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class NetworkClient{
  
  // shared session
  var session = URLSession.shared
  
  
  static func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
      (data, response, error) in
      guard let data = data, error == nil else{
        print("problem loading photo from url \(url)")
        return
      }
      
      completion(data, response, error)
      }.resume()
  }
  
  static func checkUserExists(uid: String, completion: @escaping (_ bool: Bool? , _ error: Error?) -> Void) {
    let ref = FIRDatabase.database().reference()
    ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
      
      if snapshot.hasChild(uid){
        completion(true, nil)
      }else{
        completion(false, nil)
      }
      
    }){ (error) in
      completion(nil,error)
    }
    
  }
  
  
  static func getBookingInfo(bookingId: String, completion: @escaping (_ dict: [String:Any]?, _ error: Error?) -> Void) {
    let ref = FIRDatabase.database().reference()
    ref.child("bookings").child(bookingId).observeSingleEvent(of: .value, with: { (snapshot) in
      if let dict = snapshot.value as? [String:Any]{
        completion(dict, nil)
      }
    }) { (error) in
      completion(nil,error)
    }
    
  }
  
  static func getUserInfo(userId: String, completion: @escaping (_ dict: [String:Any]?, _ error: Error?) -> Void) {
    let ref = FIRDatabase.database().reference()
    ref.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
      if let dict = snapshot.value as? [String:Any]{
        print (dict)
        completion(dict, nil)
      }
    }) { (error) in
      completion(nil,error)
    }
    
  }
  
  static func createBooking(_ booking: Booking) {
    let uid = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    ref.child("bookings").child(booking.bookingId).setValue(booking.getDict())
    ref.child("users").child(uid!).child("currentBookings").child(booking.bookingId).setValue(booking.venue.name)
    ref.child("venues").child(booking.venue.placeId).child("currentBookings").child(booking.bookingId).setValue("")
    ref.child("venues").child(booking.venue.placeId).setValue(booking.venue.getDict())
  }
  
  static func getBookingsPerCourse(courseId: String, completion: @escaping (_ dict: [String:Any]?, _ error: String?) -> Void) {
    let ref = FIRDatabase.database().reference()
    ref.child("courses").child(courseId).child("currentBookings").observeSingleEvent(of: .value, with: { (snapshot) in
      if let dict = snapshot.value as? [String:Any]{
        completion(dict, nil)
      }else{
        completion(nil, "No Current Bookings")
      }
    })
    
  }
  
  static func leaveBooking(bookingId: String, completion: @escaping (_ string: String?, _ error: Error?) -> Void){
    let uid = FIRAuth.auth()?.currentUser?.uid
    let ref = FIRDatabase.database().reference()
    ref.child("users").child(uid!).child("currentBookings").child(bookingId).removeValue()
    ref.child("bookings").child(bookingId).child("players").child(uid!).removeValue()
    
  }
  
//  
//  static func cancelBooking(booking: Booking){
//    
//    let uid = FIRAuth.auth()?.currentUser?.uid
//    let ref = FIRDatabase.database().reference()
//    ref.child("users").child(uid!).child("currentBookings").child(booking.bookingId!).removeValue()
//    ref.child("bookings").child(booking.bookingId!).removeValue()
//    ref.child("courses").child(booking.courseId!).child("currentBookings").child(booking.bookingId!).removeValue()
//    for playerId in (booking.players?.keys)!{
//      ref.child("users").child(playerId).child("currentBookings").child(booking.bookingId!).removeValue()
//    }
//  }
  
  
}



