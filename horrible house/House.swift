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
    
    // Remembers where the player currently is.
    var playerPosition = (x: 0, y: 0)
    
    // The x/y grid of room names use to navigate the house.
    //
    // 2[0, 1, 1, 3]
    // 1[0, 1, 2, 3]
    // 0[0, 1, 2, 3]
    var layout = [[Int]]()
    
    var map = [[Room]]()

    
    // MARK: Room Templates
    
    let noRoom = Room(name: "No Room", explanation: "This is the absence of a room", actions: ["Nothing doing"])
    let foyer = Room(name: "Foyer", explanation: "Less than a handful of lit wall sconces show only the dark wood of the entryway and three ways deeper into the house, along with the front door.", actions: ["Lick the wall", "Fart", "Leave"])
    
    
    // MARK: Initialization
    
    init (layout:[[Int]]) {
        super.init()
        self.layout = layout.reverse()
        print("layout is \(self.layout)")
        
        loadRooms()
        drawMap()
    }
    
    
    func loadRooms() {
        print("Loading rooms in house...")
        let path = NSBundle.mainBundle().pathForResource("Rooms", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        // load each room into the array
        for (key,_) in dict! {
            print("Adding room...")
            
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
        print("Finished adding rooms.")
    }
    
    func prepopulateMap(width: Int, height: Int) {
        print("Prepopulating map...")
        for( var y = 0; y < height; y++ ) {
            var row = [Room]()
            for( var x = 0; x < width; x++ ) {
                row.append(self.noRoom)
            } // end of x for loop
            self.map.append(row)
        } // end of y for loop
        
    }
    
    func drawMap() {
        print("Drawing map of house...")
        
        self.width = self.layout[0].count // Ideally, all of the arrays should be the same count. We'll see.
        self.height = self.layout.count
        
        print("maxWidth is \(self.width)")
        print("maxHeight is \(self.height)")
        
        prepopulateMap(self.width, height: self.height)
        
        var roomIndex = 0
        
        for( var y = 0; y < self.height; y++ ) {
            print("Drawing row number \(y)...")
            for( var x = 0; x < self.width; x++ ) {
                print("Drawing room number \(x)...")
                print("int at self.layout[y][x] is \(self.layout[y][x])")
                // Draw the room
                switch ( self.layout[y][x] ) {
                    case RoomType.foyer:
                        print("Drawing foyer.")
                        self.map[y][x] = self.foyer
                    case RoomType.noRoom:
                        print("Drawing no room.")
                        self.map[y][x] = self.noRoom
                    default:
                        print("Drawing room.")
                        let room = self.rooms[roomIndex]
                        print("self.rooms[roomIndex] is \(room.name)")
                        self.map[y][x] = room
                        roomIndex++
                }
                print("End of x for loop.")
            } // end of x for loop
            if roomIndex == self.rooms.count {
                break
            }
            print("End of y for loop.")
        } // end of y for loop
        
    }

}
