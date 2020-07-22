//
//  TeamClass.swift
//  Hackaton
//
//  Created by Romain Francois on 20/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MapKit

class Team: NSObject, MKAnnotation {
    
    var teamName: String
    var university: String
    var coordinate: CLLocationCoordinate2D
    var projectName: String
    var projectDescription: String
    var createdOn: Date
    var postingUserID: String
    var documentID: String
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var title: String? {
        return teamName
    }
    
    var subtitle: String? {
        return university
    }
    
    var dictionary: [String: Any] {
        // convert from Apple date to a TimeInterval
        let timeIntervalDate = createdOn.timeIntervalSince1970
        
        return [
            "teamName": teamName,
            "university": university,
            "latitude": latitude,
            "longitude": longitude,
            "projectName": projectName,
            "projectDescription": projectDescription,
            "createdOn": timeIntervalDate,
            "postingUserID": postingUserID,
            "documentID": documentID
        ]
    }
    
    init(teamName: String, university: String, coordinates: CLLocationCoordinate2D, projectName: String, projectDescription: String, createdOn: Date, postingUserID: String, documentID: String) {
        self.teamName = teamName
        self.university = university
        self.coordinate = coordinates
        self.projectName = projectName
        self.projectDescription = projectDescription
        self.createdOn = createdOn
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let teamName = dictionary["teamName"] as! String? ?? ""
        let university = dictionary["university"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let projectName = dictionary["projectName"] as! String? ?? ""
        let projectDescription = dictionary["projectDescription"] as! String? ?? ""
        
        let timeIntervalDate = dictionary["createdOn"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeIntervalDate)
        
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        self.init(teamName: teamName, university: university, coordinates: coordinate, projectName: projectName, projectDescription: projectDescription, createdOn: createdOn, postingUserID: postingUserID, documentID:"")
    }
    
    convenience override init() {
        self.init(teamName: "", university: "", coordinates: CLLocationCoordinate2D() , projectName: "", projectDescription: "", createdOn: Date(), postingUserID: "", documentID:"")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "team" below.
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("teams").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("teams").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Team’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
}
