//
//  ViewController.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.


//

import UIKit

class ViewController: UIViewController {
    
    struct LayoutOptions {
        // 0 is a No Room (wall).
        // 1 is a Room.
        // 2 is the Foyer.
        
        // This gives us two rows with four rooms.
        static let a = [
            [1, 2],
            [1, 1]
        ]
        static let b = [
            [1, 1, 1],
            [0, 2, 0]
        ]
    }
    // .reverse makes it so that what you see is what you get: the bottom most array ends up being the first, and so on.
    
    enum Direction: String {
        case North, South, East, West
    }
    
    let house = House(layout: LayoutOptions.a)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topRow = house.layout[1]
        let bottomRow = house.layout[0]
        
        print("top row is    \(topRow[0]) \(topRow[1])")
        print("bottom row is \(bottomRow[0]) \(bottomRow[1])")
        
        house.playerPosition = (1,1)
        
        print("current player position is \(house.playerPosition)")
        print("current room is \(roomForPositionInHouse(house.playerPosition)?.name)")
        print("0, 0 \(roomForPositionInHouse((x:0, y:0))!.name)")
        print("1, 0 \(roomForPositionInHouse((x:1, y:0))!.name)")
        print("0, 1 \(roomForPositionInHouse((x:0, y:1))!.name)")
        print("1, 1 \(roomForPositionInHouse((x:1, y:1))!.name)")

    }
    
    // Get a room in the house for a set of x and y coordinates.
    func roomForPositionInHouse(position:(x: Int, y: Int)) -> Room? {
        var room = house.noRoom
        if ( position.y >= 0 && position.y < house.layout.count ) {
            let row = house.layout[position.y]
            if ( position.x >= 0 && position.x < row.count ) {
                room = self.house.map[position.y][position.x]
            }
        }
        return room
    }
    
    func roomForName(name: String) -> Room? {
        var room = house.noRoom
        for r in house.rooms {
            if r.name == name {
                print("honk")
                room = r
            }
        }
        return room
    }
    

    
    // Checks if room exists at position
    func doesRoomExistAtPosition(position:(x: Int, y: Int)) -> Bool {
        let room = roomForPositionInHouse(position)
        if ( room!.name == "No Room" || position.y < 0 || position.x < 0 || position.x >= house.width || position.y >= house.height ) {
            return false
        } else {
            return true
        }
    }
    
    
    // Pass in a direction to move the player to a new room.
    // It also returns the data for the new room.
    func roomInDirection(direction:Direction) -> Room? {
        var potentialPosition = (x: house.playerPosition.x, y: house.playerPosition.y)
        switch direction {
        case .North:
            potentialPosition.y += 1
        case .South:
            potentialPosition.y -= 1
        case .East:
            potentialPosition.x += 1
        case .West:
            potentialPosition.x -= 1
        }
        
        // This makes sure that the new position is within the layout of the house
        // If it's not, the player's position stays as it is,
        // and the player's current room is returned.
        if ( doesRoomExistAtPosition(potentialPosition) == false ) {
            potentialPosition = house.playerPosition
        }
        let potentialRoom = roomForPositionInHouse(potentialPosition)
        house.playerPosition = potentialPosition
        
        return potentialRoom
    }
    
    // Checks for rooms around house.playerPosition
    func roomsAroundPlayer() {
        let roomPositionToNorth = (house.playerPosition.x, house.playerPosition.y+1)
        let roomPositionToWest = (house.playerPosition.x-1, house.playerPosition.y)
        let roomPositionToSouth = (house.playerPosition.x, house.playerPosition.y-1)
        let roomPositionToEast = (house.playerPosition.x+1, house.playerPosition.y)
        if ( doesRoomExistAtPosition(roomPositionToNorth) ) {
            print("\(roomForPositionInHouse(roomPositionToNorth)!.name) is to the north")
        } else { print("there is no room to the north") }
        if ( doesRoomExistAtPosition(roomPositionToWest) ) {
            print("\(roomForPositionInHouse(roomPositionToWest)!.name) is to the west")
        } else { print("there is no room to the west") }
        if ( doesRoomExistAtPosition(roomPositionToSouth) ) {
            print("\(roomForPositionInHouse(roomPositionToSouth)!.name) is to the south")
        } else { print("there is no room to the south") }
        if ( doesRoomExistAtPosition(roomPositionToEast) ) {
            print("\(roomForPositionInHouse(roomPositionToEast)!.name) is to the east")
        } else { print("there is no room to the east") }
    }
    
    
    // MARK: Moving around
    
    @IBAction func moveNorth(sender: AnyObject) {
        let northRoom = roomInDirection(Direction.North)
        print("\rMoving north, the room is the \(northRoom!.name)")
        roomsAroundPlayer()
        print("current player position is \(house.playerPosition)")
    }
    @IBAction func moveWest(sender: AnyObject) {
        let currentRoom = roomInDirection(Direction.West)
        print("\rMoving west, the room is the \(currentRoom!.name)")
        roomsAroundPlayer()
        print("current player position is \(house.playerPosition)")
    }
    @IBAction func moveSouth(sender: AnyObject) {
        let currentRoom = roomInDirection(Direction.South)
        print("\rMoving south, the room is the \(currentRoom!.name)")
        roomsAroundPlayer()
        print("current player position is \(house.playerPosition)")
    }
    @IBAction func moveEast(sender: AnyObject) {
        let currentRoom = roomInDirection(Direction.East)
        print("\rMoving east, the room is the \(currentRoom!.name)")
        roomsAroundPlayer()
        print("current player position is \(house.playerPosition)")
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

