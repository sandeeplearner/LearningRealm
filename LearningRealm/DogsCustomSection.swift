//
//  DogsCustomSection.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import Foundation
import RxDataSources

struct DogsCustomSection {
    var items : [Item]
}

extension DogsCustomSection : SectionModelType {
    init(original: DogsCustomSection, items: [Dogs]) {
        self = original
        self.items = items
    }
    
    typealias Item = Dogs
}

