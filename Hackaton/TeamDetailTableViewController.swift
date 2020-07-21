//
//  TeamDetailTableViewController.swift
//  Hackaton
//
//  Created by Romain Francois on 20/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit

class TeamDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var universityField: UITextField!
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var team: Team!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if team == nil {
            team = Team()
        }
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        teamNameField.text = team.teamName
        universityField.text = team.university
        projectNameField.text = team.projectName
        descriptionTextView.text = team.projectDescription
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
    }
    
}
