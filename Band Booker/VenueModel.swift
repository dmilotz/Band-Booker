//
//  VenueModel.swift
//  Band Booker
//
//  Created by Dirk Milotz on 4/13/17.
//  Copyright © 2017 DagApps. All rights reserved.
//

import Foundation
struct Venue{
  var name: String
  var city: String
  var state: String
  var fullAddress: String
  var zipCode: String
  var placeId: String
  func getDict()->[String:Any]{
    return ["name": name, "city": city, "state": state, "fullAddress": fullAddress , "zipCode": zipCode , "placeId":placeId]
  }

}
