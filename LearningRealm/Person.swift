//
//  Person.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/7/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import Foundation
import RealmSwift

class Person : Object {
    @objc dynamic var firstName : String? = nil
    @objc dynamic var lastName : String? = nil
    @objc dynamic var age : Int = 0
    @objc dynamic var id : String? = nil
    let owns : List<Dogs> = List<Dogs>()
    @objc dynamic var phoneNumber : String? = nil
    
    var fullName : String {
        return "\(firstName!) \(lastName!)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
