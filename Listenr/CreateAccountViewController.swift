//
//  CreateAccountViewController.swift
//  Listenr
//
//  Created by Colson, Kellie Anne on 11/27/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController {

    let db = Firestore.firestore()

    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var genresTextField: UITextField!
    @IBOutlet var favoriteSongTextField: UITextField!
    @IBOutlet var favoriteArtistTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "createAccountSegue"{
            if emailTextField.text == "" {
                let alertController = UIAlertController(title: "Missing Email", message: "An email for your account has not been entered", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
                return false
            } else if passwordTextField.text == "" {
                let alertController = UIAlertController(title: "Missing Password", message: "A password for your account has not been entered", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
                return false
            }
            
            if let email = emailTextField.text, let password = passwordTextField.text {
                if password.count >= 6 {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let resultError = error {
                            print(resultError)
                        } else {
                            print("successfully registered new user")
                        }
                    }
                    return true
                } else {
                    let alertController = UIAlertController(title: "Password Too Short", message: "Your password must be at least 6 characters long", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alertController, animated: true, completion: nil)
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        // add plain music info entered by user to firebase
        if let genres = genresTextField.text, let artist = favoriteArtistTextField.text, let song = favoriteSongTextField.text, let docID = emailTextField.text {
            
            var spotifyArtistID = ""
            var spotifyTrackID = ""
            
            SpotifyAPI.fetchArtistID(artist: artist) { (artistIDOptional) in
                if let artistID = artistIDOptional {
                    spotifyArtistID = artistID
                    print("executing fetchArtistID completion closure")
                    self.db.collection("users").document(docID).setData(["spotifyArtistID": spotifyArtistID], merge: true)
                } else {
                    print("artistIDOptional is nil")
                }
                
            }

            SpotifyAPI.fetchTrackID(track: song) { (trackIDOptional) in
                if let trackID = trackIDOptional {
                    spotifyTrackID = trackID
                    print("executing fetchTrackID completion closure")
                    self.db.collection("users").document(docID).setData(["spotifyTrackID": spotifyTrackID], merge: true)
                } else {
                    print("trackIDOptional is nil")
                }
            }

            
            db.collection("users").document(docID).setData(["genres": genres, "artist": artist, "song": song], merge: true){
                err in
                if let err = err {
                    print("error adding document: \(err)")
                } else {
                    print("document added with ID: \(docID)")
                }
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
