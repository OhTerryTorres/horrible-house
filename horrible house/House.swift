//
//  House.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class House: NSObject {
    
    
    struct RoomType {
        static let noRoom = 0
        static let normal = 1
        static let foyer = 2
    }
    
    
    // MARK: Properties
    
    var width = 0
    var height = 0
    
    // Array for all rooms in the Rooms.plist
    var rooms = [Room]()
    
    // MARK: Characters
    var player = Character(name:"Player")
    var npcs:[Character]? = []
    
    // The x/y grid of room names use to navigate the house.
    //
    // 2[0, 1, 1, 3]
    // 1[0, 1, 2, 3]
    // 0[0, 1, 2, 3]
    var layout = [[Int]]()
    
    var map = [[Room]]()

    
    // MARK: Room Templates
    
    let noRoom = Room(name: "No Room", explanation: "This is the absence of a room", actions: [Action(name: "Nothing doing")])
    var foyer = Room(name: "Foyer", explanation: "Less than a handful of lit wall sconces show only the dark wood of the entryway and three ways deeper into the house, along with the front door.", actions: [Action(name: "Lick the wall"), Action(name: "Fart"), Action(name: "Leave \\once")])
    
    
    // MARK: Initialization
    
    init (layout:[[Int]]) {
        super.init()
        self.layout = layout.reverse()
        print("layout is \(self.layout)")
        
        setNecessaryRooms()
        loadRooms()
        drawMap()
    }
    
    func setNecessaryRooms() {
        // Add rules to actions
        print("self.foyer.actions![1].name is \(self.foyer.actions![1].name)")
        self.foyer.actions![2].rules = [Rule(name: "\\hasHole")]
        self.foyer.actions![2].result = "Okay, so long."
        self.foyer.actions![2].roomChange = ""
    }
    
    func loadRooms() {
        
        print("Loading rooms in house...\r")
        let path = NSBundle.mainBundle().pathForResource("Rooms", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        // load each room into the array
        for (key,_) in dict! {
            print("Adding room...\r")
            
            // get individual dictionary
            let keyString = key as! String
            let roomDict = dict?.objectForKey(keyString)
            
            // Strip dictionary components into seperate values
            let name = roomDict?.objectForKey("name") as! String
            
            let explanation = roomDict?.objectForKey("explanation") as! String
            
            let actions = getActionsForRoomDictionary(roomDict)
            
            let items = getItemsForRoomDictionary(roomDict)
            
            // Put those values into a Meal object
            let room = Room(name: name, explanation: explanation, actions: actions)
            room.items = items
            room.actionsToDisplay = actions
            
            self.rooms += [room]
        }
        print("Finished adding rooms.\r")
    }
    
    
    // This does the work of extracting action info from the Rooms.plist
    func getActionsForRoomDictionary(roomDict: AnyObject?) -> [Action] {
        var actions = [Action]()
        
        let rawActions = roomDict!.objectForKey("actions") as! [NSDictionary]
        
        for actionDictionary in rawActions {
            var name = String()
            var rules = [Rule]()
            var result = String?()
            var roomChange = String?()
            var itemToPresent = Item?()
            
            
            if (actionDictionary.objectForKey("name") != nil) {
                name = actionDictionary.objectForKey("name") as! String
            }
            if (actionDictionary.objectForKey("rules") != nil) {
                rules = getRulesForActionDictionary(actionDictionary)
            }
            if (actionDictionary.objectForKey("result") != nil) {
                result = actionDictionary.objectForKey("result") as? String
            }
            if (actionDictionary.objectForKey("roomChange") != nil) {
                roomChange = actionDictionary.objectForKey("roomChange") as? String
            }
            if (actionDictionary.objectForKey("itemToPresent") != nil) {
                itemToPresent = Item(name: (actionDictionary.objectForKey("itemToPresent") as? String)!)
            }
            
            let action = Action(name: name)
            if rules.count > 0 { action.rules = rules}
            if let res = result { action.result = res }
            if let rc = roomChange { action.roomChange = rc }
            if let item = itemToPresent { action.itemToPresent = item }
            
            actions += [action]
        }
        
        return actions
    }
    
    
    // This does the work of extracting rules from each action.
    func getRulesForActionDictionary(actionDict: AnyObject?) -> [Rule] {
        var rules = [Rule]()
        
        if (actionDict!.objectForKey("rules") != nil) {
            for ruleName in actionDict!.objectForKey("rules") as! [String] {
                let rule = Rule(name: ruleName)
                print("rule.type \(rule.type)")
                rules += [rule]
            }
        }
        
        return rules
    }
    
    func getItemsForRoomDictionary(roomDict: AnyObject?) -> [Item] {
        var items = [Item]()
        if (roomDict!.objectForKey("items") != nil) {
            for itemName in roomDict?.objectForKey("items") as! [String] {
                let item = Item(name: itemName)
                items += [item]
            }
        }
        return items
    }
    
    // Pre-fill the house map with noRooms to make it easier to change the rooms later.
    func prepopulateMap(width: Int, height: Int) {
        print("Prepopulating map...\r")
        for( var y = 0; y < height; y++ ) {
            var row = [Room]()
            for( var x = 0; x < width; x++ ) {
                row.append(self.noRoom)
            } // end of x for loop
            self.map.append(row)
        } // end of y for loop
        
    }
    
    func drawMap() {
        print("Drawing map of house...\r")
        
        self.width = self.layout[0].count // Ideally, all of the arrays should be the same count. We'll see.
        self.height = self.layout.count
        
        print("maxWidth is \(self.width)")
        print("maxHeight is \(self.height)")
        
        prepopulateMap(self.width, height: self.height)
        
        var roomIndex = 0
        
        for( var y = 0; y < self.height; y++ ) {
            print("Drawing row number \(y)...\r")
            for( var x = 0; x < self.width; x++ ) {
                print("Drawing room number \(x)...\r")
                print("int at self.layout[y][x] is \(self.layout[y][x])\r")
                // Draw the room
                switch ( self.layout[y][x] ) {
                    case RoomType.foyer:
                        print("Drawing foyer.\r")
                        self.foyer.position = (x:x, y:y)
                        self.map[y][x] = self.foyer
                    case RoomType.noRoom:
                        print("Drawing no room.\r")
                        self.map[y][x] = self.noRoom
                    default:
                        print("Drawing room.\r")
                        self.rooms[roomIndex].position = (x:x, y:y)
                        let room = self.rooms[roomIndex]
                        print("self.rooms[roomIndex] is \(room.name)\r")
                        self.map[y][x] = room
                        roomIndex++
                }
                self.map[y][x].position = (x: x, y: y)
                print("End of x for loop.\r")
            } // end of x for loop
            if roomIndex == self.rooms.count {
                break
            }
            print("End of y for loop.\r")
        } // end of y for loop
        
    }

}
