//
//  TeamsListViewController.swift
//  Hackaton
//
//  Created by Romain Francois on 20/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn  // used to be called FirebaseGoogleAuthUI

class TeamsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var teams: Teams!
    
    // declaring the authUI variable is step [2]
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initializing the authUI var and setting the delegate are step [3]
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        teams = Teams()
        
        // if you have a table view, you'll want this code, too. The .isHidden will hide the table view data so that it cannot be seen by someone who isn't logged in.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        teams.loadData {
            self.tableView.reloadData()
        }
    }
    
    // Be sure to call this from viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTeam" {
            let destination = segue.destination as! TeamDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.team = teams.teamArray[selectedIndexPath.row]
        }
    }

    // VITAL: This gist includes key changes to make sure "cancel" works with iOS 13.
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
    
}

extension TeamsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        teams.teamArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath)
        cell.textLabel?.text = teams.teamArray[indexPath.row].teamName
        
        return cell
    }
}

// Name of the extension is likely the only thing that needs to change in new projects
extension TeamsListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        
        // Create a frame for a UIImageView to hold our logo
        let marginInsets: CGFloat = 16 // logo will be 16 points from L and R margins
        let imageHeight: CGFloat = 225 // the height of our logo
        let imageY = self.view.center.y - imageHeight // places bottom of UIImageView in the center of the login screen
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}
