//
//  PersonsCustomSection.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import Foundation
import RxDataSources

struct PersonsCustomSection {
    var items : [Item]
}

extension PersonsCustomSection : SectionModelType {
    init(original: PersonsCustomSection, items: [Person]) {
        self = original
        self.items = items
    }
    
    typealias Item = Person
}
