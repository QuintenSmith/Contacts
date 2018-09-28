//
//  DetailViewController.swift
//  Contacts
//
//  Created by Quinten Smith on 9/28/18.
//  Copyright © 2018 Quinten Smith. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    func updateViews() {
        guard let contact = contact else {return}
        nameTextField.text = contact.name
        phoneTextField.text = contact.phoneNumber
        emailTextField.text = contact.email
    }
    
    @IBAction func saveBtnWasTapped(_ sender: Any) {
        guard let name = nameTextField.text, let phoneNumber = phoneTextField.text,
            let email = emailTextField.text, !name.isEmpty else {return}
        
        if let contact = contact{
            ContactController.shared.updateContact(contact: contact, name: name, phoneNumber: phoneNumber, email: email) { (success) in
                if success {
                    print("Successfully Updated!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Could not update")
                }
                
            }
        } else {
            ContactController.shared.createContact(name: name, phoneNumber: phoneNumber, email: email) { (success) in
                if success {
                    print("Success saving contact")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Unable to save contact")
                }
            }
        }
    }
    
    
}
