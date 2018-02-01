//
//  AddViewController.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate: class {
    func addItem(by controller: UIViewController, quotedBy: String?, message: String?, status: Bool?, didEdit: Quote?)
    
    func cancel(by controller: UIViewController)
}

class AddViewController: UIViewController {
    
    var quotedBy: String = ""
    var message: String = ""
    var itemStatus: Bool?
    var itemToEdit: Quote?
    weak var delegate: AddViewControllerDelegate?
    
    @IBOutlet var quoteByTxtField: UITextField!
    @IBOutlet var messageTxtField: UITextView!
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        let getQuoteBy = quoteByTxtField.text!
        let getMessage = messageTxtField.text!
        
        delegate?.addItem(by: self, quotedBy: getQuoteBy, message: getMessage, status: false, didEdit: itemToEdit)
        print("ToSave")
    }

    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.cancel(by: self)
        print("CANCEL CANCEL")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTxtField.layer.borderWidth = 1
        quoteByTxtField.layer.borderWidth = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
