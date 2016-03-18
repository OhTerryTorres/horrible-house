//
//  Detail.swift
//  horrible house
//
//  Created by TerryTorres on 3/16/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Detail: NSObject {

    var explanation : String
    
    var rules : [Rule]? = []
    
    init(explanation:String) {
        
        self.explanation = explanation
        
    }
    
    func setRulesForDictionary(dict: AnyObject?) {
        var rules = [Rule]()
        
        if (dict!.objectForKey("rules") != nil) {
            for ruleName in dict!.objectForKey("rules") as! [String] {
                let rule = Rule(name: ruleName)
                print("rule.type \(rule.type)")
                rules += [rule]
            }
        }
        
        self.rules = rules
    }
}
