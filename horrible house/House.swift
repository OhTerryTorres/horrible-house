
//
//  House.swift
//  horrible house
//
//  Created by TerryTorres on 2/10/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class House : NSObject, NSCoding {
    struct RoomType {
        static let noRoom = 0
        static let normal = 1
        static let foyer = 2
        static let stairsDownToBasement = 3
        static let stairsUpToFirst = 4
        static let stairsUpToSecond = 5
        static let stairsDownToFirst = 6
        static func roomName (id: Int) -> String {
            let n = [
                "No Room", // 0
                "No Room", // This would correspond to the "normal" room state, so it shouldn't come up.
                "Foyer", // 2
                "Basement Stairs", // 3
                "Basement Landing", // 4
                "Stairs Ascending", // 5
                "Second Floor Landing" // 6
            ]
            return n[id]
        }
    }
    
    struct LayoutOptions {
        // 0 is a No Room (wall).
        // 1 is a Room.
        // 2 is the Foyer.
        // 3 is First -> Basement Stairs.
        // 4 is Basement -> First Stairs.
        // 5 is First -> Second Stairs.
        // 6 is Second -> First Stairs.
        
        // This gives us two rows with four rooms.
        static let a = [
            [[1, 2],
            [1, 1]]
        ]
        // This gives us two rows with four rooms, with noRooms (walls) on either side of the foyer.
        static let b = [
            [[0, 0, 0],
                [0, 0, 1,],
                [0, 0, 6,]],
            
            [[1, 1, 3],
                [1, 1, 1],
                [0, 2, 5]], // first floor = 1
            
            [[0, 1, 4],
                [0, 0, 0],
                [0, 0, 0]]  // basement = 0
        ]
    }
    
    
    enum Direction: String {
        case North, South, East, West
    }
    
    var gameClock = GameClock()
    
    // MARK: Properties
    var width = 0
    var height = 0
    var depth = 0
    
    // Array for all rooms in the Rooms.plist
    var rooms: [Room] = []
    // Array for all events in the Rooms.plist
    var events: [Event] = []
    
    // MARK: Characters
    var player = Character(name: "Player", position: (0,0,0))
    var npcs:[Character] = []
    
    // MARK: Navigation
    var layout = [[[Int]]]()
    var map = [[[Room]]]()
    
    var currentFloor = [[Room]]()
    
    
    // MARK: Room Templates
    
    var necessaryRooms : [String : Room] = [:]
    
    var noRoom = Room()
    var foyer = Room()
    var stairsDownToBasement = Room()
    var stairsUpToFirst = Room()
    var stairsUpToSecond = Room()
    var stairsDownToFirst = Room()
    
    // The room that is being presented for exploration.
    // This will be set by the game controllers.
    var currentRoom : Room {
        var room = self.noRoom
        if let r = self.roomForPosition(player.position) {
            room = r
        }
        return room
    }
    
    // The event that is being presented for interaction.
    // This will be set by the game controllers.
    var currentEvent = Event()
    
    // The skull will be watching to update its ideas
    
    var skull = Skull()
    
    override init(){
        
    }
    
    init(layout: [[[Int]]]) {
        super.init()
        
        self.layout = self.reverseLayout(layout)
        (self.width, self.height, self.depth) = getDimensionsFromLayout(layout)
        self.necessaryRooms = getNecessaryRoomsDictFromPlistName("NecessaryRooms")
        self.loadEvents()
        self.loadRooms()
        self.drawMap()
        
        
    }
    
    // MARK: Setup Functions
    
    func reverseLayout(layout: [[[Int]]]) -> [[[Int]]] {
        let layoutReversed = layout.reverse()
        
        // Reverse each floor's layout so that north and south make sense
        var i = 0
        var l = Array(layoutReversed)
        for _ in l {
            l[i] = l[i].reverse()
            i += 1
        }
        return l
    }
    
    func getDimensionsFromLayout( layout: [[[Int]]] ) -> (Int, Int, Int) {
        let width = self.layout[0][0].count
        let height = self.layout[0].count
        let depth = self.layout.count
        return (width, height, depth)
    }
    
    func getNecessaryRoomsDictFromPlistName(filename: String) -> [String: Room] {
        
        var dict : [String : Room] = [:]
        for (_,value) in self.dictForPlistFilename(filename) {
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            dict[room.name] = room
        }
        
        /*
        for (_,value) in self.dictForPlistFilename("NecessaryRooms") {
            // These needs to match the names are they are in the NecessaryRooms.plist
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            if room.name == "Foyer" { self.foyer = room }
            if room.name == "No Room" { self.noRoom = room }
            if room.name == "Basement Stairs" { self.stairsDownToBasement = room }
            if room.name == "Basement Landing" { self.stairsUpToFirst = room }
            if room.name == "Stairs Ascending" { self.stairsUpToSecond = room }
            if room.name == "Second Floor Landing" { self.stairsDownToFirst = room }
        }
        */
        
        return dict
        
    }
    
    func dictForPlistFilename(filename: String) -> Dictionary<String,AnyObject> {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
    }
    
    func loadRooms() {
        //self.rooms = []
        for (_, value) in self.dictForPlistFilename("Rooms") {
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            self.rooms += [room]
        }
        
        self.rooms.shuffleInPlace()
    }
    
    func loadEvents() {
        for (_, value) in self.dictForPlistFilename("Events") {
            let event = Event(withDictionary: value as! Dictionary<String,AnyObject>)
            self.events += [event]
        }
    }
    
    
    
    // Pre-fill the floor with noRooms to make it easier to change the rooms later.
    func prepopulatedFloor(withDimensions: (width: Int, height: Int, depth: Int)) -> [[Room]] {
        print("HOUSE – Prepopulating map...\r")
        var floor = [[Room]]()
            for _ in 0 ..< height {
                var row = [Room]()
                for _ in 0 ..< width {
                    row.append(self.noRoom)
                } // end of x for loop
                floor.append(row)
            } // end of y for loop
        
        return floor
    }
    
    
    func drawMap() {
        print("HOUSE – Drawing map of house...\r")
        
        let dimensions = (self.width, self.height, self.depth)
        var floor = prepopulatedFloor(dimensions)
        
        var roomIndex = 0
        
        var mustBreakGuidelineLoop = false
        
        var room = Room()
        
        for z in 0 ..< depth {
            for y in 0 ..< height {
                for x in 0 ..< width {
                    print("HOUSE – \(x) \(y) \(z)")
                    // Draw the room
                    switch ( self.layout[z][y][x] ) {
                        
                    case RoomType.foyer:
                        room = self.necessaryRooms[RoomType.roomName(RoomType.foyer)]!
                        self.foyer.position = (x:x, y:y, z:z)
                        floor[y][x] = self.foyer
                        print("HOUSE – \(self.foyer.name) is at position \(self.foyer.position)")
                        self.addCharactersInRoomToNPCsArray(self.foyer)
                        
                    case RoomType.stairsDownToBasement:
                        self.stairsDownToBasement.position = (x:x, y:y, z:z)
                        floor[y][x] = self.stairsDownToBasement
                        print("HOUSE – \(self.stairsDownToBasement.name) is at position \(self.stairsDownToBasement.position)")
                        self.addCharactersInRoomToNPCsArray(self.stairsDownToBasement)
                        
                    case RoomType.stairsUpToFirst:
                        self.stairsUpToFirst.position = (x:x, y:y, z:z)
                        floor[y][x] = self.stairsUpToFirst
                        print("HOUSE – \(self.stairsUpToFirst.name) is at position \(self.stairsUpToFirst.position)")
                        self.addCharactersInRoomToNPCsArray(self.stairsUpToFirst)
                        
                    case RoomType.stairsUpToSecond:
                        self.stairsUpToSecond.position = (x:x, y:y, z:z)
                        floor[y][x] = self.stairsUpToSecond
                        print("HOUSE – \(self.stairsUpToSecond.name) is at position \(self.stairsUpToSecond.position)")
                        self.addCharactersInRoomToNPCsArray(self.stairsUpToSecond)
                        
                    case RoomType.stairsDownToFirst:
                        self.stairsDownToFirst.position = (x:x, y:y, z:z)
                        floor[y][x] = self.stairsDownToFirst
                        print("HOUSE – \(self.stairsDownToFirst.name) is at position \(self.stairsDownToFirst.position)")
                        self.addCharactersInRoomToNPCsArray(self.stairsDownToFirst)
                        
                    case RoomType.noRoom:
                        floor[y][x] = self.noRoom
                        
                    default:
                        
                    
                        var i = 0
                        while ( guidelinesAreMet(forRoom: self.rooms[roomIndex], atPosition: (x:x, y:y, z:z)) == false || self.rooms[roomIndex].isInHouse == true ) {
                            
                            if i > self.rooms.count * 3 {
                                print("HOUSE – stuck in loop, attempting to break")
                                mustBreakGuidelineLoop = true
                                //break
                            } else {
                                print("HOUSE – guidelines for \(self.rooms[roomIndex].name) at (\(x), \(y), \(z)) are not met yet – shifting the rooms")
                                
                                self.rooms.shiftRightInPlace()
                                
                                print("HOUSE – next room after shifting is \(self.rooms[roomIndex].name)")
                            }
                            
                            while ( self.rooms[roomIndex].isInHouse == true ) {
                                print("HOUSE – \(self.rooms[roomIndex].name) has already been positioned in the house")
                                
                                self.rooms.shiftRightInPlace()
                                
                            }
                            
                            i += 1
                            
                            if mustBreakGuidelineLoop {
                                print("HOUSE – mustBreakGuidelineLoop")
                                if self.rooms[roomIndex].isInHouse == false {
                                    print("HOUSE – \(self.rooms[roomIndex].name) is being placed into a position that does not adhere to guidelines")
                                    break
                                }
                            }
                        }
                        
                        self.rooms[roomIndex].position = (x:x, y:y, z:z)
                        let room = self.rooms[roomIndex]
                        room.isInHouse = true // 
                        floor[y][x] = room
                        print("HOUSE – \(room.name) is at position \(room.position)")
                        self.addCharactersInRoomToNPCsArray(room)
                        roomIndex += 1
                        
                    }
                    
                    floor[y][x].position = (x:x, y:y, z:z)
                    print("HOUSE – End of x for loop.\r")
                } // end of x for loop
                
                if roomIndex > self.rooms.count {
                    print("HOUSE – roomIndex is \(roomIndex)")
                    // break
                }
                print("HOUSE – End of y for loop.\r")
            } // end of y for loop
            
            self.map += [floor]
            floor = prepopulatedFloor(dimensions)
        } // end of z for loop
        
    }
    
    func addCharactersInRoomToNPCsArray(room: Room) {
        for character in room.characters {
            self.npcs += [character]
            character.position = room.position
        }
    }
    
    
    // This function is the method used to put each of the rooms in the right spot.
    
    func guidelinesAreMet(forRoom room: Room, atPosition position: (x:Int, y:Int, z:Int)) -> Bool {
        var bool = true
        
        if let dict = room.placementGuidelines {
            for (key,value) in dict {
                if ( key.rangeOfString("floor") != nil ) {
                    print("HOUSE – guideline key for \(room.name) is FLOOR")
                    let floorNumber = value as! Int
                    print("HOUSE – floorNumber for \(room.name) is \(value)")
                    
                    if floorNumber != position.z {
                        print("HOUSE – \(room.name) needs to be on floor \(floorNumber)! This is floor \(position.z)")
                        bool = false
                    }
                }
                if ( key.rangeOfString("edge") != nil ) {
                    print("HOUSE – guideline key is EDGE")
                    if ( position.x == 0 || position.x == self.width-1 || position.y == 0 || position.y == self.height-1 ) {
                        
                    } else {
                        print("HOUSE – self.width is \(self.width)")
                        print("HOUSE – self.width-1 is \(self.width-1)")
                        print("HOUSE – self.height is \(self.height)")
                        print("HOUSE – self.height-1 is \(self.height-1)")
                        print("HOUSE – \(room.name) needs to be at a floor's edge, not in the middle")
                        bool = false
                    }
                }
                
                if ( key.rangeOfString("middle") != nil ) {
                    print("HOUSE – guideline key is MIDDLE")
                    if ( position.x == 0 || position.x == self.width-1 || position.y == 0 || position.y == self.height-1 ) {
                        print("HOUSE – \(room.name) needs to be in the middle of a floor, not at the edge")
                        bool = false
                    }
                }
            }
        }
        return bool
    }
    
    
    // MARK: Game Functions
    
    func roomForName(name: String) -> Room? {
        var room = self.noRoom
        if let index = self.rooms.indexOf({$0.name == name}) {
            room = self.rooms[index]
        }
        return room
    }
    
    func eventForName(name: String) -> Event? {
        var event = Event?()
        if let index = self.events.indexOf({$0.name == name}) {
            event = self.events[index]
        }
        return event
    }
    
    
    // Get a room in the house for a set of x and y coordinates.
    func roomForPosition(position:(x: Int, y: Int, z: Int)) -> Room? {
        var room = self.noRoom
        if ( position.z >= 0 && position.z < self.layout.count) {
            let floor = self.layout[position.z]
            if ( position.y >= 0 && position.y < floor.count ) {
                let row = floor[position.y]
                if ( position.x >= 0 && position.x < row.count ) {
                    room = self.map[position.z][position.y][position.x]
                }
            }
        }
        
        return room
    }
    
    // Get the x, y position for a room in the house based on its name.
    func positionForRoom(room: Room) -> (x: Int, y: Int, z:Int)? {
        var position = (x: 0, y: 0, z:0)
        for r: Room in self.rooms {
            if r.name == room.name {
                position = r.position
            }
        }
        return position
    }
    
    // Checks if room exists at position
    // Used to maintain the bounds of the house, so the player does not end up in a wall or outside.
    func doesRoomExistAtPosition(position:(x: Int, y: Int, z:Int)) -> Bool {
        let room = roomForPosition(position)
        if ( room!.name == "No Room" || position.y < 0 || position.x < 0 || position.x >= self.width || position.y >= self.height ) {
            return false
        } else {
            return true
        }
    }
    
    // Get get a room in a direction adjacent to the player
    // Used to find out what the room is before entering it.
    func roomInDirection(direction:Direction) -> Room? {
        var potentialPosition = (x: self.player.position.x, y: self.player.position.y, z: self.player.position.z)
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
            potentialPosition = self.player.position
        }
        let potentialRoom = roomForPosition(potentialPosition)
        
        return potentialRoom
    }
    
    // Find out what direction a room is in, based on the player's position.
    // Currently used to output directions the player can move in,
    // which in turns is vital for actually moving the player in that direction.
    func directionForRoom(room:Room) -> Direction {
        var d = Direction.North
        if room.position.x < self.player.position.x {
            d = Direction.West
        } else if room.position.x > self.player.position.x {
            d = Direction.East
        } else if room.position.y < self.player.position.y {
            d = Direction.South
        } else if room.position.y > self.player.position.y {
            d = Direction.North
        }
        return d
    }
    
    // Checks for rooms around house.playerPosition
    // Needed to output the number of directions the player can actually move in,
    // which is necessary for navigation and the tableview display itself.
    func getRoomsAroundCharacter(character: Character) -> [Room] {
        var roomsAroundCharacter = [Room]()
        let roomPositionToNorth = (character.position.x, character.position.y+1, character.position.z)
        let roomPositionToWest = (character.position.x-1, character.position.y, character.position.z)
        let roomPositionToSouth = (character.position.x, character.position.y-1, character.position.z)
        let roomPositionToEast = (character.position.x+1, character.position.y, character.position.z)
        
        if ( doesRoomExistAtPosition(roomPositionToNorth) ) {
            roomsAroundCharacter.append(roomForPosition(roomPositionToNorth)!)
        }
        if ( doesRoomExistAtPosition(roomPositionToWest) ) {
            roomsAroundCharacter.append(roomForPosition(roomPositionToWest)!)
        }
        if ( doesRoomExistAtPosition(roomPositionToSouth) ) {
            roomsAroundCharacter.append(roomForPosition(roomPositionToSouth)!)
        }
        if ( doesRoomExistAtPosition(roomPositionToEast) ) {
            roomsAroundCharacter.append(roomForPosition(roomPositionToEast)!)
        }
        
        return roomsAroundCharacter
    }
    
    func characterForName(name: String) -> Character? {
        var character = Character?()
        if let index = self.npcs.indexOf({$0.name == name}) {
            character = self.npcs[index]
        }
        return character
    }
    
    func canCharacterGoUpstairs(character: Character) -> Bool {
        var bool = false
        let upstairsPosition = (character.position.x, character.position.y, character.position.z+1)
        if let upstairsRoom = roomForPosition(upstairsPosition) {
            if upstairsRoom.name == self.stairsDownToFirst.name || upstairsRoom.name == self.stairsDownToBasement.name {
                print("HOUSE – \(character.name) is in a room that allows them to go upstairs")
                bool = true
            }
        }
        
        return bool
    }
    
    
    func canCharacterGoDownstairs(character: Character) -> Bool {
        print("HOUSE – in canCharacterGoDownstairs")
        var bool = false
        let downstairsPosition = (character.position.x, character.position.y, character.position.z-1)
        print("HOUSE – downstairsPosition is \(downstairsPosition)")
        if let downstairsRoom = roomForPosition(downstairsPosition) {
            print("HOUSE – downstairsRoom is \(downstairsRoom.name)")
            if downstairsRoom.name == self.stairsUpToFirst.name || downstairsRoom.name == self.stairsUpToSecond.name {
                print("HOUSE – \(character.name) is in a room that allows them to go downstairs")
                bool = true
            }
        }
        return bool
    }
    
    func moveCharacter(withName name:String, toRoom room:Room) {
        print("HOUSE – in moveCharacter")
        
        if name == "player" {
            room.timesEntered += 1
            self.player.position = room.position
            print("HOUSE – player is now at position \(room.position)")
            self.player.addRoomNameToRoomHistory(room.name)
        } else {
            if let npc = self.characterForName(name) {
                if let index = room.characters.indexOf({$0.name == npc.name}) {
                    room.characters.removeAtIndex(index)
                }
                room.characters += [npc]
                npc.position = room.position
            }
        }
    }
    
    func getViableSuddenEventName() -> String? {
        var string = ""
        for event in self.events {
            if event.sudden {
                if event.isFollowingTheRules() {
                    string = event.name
                    break
                }
            }
        }
        return string
    }
    
    func triggerNPCBehaviors() {
        print("HOUSE – in triggerNPCBehaviors")
        for npc in self.npcs {
            print("HOUSE – \(npc.name)")
            for behavior in npc.behaviors {
                if behavior.isFollowingTheRules() {
                    switch behavior.type {
                        
                    // Wander from room too room randomly
                    case .Random:
                        var potentialRooms = getRoomsAroundCharacter(npc)
                        
                        if canCharacterGoUpstairs(npc) {
                            let upstairsPosition = (npc.position.x, npc.position.y, npc.position.z+1)
                            if let upstairsRoom = roomForPosition(upstairsPosition) {
                                potentialRooms += [upstairsRoom]
                            }
                        }
                        if canCharacterGoDownstairs(npc) {
                            let downstairsPosition = (npc.position.x, npc.position.y, npc.position.z-1)
                            if let downstairsRoom = roomForPosition(downstairsPosition) {
                                potentialRooms += [downstairsRoom]
                            }
                        }
                        
                        let index = Int(arc4random_uniform(UInt32(potentialRooms.count)))
                        
                        print("HOUSE – the number of potential rooms for \(npc.name)'s next move is \(potentialRooms.count)")
                        print("HOUSE – the random index is \(index), so \(npc.name) will move to \(potentialRooms[index].name)")
                        
                        print("HOUSE – \(npc.name) was at \(roomForPosition(npc.position)?.name) (\(npc.position))")
                        moveCharacter(withName: npc.name, toRoom: potentialRooms[index])
                        print("HOUSE – \(npc.name) is now at \(roomForPosition(npc.position)?.name) (\(npc.position))")
                    case .PursuePlayer:
                        print("PURSUING PLAYER")
                        let currentPosition = npc.position
                        var targetPosition = self.player.position
                        var potentialPosition = currentPosition
                        
                        
                        if currentPosition.z > targetPosition.z {
                            if currentPosition.z == 2 {
                                targetPosition = self.stairsDownToFirst.position
                            } else if currentPosition.z == 1 {
                                targetPosition = self.stairsDownToBasement.position
                            }
                        } else if currentPosition.z < targetPosition.z {
                            if currentPosition.z == 0 {
                                targetPosition = self.stairsUpToFirst.position
                            } else if currentPosition.z == 1 {
                                targetPosition = self.stairsUpToSecond.position
                            }
                        }
                        
                        if currentPosition.x > targetPosition.x {
                            if self.doesRoomExistAtPosition((x:currentPosition.x-1, y:currentPosition.y, z:currentPosition.z)) {
                                potentialPosition.x -= 1
                            }
                        } else if currentPosition.x < targetPosition.x {
                            if self.doesRoomExistAtPosition((x:currentPosition.x+1, y:currentPosition.y, z:currentPosition.z)) {
                                potentialPosition.x += 1
                            }
                        } else if currentPosition.y > targetPosition.y {
                            if self.doesRoomExistAtPosition((x:currentPosition.x, y:currentPosition.y-1, z:currentPosition.z)) {
                                potentialPosition.y -= 1
                            }
                        } else if currentPosition.y < targetPosition.y {
                            if self.doesRoomExistAtPosition((x:currentPosition.x, y:currentPosition.y+1, z:currentPosition.z)) {
                                potentialPosition.y += 1
                            }
                        } else if potentialPosition == targetPosition {
                            if canCharacterGoUpstairs(npc) {
                                potentialPosition.z += 1
                            }
                            if canCharacterGoDownstairs(npc) {
                                potentialPosition.z -= 1
                            }
                        }
                        
                        moveCharacter(withName: npc.name, toRoom: roomForPosition(potentialPosition)!)
                        
                    default:
                        break
                    }
                    break
                }
            }
        }
    }
    
    
    // MARK: ENCODING
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.gameClock = decoder.decodeObjectForKey("gameClock") as! GameClock
        self.width = decoder.decodeIntegerForKey("width")
        self.height = decoder.decodeIntegerForKey("height")
        self.depth = decoder.decodeIntegerForKey("depth")
        
        self.rooms = decoder.decodeObjectForKey("rooms") as! [Room]
        self.events = decoder.decodeObjectForKey("events") as! [Event]
        self.player = decoder.decodeObjectForKey("player") as! Character
        
        print("HOUSE - loading player.items.count as \(self.player.items.count)")
        
        self.npcs = decoder.decodeObjectForKey("npcs") as! [Character]
        self.layout = decoder.decodeObjectForKey("layout") as! [[[Int]]]
        self.map = decoder.decodeObjectForKey("map") as! [[[Room]]]
        self.currentFloor = decoder.decodeObjectForKey("currentFloor") as! [[Room]]
        //self.currentRoom = decoder.decodeObjectForKey("currentRoom") as! Room
        
        print("HOUSE - loading currentRoom as \(self.currentRoom.name)")
        
        self.currentEvent = decoder.decodeObjectForKey("currentEvent") as! Event
        self.skull = decoder.decodeObjectForKey("skull") as! Skull
        self.noRoom = decoder.decodeObjectForKey("noRoom") as! Room
        self.foyer = decoder.decodeObjectForKey("foyer") as! Room
        self.stairsDownToBasement = decoder.decodeObjectForKey("stairsDownToBasement") as! Room
        self.stairsUpToFirst = decoder.decodeObjectForKey("stairsUpToFirst") as! Room
        self.stairsUpToSecond = decoder.decodeObjectForKey("stairsUpToSecond") as! Room
        self.stairsDownToFirst = decoder.decodeObjectForKey("stairsDownToFirst") as! Room
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.gameClock, forKey: "gameClock")
        coder.encodeInteger(self.width, forKey: "width")
        coder.encodeInteger(self.height, forKey: "height")
        coder.encodeInteger(self.depth, forKey: "depth")
        
        coder.encodeObject(self.rooms, forKey: "rooms")
        coder.encodeObject(self.events, forKey: "events")
        
        coder.encodeObject(self.player, forKey: "player")
        
        print("HOUSE - saving player.items.count as \(self.player.items.count)")
        
        coder.encodeObject(self.npcs, forKey: "npcs")
        
        coder.encodeObject(self.layout, forKey: "layout")
        coder.encodeObject(self.map, forKey: "map")
        
        coder.encodeObject(self.currentFloor, forKey: "currentFloor")
        coder.encodeObject(self.currentRoom, forKey: "currentRoom")
        
        print("HOUSE - saving currentRoom as \(self.currentRoom.name)")
        
        coder.encodeObject(self.currentEvent, forKey: "currentEvent")
        
        coder.encodeObject(self.noRoom, forKey: "noRoom")
        coder.encodeObject(self.foyer, forKey: "foyer")
        coder.encodeObject(self.stairsDownToBasement, forKey: "stairsDownToBasement")
        coder.encodeObject(self.stairsUpToFirst, forKey: "stairsUpToFirst")
        coder.encodeObject(self.stairsUpToSecond, forKey: "stairsUpToSecond")
        coder.encodeObject(self.stairsDownToFirst, forKey: "stairsDownToFirst")
        
        coder.encodeObject(self.skull, forKey: "skull")

    }
    
    init(
        gameClock : GameClock,
        width : Int,
        height : Int,
        depth : Int,
        rooms : [Room],
        events : [Event],
        player : Character,
        npcs : [Character],
        layout : [[[Int]]],
        map : [[[Room]]],
        currentFloor : [[Room]],
        currentEvent : Event,
        skull : Skull,
        noRoom : Room,
        foyer : Room,
        stairsDownToBasement : Room,
        stairsUpToFirst : Room,
        stairsUpToSecond : Room,
        stairsDownToFirst : Room
    ) {
        self.gameClock = gameClock
        self.width = width
        self.height = height
        self.depth = depth
        self.rooms = rooms
        self.events = events
        self.player = player
        self.npcs = npcs
        self.layout = layout
        self.map = map
        self.currentFloor = currentFloor
        //self.currentRoom = currentRoom
        self.currentEvent = currentEvent
        self.skull = skull
        self.noRoom = noRoom
        self.foyer = foyer
        self.stairsDownToBasement = stairsDownToBasement
        self.stairsUpToFirst = stairsUpToFirst
        self.stairsUpToSecond = stairsUpToSecond
        self.stairsDownToFirst = stairsDownToFirst
    }
    
}