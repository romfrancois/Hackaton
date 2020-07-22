//
//  TeamDetailTableViewController.swift
//  Hackaton
//
//  Created by Romain Francois on 20/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class TeamDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var universityField: UITextField!
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    var team: Team!
    let regionDistance: CLLocationDistance = 50_000 // 50 KM
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if team == nil {
            team = Team()
        }
        
        let region = MKCoordinateRegion(center: team.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        teamNameField.text = team.teamName
        universityField.text = team.university
        projectNameField.text = team.projectName
        descriptionTextView.text = team.projectDescription
        
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(team)
        mapView.setCenter(team.coordinate, animated: true)
    }
    
    func updateFromUserInterface() {
        team.teamName = teamNameField.text!
        team.university = universityField.text!
        team.projectName = projectNameField.text!
        team.projectDescription = descriptionTextView.text
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        team.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func findLocationPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension TeamDetailTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        updateFromUserInterface()
        
        team.university = place.name ?? "Unknown School"
        team.coordinate = place.coordinate
        team.projectDescription = "\(team.coordinate.latitude), \(team.coordinate.longitude)"
        
        updateUserInterface()
        
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
