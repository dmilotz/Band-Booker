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

class CreateBookingViewController:UITableViewController{
  var genrePickerDataSource = ["Rock", "Folk", "Pop","Shoegaze"]
  var chosenGenre: String = ""
  
  
  @IBOutlet var dateTimePicker: UIDatePicker!
  @IBOutlet var genrePicker: UIPickerView!
  @IBOutlet var bandOneLabel: UITextField!
  @IBOutlet var bandTwoLabel: UITextField!
  @IBOutlet var bandThreeLabel: UITextField!
  @IBOutlet var chooseVenueButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    genrePicker.dataSource = self
    genrePicker.delegate = self
    chooseVenueButton.titleLabel?.text = "Choose Venue"
  }
  
  @IBAction func chooseVenueClicked(_ sender: Any) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
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
    for item in place.addressComponents!{
      print(item.type)
      print(item.name)
    }
    print(place.types)

    chooseVenueButton.setTitle(place.name, for: .normal)
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
    return genrePickerDataSource.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return genrePickerDataSource[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    chosenGenre = genrePickerDataSource[row]
  }
  
}
