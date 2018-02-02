//
//  QuotesTableViewController.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol QuoteTableViewControllerDelegate: class {

}

class QuotesTableViewController: UITableViewController, AddViewControllerDelegate {

    var quoteData = [Quote]()
    var alertController: UIAlertController!
    weak var delegate: QuoteTableViewControllerDelegate?
    let db = Database.database()
    let currUserName = User.userName
    let currUserEmail = User.userEmail
    var favoriteIds = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndReload()

        print("GET favoriteIDS: \(favoriteIds)")
        print("I'M FROM FIRST LOAD: \(self.quoteData)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let navigationController = segue.destination as! UINavigationController
            let addViewController = navigationController.topViewController as! AddViewController
            addViewController.delegate = self
        }
    }
    
    // MARK: Delegate
    func addItem(by controller: UIViewController, quotedBy: String?, message: String?, status: Bool?, didEdit: Quote?) {

        let userRef = db.reference(withPath: "quotes").childByAutoId()
        let currentTime = convertToUnix(date: Date())
        let idKey = userRef.key

        let quoteToAdd: [String:Any] = ["userEmail": currUserEmail, "userName": currUserName, "quotedBy": quotedBy, "message": message, "updatedAt": currentTime, "idKey": idKey]
        userRef.setValue(quoteToAdd)

        print("GOTCHA")
        dismiss(animated: true, completion: nil)
    }

    func cancel(by controller: UIViewController) {
        dismiss(animated: true, completion: nil)
        print("clicked on cancel")
    }
    
    // MARK: Firebase
    func fetchAndReload() {
        
//        db.reference(withPath: "userFavorites").child(currUserEmail).observe(.childAdded) {(snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let favId = value!["idKey"]
//            print(favId!)
//            self.favoriteIds.append(favId! as! String)
//            print(self.favoriteIds)
//        }


        db.reference(withPath: "quotes").observe(.childAdded) {(snapshot) in
            let single = snapshot.value as! [String: Any]
            let checkId = single["idKey"] as! String
            let singleQuote = Quote(quotedBy: single["quotedBy"] as! String, message: single["message"] as! String, posterName: single["userName"] as! String, posterEmail: single["userEmail"] as! String, updatedAt: single["updatedAt"] as! Int, idKey: single["idKey"] as! String)
            
            self.db.reference(withPath: "userFavorites").child(self.currUserEmail).observe(.childAdded) {(snapshot) in
                let value = snapshot.value as? [String: Any]
                let favId = value!["idKey"] as! String
                let favQuote = Quote(quotedBy: value!["quotedBy"] as! String, message: value!["message"] as! String, posterName: value!["userName"] as! String, posterEmail: value!["userEmail"] as! String, updatedAt: value!["updatedAt"] as! Int, idKey: value!["idKey"] as! String)
                
                if favId == checkId {
                    print("MATCHED")
            
                } else {
                    print("DOESN'T MATCH")
                    self.tableView.reloadData()
                    self.quoteData.insert(singleQuote, at: 0)
                }
            }
        }

        //ORIGINAL
//        db.reference(withPath: "quotes").queryOrdered(byChild: "updatedAt").observe(.childAdded) { (snapshot) in
//            let single = snapshot.value as! [String: Any]
//            let singleQuote = Quote(quotedBy: single["quotedBy"] as! String, message: single["message"] as! String, posterName: single["userName"] as! String, posterEmail: single["userEmail"] as! String, updatedAt: single["updatedAt"] as! Int, idKey: single["idKey"] as! String)
//            self.quoteData.insert(singleQuote, at: 0)
//            print(self.quoteData)
//            self.tableView.reloadData()
//        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quoteData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quoteCell") as! QuotesTableViewCell
        
        let quote = quoteData[indexPath.row] as Quote
        cell.messageLabel.text = "\(quote.quotedBy!): \(quote.message!)"
        cell.postedByLabel.text = "Posted By: \(quote.posterName!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    
        let addToFavoriteAction = UIAlertAction(title: "Add to Favorite", style: UIAlertActionStyle.default) { (action) -> Void in
            let quote = self.quoteData[indexPath.row]
            let id = quote.idKey

            self.db.reference(withPath: "quotes").child(id!).observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                let email = value?["userEmail"] as? String
                let name = value?["userName"] as? String
                let quotedBy = value?["quotedBy"] as? String
                let favoriteMessage = value?["message"] as? String
                let updated = value?["updatedAt"] as? Int
                
                let quoteToFavorite: [String:Any] = ["userEmail": email, "userName": name, "quotedBy": quotedBy, "message": favoriteMessage, "updatedAt": updated, "idKey": id]
                
                let newDbRef = self.db.reference(withPath: "userFavorites")
                let newfav = newDbRef.child(self.currUserEmail)
                let withId = newfav.child(id!)
                withId.setValue(quoteToFavorite)
            }) {(error) in
                print("Error from getting data: \(error.localizedDescription)")
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default) { (action) -> Void in
            print("DeleteAction")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) -> Void in
            print("Cancel")
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        alertController.addAction(addToFavoriteAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    // MARK: Other func
    func convertToUnix (date: Date) -> Int {
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        let myInt = Int(timeInterval)
        return myInt
    }
    
    
    func getFavorites() {
        db.reference(withPath: "userFavorites").child(currUserEmail).observe(.childAdded) { (snapshot) in
            let singleFav = snapshot.value as! [String:Any]
            let singleKey = singleFav["idKey"]
            self.favoriteIds.append(singleKey as! String)
        }
    }
    
    func compareFavorites() {
        self.db.reference(withPath: "quotes").queryOrdered(byChild: "updatedAt").observe(.childAdded) { (snapshot) in
            let single = snapshot.value as! [String: Any]
            let singleAllkey = single["idKey"] as! String
            for checkKey in self.favoriteIds {
                if checkKey == singleAllkey {
                    let singleQuote = Quote(quotedBy: single["quotedBy"] as! String, message: single["message"] as! String, posterName: single["userName"] as! String, posterEmail: single["userEmail"] as! String, updatedAt: single["updatedAt"] as! Int, idKey: single["idKey"] as! String)
                    self.quoteData.insert(singleQuote, at: 0)
                    self.tableView.reloadData()
                }
            }
        }
    }
}
