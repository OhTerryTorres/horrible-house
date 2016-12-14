//
//  Detail.swift
//  horrible house
//
//  Created by TerryTorres on 3/16/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Detail : NSObject, NSCoding, DictionaryBased, RuleBased {

    var explanation : String = ""
    
    var rules : [Rule] = []
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        for (key, value) in withDictionary {
            if key == "explanation" { self.explanation = value as! String }
            if key == "rules" { self.setRulesForArray(array: value as! [String]) }
        }
    }
    
    override init() {
        
    }
    
    init(explanation: String, rules: [Rule]) {
        self.explanation = explanation
        self.rules = rules
    }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.explanation, forKey: "explanation")
        coder.encode(self.rules, forKey: "rules")
        
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.explanation = decoder.decodeObject(forKey: "explanation") as! String
        self.rules = decoder.decodeObject(forKey: "rules") as! [Rule]

    }
}
