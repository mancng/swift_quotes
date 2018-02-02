//
//  FavoritesTableViewController.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FavoritesTableViewController: UITableViewController {
    

    var quoteData = [Quote]()
    let currUserName = User.userName
    let currUserEmail = User.userEmail
    
    let db = Database.database()

    @IBAction func signoutBtnPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signout: &@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndReload()
        print(currUserEmail)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Firebase
    func fetchAndReload() {
        db.reference(withPath: "userFavorites").child(currUserEmail).queryOrdered(byChild: "updatedAt").observe(.childAdded) { (snapshot) in
            let single = snapshot.value as! [String: Any]
            let singleQuote = Quote(quotedBy: single["quotedBy"] as! String, message: single["message"] as! String, posterName: single["userName"] as! String, posterEmail: single["userEmail"] as! String, updatedAt: single["updatedAt"] as! Int, idKey: single["idKey"] as! String)
            self.quoteData.insert(singleQuote, at: 0)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoritesTableViewCell
        
        let quote = quoteData[indexPath.row] as Quote
        cell.messageLabel.text = "\(quote.quotedBy!): \(quote.message!)"
        cell.postedByLabel.text = "Posted By: \(quote.posterName!)"
        return cell
    }

 

}
