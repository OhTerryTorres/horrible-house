//
//  House.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class House: NSObject {
    
    // MARK: Potential layout
    
    struct LayoutOptions {
        // This gives us two rows with four rooms.
        // 998 show us potential rooms, 999 shows us empty (unenterable) space.
        static let layoutOption0 = [[998, 1000], [998, 998]]
        
    }
    
    // MARK: Properties
    
    // Array for all rooms in the Rooms.plist
    var rooms = [Room]()
    // Remembers where the player currently is.
    var playerPosition = (x: 0, y: 0)
    // The an x/y grid of room names use to navigate the house.
    //
    // 2[0, 1, 1, 3]
    // 1[0, 1, 2, 3]
    // 0[0, 1, 2, 3]
    var layout = [[String]]()
    
    // MARK: Room Templates
    
    let noRoom = Room(name: "No Room", explanation: "This is the absence of a room", actions: ["Nothing doing"])
    
    
    
    // MARK: Initialization
    
    override init () {
        super.init()
        
        let path = NSBundle.mainBundle().pathForResource("Rooms", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        // load each room into the array
        for (key,_) in dict! {
            // get individual dictionary
            let keyString = key as! String
            let roomDict = dict?.objectForKey(keyString)
            
            // Strip dictionary components into seperate values
            let name = roomDict?.objectForKey("name") as! String
            
            print("name is \(name)")
            
            let explanation = roomDict?.objectForKey("explanation") as! String
            
            print("explanation is \(explanation)")
            
            let actions = roomDict?.objectForKey("actions") as! [String]
            
            print("actions[0] is \(actions[0])")
            
            // Put those values into a Meal object
            let room = Room(name: name, explanation: explanation, actions: actions)
            
            self.rooms += [room]
        }
        
        // Remove Foyer from rooms to be inserted at the appropriate layout position
        let foyerRoomNumber = roomNumberForRoomName("Foyer")
        let foyer = rooms[foyerRoomNumber]
        rooms.removeAtIndex(foyerRoomNumber)
        
        // Figuring out the layout.
        var i = 0
        var y = 0
        var x = 0
        
        while i < rooms.count {
            // Start on the first row, and then go up.
            print("i is \(i)")
            
            while y < LayoutOptions.layoutOption0.count {
                // Get the array of room positions at the current row.
                print("y is \(y)")
                
                var newRow = [String]()
                
                var currentRow = LayoutOptions.layoutOption0[y]
                // Prepare newRow to become a new row.
                // Go through each room position on the row.
                while x < currentRow.count {
                    // Make array of a row of rooms to add to the layout.
                    print("x is \(x)")
                    
                    var room = foyer
                    
                    // Check if room position is asking for a new room
                    // ++i, because
                    if ( currentRow[x] == 998 ) {
                        print("room available")
                        room = rooms[i]
                        print("room is \(room.name)")
                        ++i
                    // Check if room position is a wall, or just not a room
                    } else if ( currentRow[x] == 999 ) {
                        print("room available")
                        let room = noRoom
                        print("room is \(room.name)")
                    // Check if room position is where the foyer/lobby should be.
                    } else if ( currentRow[x] == 1000 ) {
                        print("room available")
                        let room = foyer
                        print("room is \(room.name)")
                    }
                    newRow.insert(room.name, atIndex: x)
                    ++x
                }
                // Add the filled out row to the house's layout
                layout += [newRow]
                // Move on to the next row
                ++y
                x = 0
            }
        }
        
    }
    
    
    // This will return a room and it's position in the house.rooms array
    // Mostly used to pull out the foyer from the rooms array.
    func roomNumberForRoomName(name: String) -> (Int) {
        var roomNumber = Int()
        if let i = rooms.indexOf({$0.name == name}) {
            roomNumber = i
        }
        return roomNumber
    }

}
