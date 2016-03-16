//
//  Room.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class Room: NSObject {
    
    // MARK: Properties
    
    var name: String
    var explanation: String
    var actions: [Action]? = []
    var actionsToDisplay: [Action]? = []
    var position = (x: 0, y: 0)
    var timesEntered = 0
    var charactersPresent = [Character]()
    var items: [Item]? = []
    

    init(name:String, explanation:String, actions:[Action]) {
        self.name = name
        self.explanation = explanation
        self.actions = actions
    }
    
    
}