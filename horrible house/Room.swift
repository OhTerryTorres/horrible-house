//
//  Room.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Room: DictionaryBased, ItemBased, ActionPacked, Detailed {
    
    var name = ""
    var explanation = ""
    var details: [Detail] = []
    var actions: [Action] = []
    var position = (x: 0, y: 0, z:0)
    var timesEntered = 0
    var charactersPresent: [Character] = []
    var items: [Item] = []
    var placementGuidelines: [String] = []
    
    required init(withDictionary: Dictionary<String, AnyObject>) {
        for (key, value) in withDictionary {
            if key == "name" { self.name = value as! String }
            if key == "explanation" { self.explanation = value as! String }
            if key == "details" { self.setDetailsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            if key == "actions" { self.setActionsForArrayOfDictionaries(value as! [Dictionary<String, AnyObject>]) }
            if key == "items" { self.setItemsForDictionary(value as! [Dictionary<String, AnyObject>]) }
            if key == "placementGuidelines" {
                let placementGuidlines = value as! [String]
                for placement in placementGuidlines {
                    self.placementGuidelines += [placement]
                }
            }
        }
    }
    
    init() {
        
    }

}
