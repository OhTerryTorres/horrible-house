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
            if key == "rules" { self.setRulesForArray(value as! [String]) }
        }
    }
    
    override init() {
        
    }
    
    init(explanation: String, rules: [Rule]) {
        self.explanation = explanation
        self.rules = rules
    }
    
    // MARK: ENCODING
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.explanation, forKey: "explanation")
        coder.encodeObject(self.rules, forKey: "rules")
        
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let explanation = decoder.decodeObjectForKey("explanation") as? String,
            let rules = decoder.decodeObjectForKey("rules") as? [Rule]
            else { return nil }
        
        self.init(explanation: explanation, rules: rules)
    }
}
