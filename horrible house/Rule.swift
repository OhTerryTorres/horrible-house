//
//  Rule.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Rule: NSObject {
    
    // MARK: Properties
    
    var name : String
    
    var type = ""
    
    var followed = false
    
    struct RuleType {
        // Checks to see if the player has done something
        static let hasItem = "hasItem"
        static let metCharacter = "metCharacter"
        static let enteredRoom = "enteredRoom"
        static let completedEvent = "completedEvent"
        static let timesPerformed = "timesPerformed"
        
        // Checks to see if the player has NOT done something
        static let nopeHasItem = "nopeHasItem"
        static let nopeMetCharacter = "nopeMetCharacter"
        static let nopeEnteredRoom = "nopeEnteredRoom"
        static let nopeCompletedEvent = "nopeCompletedEvent"
        static let nopeTimesPerformed = "nopeTimesPerformed"
    }
    

    // When the ruletype is defined, the name is changed to whatever corresponds to the rule.
    // for example, if the rule in the plist was "hasGlasses", when it's initialized
    // name becomes "glasses" and type becomes "hasItem"
    
    init(name:String) {
        self.name = name
        
        if self.name.rangeOfString("\\nopeHas") != nil {
            type = RuleType.nopeHasItem
            self.name = self.name.stringByReplacingOccurrencesOfString("\\nopeHas", withString: "")
        }
        if self.name.rangeOfString("\\nopeMet") != nil {
            type = RuleType.nopeMetCharacter
            self.name = self.name.stringByReplacingOccurrencesOfString("\\nopeMet", withString: "")
        }
        if self.name.rangeOfString("\\nopeEntered") != nil {
            type = RuleType.nopeEnteredRoom
            self.name = self.name.stringByReplacingOccurrencesOfString("\\nopeEntered", withString: "")
        }
        if self.name.rangeOfString("\\nopeCompleted") != nil {
            type = RuleType.nopeCompletedEvent
            self.name = self.name.stringByReplacingOccurrencesOfString("\\nopeCompleted", withString: "")
        }
        if self.name.rangeOfString("\\nopeTimesPerformed") != nil {
            type = RuleType.nopeCompletedEvent
            self.name = self.name.stringByReplacingOccurrencesOfString("\\nopeTimesPerformed", withString: "")
        }
        
        if self.name.rangeOfString("\\has") != nil {
            type = RuleType.hasItem
            self.name = self.name.stringByReplacingOccurrencesOfString("\\has", withString: "")
        }
        if self.name.rangeOfString("\\met") != nil {
            type = RuleType.metCharacter
            self.name = self.name.stringByReplacingOccurrencesOfString("\\met", withString: "")
        }
        if self.name.rangeOfString("\\entered") != nil {
            type = RuleType.enteredRoom
            self.name = self.name.stringByReplacingOccurrencesOfString("\\entered", withString: "")
        }
        if self.name.rangeOfString("\\completed") != nil {
            type = RuleType.completedEvent
            self.name = self.name.stringByReplacingOccurrencesOfString("\\completed", withString: "")
        }
        if self.name.rangeOfString("\\timesPerformed") != nil {
            type = RuleType.completedEvent
            self.name = self.name.stringByReplacingOccurrencesOfString("\\timesPerformed", withString: "")
        }
        
    }

}
