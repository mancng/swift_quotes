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
    var getUser: User?
    var alertController: UIAlertController!
    weak var delegate: QuoteTableViewControllerDelegate?
    let db = Database.database().reference(withPath: "quotes")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndReload()
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

        let userRef = db.childByAutoId()
        let name = getUser?.userName
        let email = getUser?.userEmail
        let currentTime = convertToUnix(date: Date())

        let quoteToAdd: [String:Any] = ["userEmail": email, "userName": name, "quotedBy": quotedBy, "message": message, "updatedAt": currentTime]
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
        db.observe(.childAdded) { (snapshot) in
        let single = snapshot.value as! [String: Any]
            let singleQuote = Quote(quotedBy: single["quotedBy"] as! String, message: single["message"] as! String, posterName: single["userName"] as! String, posterEmail: single["userEmail"] as! String, updatedAt: single["updatedAt"] as! Int)
            self.quoteData.append(singleQuote)
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
//            let itemToShow = self.friendsData[indexPath.row]
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

}
