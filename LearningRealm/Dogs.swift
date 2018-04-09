//
//  Dogs.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import Foundation
import RealmSwift

class Dogs : Object {
    @objc dynamic var name : String? = nil
    var age : RealmOptional<Int>! = nil
    @objc dynamic var ownedBy : Person? = nil
    @objc dynamic var id : String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
