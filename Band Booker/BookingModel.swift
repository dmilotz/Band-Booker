//
//  BookingModel.swift
//  Band Booker
//
//  Created by Dirk Milotz on 4/13/17.
//  Copyright © 2017 DagApps. All rights reserved.
//

import Foundation

struct Booking{
  var bookingId: String
  var venue: Venue
  var date: String
  var time: String
  var band1: String?
  var band2: String?
  var band3: String?
  var genre: String
  var spotNeeded: String
  func getDict()->[String:Any]{
    return ["venue": venue.placeId, "date": date, "time": time, "band1": band1 ?? "none", "band2": band2 ?? "none", "band3":band3 ?? "none","genre": genre, "spotNeeded": spotNeeded]
  }
  
}
