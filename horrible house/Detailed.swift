//
//  Detailed.swift
//  horrible house
//
//  Created by TerryTorres on 4/5/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation

protocol Detailed : class {
    var details : [Detail] { get set }
}

extension Detailed {
    func setDetailsForArrayOfDictionaries(dictArray:[Dictionary<String, AnyObject>]) {
        for dict in dictArray {
            let detail = Detail(withDictionary: dict)
            self.details += [detail]
        }
    }
    
}