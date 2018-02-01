//
//  ViewController.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController, QuoteTableViewControllerDelegate {

    let currUer = User()
    var userPassword: String = ""
    var loggedUserEmail: String = ""
    var formattedEmail: String = ""
    var username: String = ""
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        print("Button Pressed")
        if let userEmail = emailTextField.text, let userPassword = passwordTextField.text {
            Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
                if user != nil {
                    
                    self.formattedEmail = self.encodeEmail(email: userEmail)
        
                    let dbref = Database.database().reference()
                    dbref.child("users").child(self.formattedEmail).observeSingleEvent(of: .value, with: {(snapshot) in
                        
                        let value = snapshot.value as? NSDictionary
                        
                        if let theName = value?["userName"] as? String {
                            self.username = theName
                        }
//                        let username = value?["userName"] as? String
                        print(self.username)
                        print(self.formattedEmail)

                        self.currUer.userEmail = self.formattedEmail
                        self.currUer.userName = self.username
                        self.performSegue(withIdentifier: "quotesSegue", sender: self.currUer)
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                } else {
                    print("Error from login: \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "quotesSegue" {
            let tabBarController = segue.destination as! UITabBarController
            let nav = tabBarController.viewControllers![0] as! UINavigationController
            let quotesTableViewController = nav.topViewController as! QuotesTableViewController
            quotesTableViewController.delegate = self
            if let theUser = sender as? User {
                quotesTableViewController.getUser = sender as? User
                print("I'm SENDING the USER: \(currUer.userName)")
            }
        } else {
            print("NOT USING QUOTE segue")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func encodeEmail (email: String) -> String {
        let originalEmail = email
        let newEmail = originalEmail.replacingOccurrences(of: ".", with: ",")
        return newEmail
    }


}

