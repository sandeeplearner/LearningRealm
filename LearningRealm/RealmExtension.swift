//
//  RealmExtension.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

extension Object {
    func cascadeDeleteObject() {
        let realm = try! Realm()
        let mirroredObject = Mirror(reflecting: self)
        do {
            try realm.write {
                for (_,attr) in mirroredObject.children.enumerated() {
                    if let childernArray = attr.value as? RealmSwift.ListBase {
                        while childernArray.count > 0 {
                            let object = childernArray._rlmArray.lastObject()
                            realm.delete(object as! Object)
                        }
                    }
                    else if let object = attr.value as? RealmSwift.Object {
                        realm.delete(object)
                    }
                }
                realm.delete(self)
            }
        }
        catch {
            debugPrint(error)
        }
    }
}
