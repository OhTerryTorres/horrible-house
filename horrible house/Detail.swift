//
//  Detail.swift
//  horrible house
//
//  Created by TerryTorres on 3/16/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Detail : DictionaryBased, RuleBased {

    var explanation : String = ""
    
    var rules : [Rule] = []
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "explanation" { self.explanation = value as! String }
            if key == "rules" { self.setRulesForArray(value as! [String]) }
        }
    }
    
    init() {
        
    }
}
