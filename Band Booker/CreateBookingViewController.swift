//
//  CreateBookingViewController.swift
//  Band Booker
//
//  Created by Dirk Milotz on 4/13/17.
//  Copyright © 2017 DagApps. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import FirebaseAuth

class CreateBookingViewController:UITableViewController{
  var genrePickerDataSource = ["Rock", "Folk", "Pop","Shoegaze", "Metal", "Country", "Jazz","Who Cares"]
   var spotPickerDataSource = ["Any","Headliner", "Middle", "Opener"]
  var chosenGenre: String = ""
  var venueCity: String = ""
  var venueName: String = ""
  var venueFullAddress: String = ""
  var venueCoordinates: CLLocationCoordinate2D?
  var venueWebsite: String?
  var placeInfoDict: [String:String] = [:]
  var chosenDate: String?
  var chosenTime: String?
  var chosenSpot: String?
  
  @IBOutlet var spotNeededPicker: UIPickerView!
  @IBOutlet var createBookingButton: UIBarButtonItem!
  @IBOutlet var dateTimePicker: UIDatePicker!
  @IBOutlet var genrePicker: UIPickerView!
  @IBOutlet var bandOneLabel: UITextField!
  @IBOutlet var bandTwoLabel: UITextField!
  @IBOutlet var bandThreeLabel: UITextField!
  @IBOutlet var chooseVenueButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hideKeyboardWhenTappedAround()

    chosenSpot = spotPickerDataSource[0]
    chosenGenre = genrePickerDataSource[0]
    spotNeededPicker.dataSource = self
    spotNeededPicker.delegate = self
    genrePicker.dataSource = self
    genrePicker.delegate = self
    chooseVenueButton.titleLabel?.text = "Choose Venue"
    createBookingButton.isEnabled = false
    defaultState()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    defaultState()
  }
  
  @IBAction func chooseVenueClicked(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
  }
  
  @IBAction func createBooking(_ sender: Any) {
    let userId = FIRAuth.auth()?.currentUser?.uid
    let curUser = NetworkClient.getUserInfo(userId: userId!) { (dict, error) in
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "E, MMM dd, yy' at 'h:mm a."
      self.chosenDate = dateFormatter.string(from: self.dateTimePicker.date) // You can pass your date here as a parameter to get in a desired format
      dateFormatter.dateFormat = "HH:mm"
      self.chosenTime = dateFormatter.string(from: self.dateTimePicker.date)
      if(self.chosenGenre != nil || self.chosenDate != nil || self.chooseVenueButton.title(for: .normal) != "Choose Venue"){
        _ = FIRAuth.auth()?.currentUser?.uid
        let venue = Venue(name: self.placeInfoDict["name"]!, city: self.placeInfoDict["city"]!, state: self.placeInfoDict["state"]!, fullAddress: self.placeInfoDict["fullAddress"]!, zipCode: self.placeInfoDict["postal_code"]!, placeId: self.placeInfoDict["placeId"]!)
        let booking = Booking(bookingId: UUID().uuidString, venue: venue, date: self.chosenDate!, time: self.chosenTime!, band1: self.bandOneLabel.text, band2: self.bandTwoLabel.text, band3: self.bandThreeLabel.text, genre: self.chosenGenre, spotNeeded: self.chosenSpot!, bookerEmail: dict?["email"] as! String)
        NetworkClient.createBooking(booking)
        self.tabBarController?.selectedIndex = 2
      }
    }
  
  }
  
  
  func defaultState(){
    chosenSpot = spotPickerDataSource[0]
    chosenGenre = genrePickerDataSource[0]
    bandOneLabel.text = "Headliner"
    bandTwoLabel.text = "Support"
    bandThreeLabel.text = "Opener"
  }
  
}


// MARK: - GMSAutocompleteViewControllerDelegate
extension CreateBookingViewController: GMSAutocompleteViewControllerDelegate {
  
  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    //    print("Place name: \(place.name)")
    //    print("Place address: \(place.formattedAddress)")
    //    print("Place attributions: \(place.attributions)")
    //    print(place.coordinate)
    placeInfoDict["name"] = place.name
    placeInfoDict["fullAddress"] = place.formattedAddress
    placeInfoDict["placeId"] = place.placeID
    for item in place.addressComponents!{
      if(item.type == "administrative_area_level_1"){
        placeInfoDict["state"] = item.name
      }else if(item.type == "locality"){
        placeInfoDict["city"] = item.name
      }
      else{
        placeInfoDict[item.type] = item.name
      }
      
      print(item.type)
      print(item.name)
    }
    print(place.types)
    print(placeInfoDict)
    chooseVenueButton.setTitle(place.name, for: .normal)
    createBookingButton.isEnabled = true
    dismiss(animated: true, completion: nil)
  }
  
  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }
  
  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
  
  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
  
  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
}

// MARK: - Picker delegate used for handicap picker

extension CreateBookingViewController: UIPickerViewDelegate, UIPickerViewDataSource{
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView.tag == 10{
    return genrePickerDataSource.count
    }else{
      return spotPickerDataSource.count
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if pickerView.tag == 10{
      return genrePickerDataSource[row]
    }else{
      return spotPickerDataSource[row]
    }
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView.tag == 10{
      chosenGenre = genrePickerDataSource[row]
    }else{
      chosenSpot = spotPickerDataSource[row]
    }
   
  }
  
}
