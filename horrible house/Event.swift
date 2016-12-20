//
//  Event.swift
//  horrible house
//
//  Created by TerryTorres on 3/19/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Event: NSObject, NSCoding, DictionaryBased, RuleBased {
    
    var name = ""
    var stages : [Stage] = []
    var currentStage : Stage?
    var rules: [Rule] = []
    var completed = false
    var sudden = false

    required init(withDictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "stages" {
                let dictArray = value as! [Dictionary<String, AnyObject>]
                for dict in dictArray {
                    let stage = Stage(withDictionary: dict)
                    self.stages += [stage]
                }
            }
            
            if key == "sudden" { // Sudden events can be called during the player turn. Otherwise, they trigger on an action
                self.sudden = true
            }
            
            if key == "rules" { self.setRulesForArray(array: value as! [String]) }
        }
    }
    
    init(name: String, stages: [Stage], currentStage: Stage?, rules: [Rule], completed: Bool, sudden: Bool) {
        self.name = name
        self.stages = stages
        self.currentStage = currentStage
        self.rules = rules
        self.completed = completed
        self.sudden = sudden
    }
    
    override init() {
        
    }
    
    // This will make the first stage in self.stages that follows the rules
    // into the default stage. This can be changed if a better method appears.
    func getStageThatFollowsRulesFromStagesArray(stages: [Stage]) -> Stage {
        print("EVENT – begin setCurrentStage")
        var s = Stage()
        for stage in stages {
            if stage.isFollowingTheRules() { s = stage ; break }
        }
        return s
    }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        
        coder.encode(self.name, forKey: "name")
        coder.encode(self.stages, forKey: "stages")
        
        
        if let currentStage = self.currentStage {
            coder.encode(currentStage, forKey: "currentStage")
        }
        
        coder.encode(self.rules, forKey: "rules")
        
        coder.encode(self.completed, forKey: "completed")
        
        coder.encode(self.sudden, forKey: "sudden")
        
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.stages = decoder.decodeObject(forKey: "stages") as! [Stage]
        if let currentStage = decoder.decodeObject(forKey: "currentStage") as? Stage? {
            self.currentStage = currentStage
        }
        self.rules = decoder.decodeObject(forKey: "rules") as! [Rule]
        self.completed = decoder.decodeBool(forKey: "completed")
        self.sudden = decoder.decodeBool(forKey: "sudden")

    }
    
}
