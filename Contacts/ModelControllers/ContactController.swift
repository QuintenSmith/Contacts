//
//  ContactController.swift
//  Contacts
//
//  Created by Quinten Smith on 9/28/18.
//  Copyright © 2018 Quinten Smith. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    
    static let shared = ContactController()
    
    private init() {}
    
    var contacts: [Contact] = []
    
    func save(contact: Contact, completion: @escaping (Bool) -> ()) {
        let recordEntry = CKRecord(contact: contact)
        CKContainer.default().publicCloudDatabase.save(recordEntry) { (record, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false); return
            }
            guard let record = record, let contact = Contact(ckRecord: record) else {completion(false); return}
            self.contacts.append(contact)
            completion(true)
        }
    }
    
    func createContact(name: String, phoneNumber: String, email: String, completion: @escaping(Bool) -> Void) {
        let contact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        self.save(contact: contact) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateContact(contact: Contact, name: String, phoneNumber: String, email: String, completion: @escaping (Bool) -> Void) {
        
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: contact.ckRecordID) { (record, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false); return
            }
            
            guard let record = record else {completion(false); return}
            
            record[Constants.NameKey] = name
            record[Constants.PhoneNumberKey] = phoneNumber
            record[Constants.EmailKey] = email
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, reordIDs, error) in
                completion(true)
            }
            
            CKContainer.default().publicCloudDatabase.add(operation) 
        }
    }
    
    func removeContact(contact: Contact, completion: @escaping (Bool) -> Void) {
        guard let index = ContactController.shared.contacts.index(of: contact) else {return}
        contacts.remove(at: index)
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: contact.ckRecordID) { (_, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false); return
            } else {
                print("Successfully deleted")
                completion(true)
            }
        }
    }
    
    func fetchContact(completion: @escaping(Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery.init(recordType: Constants.ContactRecordType, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error in \(#function); \(error); \(error.localizedDescription)")
                completion(false); return
            }
            
            guard let records = records else {completion(false); return}
            
            let contacts = records.compactMap{Contact(ckRecord: $0)}
            self.contacts = contacts
            completion(true) 
        }
    }
    
}
