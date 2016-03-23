//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/19/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var name = ""
    var stages : [Stage]? = []
    var currentStage : Stage?
    var completed = false
    var rules: [Rule]? = []

    init(name: String) {
        super.init()
        
        print("Finding event based on name...\r")
        let path = NSBundle.mainBundle().pathForResource("Events", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        // load each room into the array
        for (key,_) in dict! {
            print("Adding room...\r")
            
            // get individual dictionary
            let keyString = key as! String
            let eventDict = dict?.objectForKey(keyString)
            
            if name == eventDict?.objectForKey("name") as! String {
                self.setEventValuesForDictionary(eventDict)
            }
            
        }
        
        
    }
    
    func setEventValuesForDictionary(dict: AnyObject?) {
        if let name = dict!.objectForKey("name") { self.name = name as! String }
        if let stagesDictionary = dict!.objectForKey("stages") {
            for stageDictionary in stagesDictionary as! [NSDictionary] {
                let stage = Stage()
                stage.setStageValuesForDictionary(stageDictionary)
                
                self.stages?.append(stage)
            }
        }
        
        if let rulesDictionary = dict!.objectForKey("rules") { self.setRulesForDictionary(rulesDictionary) }
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
