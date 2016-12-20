//
//  Rule.swift
//  horrible house
//
//  Created by TerryTorres on 3/11/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Rule: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name = ""
    
    var type = ""
    
    struct RuleType {
        // Checks to see if the player has done something
        static let hasItem = "hasItem"
        static let metCharacter = "metCharacter"
        static let enteredRoom = "enteredRoom"
        static let completedEvent = "completedEvent"
        static let inRoomWithCharacter = "inRoomWithCharacter"
        static let timePassed = "timePassed" // \timePassed12:00
        static let turnsPassed = "turnsPassed"
        static let didStoreItem = "didStoreItem"
        static let occupyingRoom = "occupyingRoom"
        
        // Checks to see if the player has NOT done something
        static let nopeHasItem = "nopeHasItem"
        static let nopeMetCharacter = "nopeMetCharacter"
        static let nopeEnteredRoom = "nopeEnteredRoom"
        static let nopeCompletedEvent = "nopeCompletedEvent"
        static let nopeInRoomWithCharacter = "nopeInRoomWithCharacter"
        static let nopeTimePassed = "nopeTimePassed"
        static let nopeTurnsPassed = "nopeTurnsPassed"
        static let nopeDidStoreItem = "nopeDidStoreItem"
        
        // These are rules that don't have a negative yet
        static let roomInDirection = "roomInDirection"
    }
    

    // When the ruletype is defined, the name is changed to whatever corresponds to the rule.
    // for example, if the rule in the plist was "hasGlasses", when it's initialized
    // name becomes "glasses" and type becomes "hasItem"
    
    init(name:String) {
        super.init()
        
        self.name = name
        
        if self.name.range(of: "\\nopeHas") != nil {
            self.type = RuleType.nopeHasItem
            self.name = self.name.replacingOccurrences(of: "\\nopeHas", with: "")
        }
        if self.name.range(of: "\\nopeMet") != nil {
            type = RuleType.nopeMetCharacter
            self.name = self.name.replacingOccurrences(of: "\\nopeMet", with: "")
        }
        if self.name.range(of: "\\nopeEntered") != nil {
            type = RuleType.nopeEnteredRoom
            self.name = self.name.replacingOccurrences(of: "\\nopeEntered", with: "")
        }
        if self.name.range(of: "\\nopeCompleted") != nil {
            type = RuleType.nopeCompletedEvent
            self.name = self.name.replacingOccurrences(of: "\\nopeCompleted", with: "")
        }
        if self.name.range(of: "\\nopeInRoomWith") != nil {
            type = RuleType.nopeInRoomWithCharacter
            self.name = self.name.replacingOccurrences(of: "\\nopeInRoomWith", with: "")
        }
        if self.name.range(of: "\\nopeTimePassed") != nil {
            type = RuleType.nopeTimePassed
            self.name = self.name.replacingOccurrences(of: "\\nopeTimePassed", with: "")
        }
        if self.name.range(of: "\\nopeTurnsPassed") != nil {
            type = RuleType.nopeTurnsPassed
            self.name = self.name.replacingOccurrences(of: "\\nopeTurnsPassed", with: "")
        }
        if self.name.range(of: "\\nopeDidStore") != nil {
            type = RuleType.nopeDidStoreItem
            self.name = self.name.replacingOccurrences(of: "\\nopeDidStore", with: "")
        }

        
        if self.name.range(of: "\\has") != nil {
            type = RuleType.hasItem
            self.name = self.name.replacingOccurrences(of: "\\has", with: "")
        }
        if self.name.range(of: "\\met") != nil {
            type = RuleType.metCharacter
            self.name = self.name.replacingOccurrences(of: "\\met", with: "")
        }
        if self.name.range(of: "\\entered") != nil {
            type = RuleType.enteredRoom
            self.name = self.name.replacingOccurrences(of: "\\entered", with: "")
        }
        if self.name.range(of: "\\completed") != nil {
            type = RuleType.completedEvent
            self.name = self.name.replacingOccurrences(of: "\\completed", with: "")
        }
        if self.name.range(of: "\\inRoomWith") != nil {
            type = RuleType.inRoomWithCharacter
            self.name = self.name.replacingOccurrences(of: "\\inRoomWith", with: "")
        }
        if self.name.range(of: "\\timePassed") != nil {
            type = RuleType.timePassed
            self.name = self.name.replacingOccurrences(of: "\\timePassed", with: "")
        }
        if self.name.range(of: "\\turnsPassed") != nil {
            type = RuleType.turnsPassed
            self.name = self.name.replacingOccurrences(of: "\\turnsPassed", with: "")
        }
        if self.name.range(of: "\\didStore") != nil {
            type = RuleType.didStoreItem
            self.name = self.name.replacingOccurrences(of: "\\didStore", with: "")
        }
        
        if self.name.range(of: "\\occupying") != nil {
            type = RuleType.occupyingRoom
            self.name = self.name.replacingOccurrences(of: "\\occupying", with: "")
        }
        
        if self.name.range(of: "\\roomInDirection") != nil {
            type = RuleType.roomInDirection
            self.name = self.name.replacingOccurrences(of: "\\timePassed", with: "")
        }
        
    }
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
    
    override init() {
        
    }
    
    // MARK: ENCODING
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(self.type, forKey: "type")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.type = decoder.decodeObject(forKey: "type") as! String

    }

}
