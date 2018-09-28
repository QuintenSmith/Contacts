//
//  Contact.swift
//  Contacts
//
//  Created by Quinten Smith on 9/28/18.
//  Copyright © 2018 Quinten Smith. All rights reserved.
//

import Foundation
import CloudKit

class Contact {
    
    var name: String
    var phoneNumber: String
    var email: String
    
    let ckRecordID: CKRecord.ID
    
    init(name: String, phoneNumber: String, email: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constants.NameKey] as? String,
            let phoneNumber = ckRecord[Constants.PhoneNumberKey] as? String,
            let email = ckRecord[Constants.EmailKey] as? String else { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: Constants.ContactRecordType)
        self.setValue(contact.name, forKey: Constants.NameKey)
        self.setValue(contact.phoneNumber, forKey: Constants.PhoneNumberKey)
        self.setValue(contact.email, forKey: Constants.EmailKey)
    }
}

struct Constants {
    static let ContactRecordType = "Contact"
    static let NameKey = "Name"
    static let PhoneNumberKey = "PhoneNumber"
    static let EmailKey = "Email"
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name && lhs.phoneNumber == rhs.phoneNumber && lhs.email == rhs.email
    }
}
