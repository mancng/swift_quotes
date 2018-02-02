//
//  RegisterViewController.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, QuoteTableViewControllerDelegate {

    var userEmail: String = ""
    var userPassword: String = ""
    var userName: String = ""
    var formattedEmail: String = ""

    @IBOutlet var nameTxtField: UITextField!
    @IBOutlet var emailTxtField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        
        userName = nameTxtField.text!
        userEmail = emailTxtField.text!
        formattedEmail = encodeEmail(email: emailTxtField.text!)
        userPassword = passwordTxtField.text!
        
        if userEmail != "" && userPassword != "" {
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
                if user != nil {
                    let db = Database.database()
                    let ref = db.reference(withPath: "users")
                    let userRef = ref.child(self.formattedEmail)
                    let userToAdd: [String:Any] = ["userName": self.userName, "userEmail": self.userEmail]
                    userRef.setValue(userToAdd)
                    print("user created in database!")
                    User.userName = self.userName
                    User.userEmail = self.formattedEmail
                    
                    self.performSegue(withIdentifier: "quotesSegue", sender: self)
                } else {
                    print("Error from registration: \(String(describing: error))")
                }
            }
        } else {
            print("NOTHING entered")
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
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTxtField.resignFirstResponder()
        passwordTxtField.resignFirstResponder()
    }

    func encodeEmail (email: String) -> String {
        let originalEmail = email
        let newEmail = originalEmail.replacingOccurrences(of: ".", with: ",")
        return newEmail
    }


}
