
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
                "No Room", // 1. This would correspond to the "normal" room state, so it shouldn't come up.
                "Foyer", // 2
                "Basement Stairs", // 3
                "Basement Landing", // 4
                "Stairs Ascending", // 5
                "2nd Floor Landing" // 6
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
        static let b = [
            [[1, 2],
            [1, 1]]
        ]
        // This gives us three floors!
        // Each array needs the same number of rows and columns
        static let a = [
            [[6, 1, 0, 0],
            [1, 1, 0, 0,],
            [0, 0, 0, 0,]], // second floor = 2
            
            [[5, 1, 1, 3],
            [0, 1, 1, 0],
            [0, 0, 2, 0]], // first floor = 1
            
            [[0, 0, 1, 4],
            [0, 0, 1, 1],
            [0, 0, 0, 0]]  // basement = 0
        ]
    }
    
    
    enum Direction: String {
        case North, South, West, East, Upstairs, Downstairs, Default
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
    
    
    // MARK: Room Templates
    
    var necessaryRooms : [String : Room] = [:]
    
    // The room that is being presented for exploration.
    // This will be set by the game controllers.
    var currentRoom = Room()
    
    // The event that is being presented for interaction.
    // This will be set by the game contserollers.
    var currentEvent = Event()
    
    // The skull will be watching to update its ideas
    var skull = Skull()
    
    // This remember which container is the player's
    // designated safe box.
    var safeBox = Item()
    
    
    // The pipeline will store the potential actions for every character
    // in the house. Then they'll be executed all at once, in order.
    var pipeline : [(Action, Action.ActionType, Character, Room, Stage?, Action.ResolutionType)] = []
    // Incidentally, this property is never TOUCHED by NSCoding.
    // There is no reason to save or load this, as it's only needed
    // while the game is active.
    
    override init(){
        
    }
    
    init(layout: [[[Int]]]) {
        super.init()
        
        self.layout = self.reverseLayout(layout: layout)
        (self.width, self.height, self.depth) = getDimensionsFromLayout(layout: layout)
        
        self.events = getEventsFromPlist(withFilename: "Events")
        
        if let _ = UserDefaults.standard.data(forKey: "roomsData") {
            self.loadNecessaryRoomsDataFromDefaults()
            self.loadMapDataFromDefaults()
            self.loadRoomsDataFromDefaults()
            self.loadNPCDataFromDefaults()
        } else {
            self.necessaryRooms = getNecessaryRoomsDictFromPlistName(filename: "NecessaryRooms")
            self.rooms = getRoomsFromPlist(withFilename: "Rooms")
            self.drawMap()
        }
        
        
        self.skull = Skull(withDictionary: dictForPlistFilename(filename: "Skull"))
        
        
        // Player starts in foyer on initilization
        if let foyer = self.necessaryRooms["Foyer"] {
            print("putting player in foyer")
            self.player.position = foyer.position
            self.player.addRoomNameToRoomHistory(roomName: foyer.name)
            self.setCurrentRoomToPlayerRoom()
        }
        
        self.setSafeBox()
        
    }
    
    // MARK: Setup Functions
    
    func reverseLayout(layout: [[[Int]]]) -> [[[Int]]] {
        let layoutReversed = layout.reversed()
        
        // Reverse each floor's layout so that north and south make sense
        var i = 0
        var l = Array(layoutReversed)
        for _ in l {
            l[i] = l[i].reversed()
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
        for (_,value) in self.dictForPlistFilename(filename: filename) {
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            dict[room.name] = room
        }
        return dict
    }
    
    func dictForPlistFilename(filename: String) -> Dictionary<String,AnyObject> {
        let path = Bundle.main.path(forResource: filename, ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
    }
    
    func getRoomsFromPlist(withFilename filename: String) -> [Room] {
        var rooms : [Room] = []
        for (_, value) in self.dictForPlistFilename(filename: "Rooms") {
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            rooms += [room]
        }
        
        
        // *** Comment out this line to make the room layout fixe every time
        rooms.shuffle()
        return rooms
    }
    
    func getEventsFromPlist(withFilename filename: String) -> [Event] {
        var events : [Event] = []
        for (_, value) in self.dictForPlistFilename(filename: "Events") {
            let event = Event(withDictionary: value as! Dictionary<String,AnyObject>)
            events += [event]
        }
        return events
    }
    
    
    
    // Pre-fill the floor with noRooms to make it easier to change the rooms later.
    func prepopulatedFloor(withDimensions: (width: Int, height: Int, depth: Int)) -> [[Room]] {
        print("HOUSE – Prepopulating map...\r")
        var floor = [[Room]]()
            for _ in 0 ..< height {
                var row = [Room]()
                for _ in 0 ..< width {
                    if let noRoom = self.necessaryRooms["No Room"] {
                        row.append(noRoom)
                    }
                } // end of x for loop
                floor.append(row)
            } // end of y for loop
        
        return floor
    }
    
    
    func drawMap() {
        print("HOUSE – Drawing map of house...\r")
        
        let dimensions = (self.width, self.height, self.depth)
        var floor = prepopulatedFloor(withDimensions: dimensions)
        
        var roomIndex = 0
        var mustBreakGuidelineLoop = false
        var room = Room()
        
        for z in 0 ..< depth {
            for y in 0 ..< height {
                for x in 0 ..< width {

                    // Draw the room
                    switch ( self.layout[z][y][x] ) {
                    case RoomType.normal:
                        var i = 0
                        while ( guidelinesAreMet(forRoom: self.rooms[roomIndex], atPosition: (x:x, y:y, z:z)) == false || self.rooms[roomIndex].isInHouse == true ) {
                            if i > self.rooms.count * 3 {
                                mustBreakGuidelineLoop = true
                                //break
                            } else {
                                self.rooms.shiftRightInPlace()
                            }
                            
                            while ( self.rooms[roomIndex].isInHouse == true ) {
                                self.rooms.shiftRightInPlace()
                            }
                            
                            i += 1
                            
                            if mustBreakGuidelineLoop {
                                if self.rooms[roomIndex].isInHouse == false {
                                    break
                                }
                            }
                        }
                        room = self.rooms[roomIndex]
                        roomIndex += 1
                    default:
                        room = self.necessaryRooms[RoomType.roomName(id: self.layout[z][y][x])]!
                        self.necessaryRooms[RoomType.roomName(id: self.layout[z][y][x])]!.position = (x:x, y:y, z:z)
                    }
                    
                    room.position = (x:x, y:y, z:z)
                    room.isInHouse = true //
                    floor[y][x] = room
                    self.addCharactersInRoomToNPCsArray(room: room)
                    print("drawMap - room at \(room.position) is \(room.name)")
                } // end of x for loop
            } // end of y for loop
            self.map += [floor]
            floor = prepopulatedFloor(withDimensions: dimensions)
        } // end of z for loop
        
        self.saveNecessaryRoomsDataToDefaults()
        self.saveRoomsDataToDefaults()
        self.saveNPCDataToDefaults()
        self.saveMapDataToDefaults()
        UserDefaults.standard.synchronize()
        
    }
    
    func loadNecessaryRoomsDataFromDefaults() {
        if let necessaryRoomsData = UserDefaults.standard.data(forKey: "necessaryRoomsData") {
            self.necessaryRooms = NSKeyedUnarchiver.unarchiveObject(with: necessaryRoomsData) as! [String : Room]
        }
    }
    
    func loadRoomsDataFromDefaults() {
        if let roomsData = UserDefaults.standard.data(forKey: "roomsData") {
            self.rooms = NSKeyedUnarchiver.unarchiveObject(with: roomsData) as! [Room]
        }
    }
    
    func loadNPCDataFromDefaults() {
        if let npcData = UserDefaults.standard.data(forKey: "npcData") {
            self.npcs = NSKeyedUnarchiver.unarchiveObject(with: npcData) as! [Character]
        }
    }
    func loadMapDataFromDefaults() {
        if let mapData = UserDefaults.standard.data(forKey: "mapData") {
            self.map = NSKeyedUnarchiver.unarchiveObject(with: mapData) as! [[[Room]]]
        }
    }
    
    func saveNecessaryRoomsDataToDefaults() {
        if let _ = UserDefaults.standard.data(forKey: "necessaryRoomsData") {
        } else {
            let necessaryRoomsData = NSKeyedArchiver.archivedData(withRootObject: self.necessaryRooms)
            UserDefaults.standard.set(necessaryRoomsData, forKey: "necessaryRoomsData")
            
            print("necessary rooms archived")
        }
    }
    
    func saveRoomsDataToDefaults() {
        if let _ = UserDefaults.standard.data(forKey: "roomsData") {
        } else {
            let roomsData = NSKeyedArchiver.archivedData(withRootObject: self.rooms)
            UserDefaults.standard.set(roomsData, forKey: "roomsData")
    
            print("rooms archived")
        }
    }
    
    func saveNPCDataToDefaults() {
        if let _ = UserDefaults.standard.data(forKey: "npcData") {
        } else {
            let npcData = NSKeyedArchiver.archivedData(withRootObject: self.npcs)
            UserDefaults.standard.set(npcData, forKey: "npcData")

            print("npcs archived")
        }
    }
    
    func saveMapDataToDefaults() {
        if let _ = UserDefaults.standard.data(forKey: "mapData") {
        } else {
            let mapData = NSKeyedArchiver.archivedData(withRootObject: self.map)
            UserDefaults.standard.set(mapData, forKey: "mapData")

            print("map archived")
        }
    }
    
    func addCharactersInRoomToNPCsArray(room: Room) {
        for character in room.characters {
            self.npcs += [character]
            character.position = room.position
            print("\(character.name) is in \(room.name)")
        }
    }
    
    
    // This function is the method used to put each of the rooms in the right spot.
    
    func guidelinesAreMet(forRoom room: Room, atPosition position: (x:Int, y:Int, z:Int)) -> Bool {
        var bool = true
        
        if let dict = room.placementGuidelines {
            for (key,value) in dict {
                if ( key.range(of: "floor") != nil ) {
                    let floorNumber = value as! Int
                    
                    if floorNumber != position.z {
                        bool = false
                    }
                }
                if ( key.range(of: "edge") != nil ) {
                    if ( position.x == 0 || position.x == self.width-1 || position.y == 0 || position.y == self.height-1 ) {
                        
                    } else {
                        print("GUIDELINES – \(room.name) needs to be at the edge of a floor, not at the middle")
                        bool = false
                    }
                }
                
                if ( key.range(of: "middle") != nil ) {
                    if ( position.x == 0 || position.x == self.width-1 || position.y == 0 || position.y == self.height-1 ) {
                        print("GUIDELINES – \(room.name) needs to be in the middle of a floor, not at the edge")
                        bool = false
                    }
                }
            }
        }
        return bool
    }
    
    
    // MARK: Game Functions
    
    func roomForName(name: String) -> Room? {
        var room = Room()
        if let index = self.rooms.index(where: {$0.name == name}) {
            room = self.rooms[index]
        } else {
            for key in self.necessaryRooms.keys {
                if key == name {
                    room = self.necessaryRooms[key]!
                }
            }
        }
        return room
    }
    
    func eventForName(name: String) -> Event? {
        var event : Event?
        if let index = self.events.index(where: {$0.name == name}) {
            event = self.events[index]
        }
        return event
    }
    
    
    // Get a room in the house for a set of x and y coordinates.
    func roomForPosition(position:(x: Int, y: Int, z: Int)) -> Room? {
        var room = Room()
        if ( position.z >= 0 && position.z < self.layout.count) {
            let floor = self.layout[position.z]
            if ( position.y >= 0 && position.y < floor.count ) {
                let row = floor[position.y]
                if ( position.x >= 0 && position.x < row.count ) {
                    let roomName = self.map[position.z][position.y][position.x].name
                    room = self.roomForName(name: roomName)!
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
        let room = roomForPosition(position: position)
        if ( room!.name == "No Room" || position.y < 0 || position.x < 0 || position.x >= self.width || position.y >= self.height ) {
            return false
        } else {
            return true
        }
    }
    
    // Get get a room in a direction adjacent to the player
    // Used to find out what the room is before entering it.
    func roomInDirection(direction:Direction, fromPosition: (x: Int, y: Int, z: Int)) -> Room? {
        var potentialPosition = fromPosition
        switch direction {
        case .North:
            potentialPosition.y += 1
        case .South:
            potentialPosition.y -= 1
        case .East:
            potentialPosition.x += 1
        case .West:
            potentialPosition.x -= 1
        case .Upstairs:
            potentialPosition.z += 1
        case .Downstairs:
            potentialPosition.z -= 1
        case .Default:
            break
        }
        
        // This makes sure that the new position is within the layout of the house
        // If it's not, the player's position stays as it is,
        // and the player's current room is returned.
        if ( doesRoomExistAtPosition(position: potentialPosition) == false ) {
            potentialPosition = fromPosition
        }
        
        let character = Character()
        character.position = fromPosition
        if direction == House.Direction.Upstairs {
            if canCharacterGoUpstairs(character: character) == false {
                potentialPosition = fromPosition
            }
        }
        if direction == House.Direction.Downstairs {
            if canCharacterGoDownstairs(character: character) == false {
                potentialPosition = fromPosition
            }
        }
        
        let potentialRoom = roomForPosition(position: potentialPosition)
        
        return potentialRoom
    }
    
    // Find out what direction a room is in, based on the player's position.
    // Currently used to output directions the player can move in,
    // which in turns is vital for actually moving the player in that direction.
    func directionForRoom(roomA:Room, fromRoom roomB: Room) -> Direction {
        var d = Direction.North
        if roomA.position.x < roomB.position.x {
            d = Direction.West
        } else if roomA.position.x > roomB.position.x {
            d = Direction.East
        } else if roomA.position.y < roomB.position.y {
            d = Direction.South
        } else if roomA.position.y > roomB.position.y {
            d = Direction.North
        } else if roomA.position.z > roomB.position.z {
            d = Direction.Upstairs
        } else if roomA.position.z < roomB.position.z {
            d = Direction.Downstairs
        }
        return d
    }
    
    func directionForString(string: String) -> House.Direction {
        if string.lowercased().range(of: "north") != nil {
            return House.Direction.North
        } else if string.lowercased().range(of: "west") != nil {
            return House.Direction.West
        } else if string.lowercased().range(of: "south") != nil {
            return House.Direction.South
        } else if string.lowercased().range(of: "east") != nil {
            return House.Direction.East
        } else if string.lowercased().range(of: "upstairs") != nil {
            return House.Direction.Upstairs
        } else if string.lowercased().range(of: "downstairs") != nil {
            return House.Direction.Downstairs
        } else { return House.Direction.Default }
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
        let roomPositionUpstairs = (character.position.x, character.position.y, character.position.z+1)
        let roomPositionDownstairs = (character.position.x, character.position.y, character.position.z-1)
        
        if ( doesRoomExistAtPosition(position: roomPositionToNorth) ) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionToNorth)!)
        }
        if ( doesRoomExistAtPosition(position: roomPositionToWest) ) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionToWest)!)
        }
        if ( doesRoomExistAtPosition(position: roomPositionToSouth) ) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionToSouth)!)
        }
        if ( doesRoomExistAtPosition(position: roomPositionToEast) ) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionToEast)!)
        }
        if canCharacterGoUpstairs(character: character) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionUpstairs)!)
        }
        if canCharacterGoDownstairs(character: character) {
            roomsAroundCharacter.append(roomForPosition(position: roomPositionDownstairs)!)
        }
        
        return roomsAroundCharacter
    }
    
    func characterForName(name: String) -> Character? {
        var character : Character?
        if let index = self.npcs.index(where: {$0.name == name}) {
            character = self.npcs[index]
        }
        return character
    }
    
    func canCharacterGoUpstairs(character: Character) -> Bool {
        var bool = false
        if let room = roomForPosition(position: character.position) {
            if room.name == self.necessaryRooms[RoomType.roomName(id: RoomType.stairsUpToFirst)]!.name || room.name == self.necessaryRooms[RoomType.roomName(id: RoomType.stairsUpToSecond)]!.name {
                bool = true
            }
        }
        
        return bool
    }
    
    
    func canCharacterGoDownstairs(character: Character) -> Bool {
        var bool = false
        if let room = roomForPosition(position: character.position) {
            if room.name == self.necessaryRooms[RoomType.roomName(id: RoomType.stairsDownToFirst)]!.name || room.name == self.necessaryRooms[RoomType.roomName(id: RoomType.stairsDownToBasement)]!.name {
                bool = true
            }
        }
        return bool
    }
    
    func moveCharacter(withName name:String, toRoom room:Room) {
        print("HOUSE – in moveCharacter")
        
        // MOVE PLAYER
        if name.lowercased().range(of: "player") != nil {
            self.player.position = room.position
            self.player.addRoomNameToRoomHistory(roomName: room.name)
            self.setCurrentRoomToPlayerRoom()
        } else {
            
        // MOVE NPC
            if let npc = self.characterForName(name: name) {
                if let currentRoom = roomForPosition(position: npc.position) {
                    if let index = currentRoom.characters.index(where: {$0.name == npc.name}) {
                        currentRoom.characters.remove(at: index)
                    }
                }
                room.characters += [npc]
                npc.position = room.position
                npc.addRoomNameToRoomHistory(roomName: room.name)
            }
        }
    }
    
    func setCurrentRoomToPlayerRoom() {
        self.currentRoom = self.roomForPosition(position: self.player.position)!
        self.currentRoom.timesEntered += 1
        
        // *** STATS
        if let roomsFound = self.player.stats["roomsFound"] {
            if roomsFound.contains(self.currentRoom.name) {
                
            } else {
                var newArray = roomsFound
                newArray.append(self.currentRoom.name)
                self.player.stats["roomsFound"] = newArray
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
        for npc in self.npcs {
            print("HOUSE – \(npc.name) was at \(roomForPosition(position: npc.position)?.name) (\(npc.position))")
            for behavior in npc.behaviors {
                if behavior.isFollowingTheRules() {
                    switch behavior.type {
                        
                    // Wander from room too room randomly
                    case .Random:
                        self.pipeline += [self.npcBehaviorRandomActionSet(npc: npc)]
                    // Follow player
                    case .PursuePlayer:
                        self.pipeline += [self.npcBehaviorPursuePlayerActionSet(npc: npc)]
                        
                    default:
                        break
                    }
                    print("HOUSE – \(npc.name) is now at \(roomForPosition(position: npc.position)?.name) (\(npc.position))\r")
                    
                    break
                }
            }
        }
    }
    
    func npcBehaviorRandomActionSet(npc: Character) -> (Action, Action.ActionType, Character, Room, Stage?, Action.ResolutionType) {
        var potentialRooms = getRoomsAroundCharacter(character: npc)
        
        if canCharacterGoUpstairs(character: npc) {
            let upstairsPosition = (npc.position.x, npc.position.y, npc.position.z+1)
            if let upstairsRoom = roomForPosition(position: upstairsPosition) {
                potentialRooms += [upstairsRoom]
            }
        }
        if canCharacterGoDownstairs(character: npc) {
            let downstairsPosition = (npc.position.x, npc.position.y, npc.position.z-1)
            if let downstairsRoom = roomForPosition(position: downstairsPosition) {
                potentialRooms += [downstairsRoom]
            }
        }
        
        let index = Int(arc4random_uniform(UInt32(potentialRooms.count)))
        
        let action = Action()
        let room = potentialRooms[index]
        action.moveCharacter = (npc.name, room.name, nil)
        
        return (action, Action.ActionType.Room, npc, room, self.currentEvent.currentStage, Action.ResolutionType.Exploration)
    }
    
    /*
    func npcBehaviorPursuePlayerActionSetOLD(npc: Character) -> (Action, Action.ActionType, Character, Room, Stage?, Action.ResolutionType) {
        
        // Keep in mind where the character currently is
        let currentPosition = npc.position
        // Find where the player is, for comparison
        var targetPosition = self.player.position
        // The position to which the character will move
        // when calculations are complete.
        var potentialPosition = currentPosition
        
        // First, in case the player is on another floor,
        // set the targetPosition to the staircase that
        // can access that floor.
        if currentPosition.z > targetPosition.z {
            if currentPosition.z == 2 {
                targetPosition = self.necessaryRooms[RoomType.roomName(RoomType.stairsDownToFirst)]!.position
            } else if currentPosition.z == 1 {
                targetPosition = self.necessaryRooms[RoomType.roomName(RoomType.stairsDownToBasement)]!.position
            }
        } else if currentPosition.z < targetPosition.z {
            if currentPosition.z == 0 {
                targetPosition = self.necessaryRooms[RoomType.roomName(RoomType.stairsUpToFirst)]!.position
            } else if currentPosition.z == 1 {
                targetPosition = self.necessaryRooms[RoomType.roomName(RoomType.stairsUpToSecond)]!.position
            }
        }
        
        // Now that we have a target: 
        // Here we set up default values for the new postion
        var x = 0
        var y = 0
        var z = 0
        var lookingForNewPosition = true
        
        if currentPosition.x > targetPosition.x && lookingForNewPosition {
            if self.doesRoomExistAtPosition((x:currentPosition.x-1, y:currentPosition.y, z:currentPosition.z)) {
                potentialPosition.x -= 1
                x -= 1
                lookingForNewPosition = false
            }
        }
        if currentPosition.x < targetPosition.x && lookingForNewPosition {
            if self.doesRoomExistAtPosition((x:currentPosition.x+1, y:currentPosition.y, z:currentPosition.z)) {
                potentialPosition.x += 1
                x += 1
                lookingForNewPosition = false
            }
        }
        if currentPosition.y > targetPosition.y && lookingForNewPosition {
            if self.doesRoomExistAtPosition((x:currentPosition.x, y:currentPosition.y-1, z:currentPosition.z)) {
                potentialPosition.y -= 1
                y -= 1
                lookingForNewPosition = false
            }
        }
        if currentPosition.y < targetPosition.y && lookingForNewPosition {
            if self.doesRoomExistAtPosition((x:currentPosition.x, y:currentPosition.y+1, z:currentPosition.z)) {
                potentialPosition.y += 1
                y += 1
                lookingForNewPosition = false
            }
        }
        if potentialPosition == targetPosition && lookingForNewPosition {
            if canCharacterGoUpstairs(npc) {
                potentialPosition.z += 1
                z += 1
            }
            if canCharacterGoDownstairs(npc) {
                potentialPosition.z -= 1
                z -= 1
            }
        }
        
        let room = roomForPosition((x, y, z))
        let action = Action()
        action.moveCharacter = (npc.name, room!.name, nil)
        
        return (action, Action.ActionType.Room, npc, self.currentRoom, self.currentEvent.currentStage, Action.ResolutionType.Exploration)
        
    }
    */
    
    func npcBehaviorPursuePlayerActionSet(npc: Character) -> (Action, Action.ActionType, Character, Room, Stage?, Action.ResolutionType) {
        
        // Keep in mind where the character currently is
        let currentPosition = npc.position
        // Find where the player is, for comparison
        var targetPosition = self.player.position
        // The position to which the character will move
        // when calculations are complete.
        
        // First, in case the player is on another floor,
        // set the targetPosition to the staircase that
        // can access that floor.
        if currentPosition.z > targetPosition.z {
            if currentPosition.z == 2 {
                targetPosition = self.necessaryRooms[RoomType.roomName(id: RoomType.stairsDownToFirst)]!.position
            } else if currentPosition.z == 1 {
                targetPosition = self.necessaryRooms[RoomType.roomName(id: RoomType.stairsDownToBasement)]!.position
            }
        } else if currentPosition.z < targetPosition.z {
            if currentPosition.z == 0 {
                targetPosition = self.necessaryRooms[RoomType.roomName(id: RoomType.stairsUpToFirst)]!.position
            } else if currentPosition.z == 1 {
                targetPosition = self.necessaryRooms[RoomType.roomName(id: RoomType.stairsUpToSecond)]!.position
            }
        }
        
        
        let roomsAroundNPC = getRoomsAroundCharacter(character: npc)
        var potentialRooms : [Room] = []
        for room in roomsAroundNPC {
            print("room.name is \(room.name)")
            if currentPosition.x > targetPosition.x {
                if room.position.x < currentPosition.x {
                    potentialRooms += [room]
                }
            }
            if currentPosition.x < targetPosition.x {
                if room.position.x > currentPosition.x {
                    potentialRooms += [room]
                }
            }
            if currentPosition.y > targetPosition.y {
                if room.position.y < currentPosition.y {
                    potentialRooms += [room]
                }
            }
            if currentPosition.y < targetPosition.y {
                if room.position.y > currentPosition.y {
                    potentialRooms += [room]
                }
            }
            
        }
        
        if currentPosition == targetPosition {
            if canCharacterGoUpstairs(character: npc) {
                potentialRooms += [roomInDirection(direction: House.Direction.Upstairs, fromPosition: npc.position)!]
            }
            if canCharacterGoDownstairs(character: npc) {
                potentialRooms += [roomInDirection(direction: House.Direction.Downstairs, fromPosition: npc.position)!]
            }
        }
        
        
        var room = Room()
        if potentialRooms.count > 0 {
            let index = Int(arc4random_uniform(UInt32(potentialRooms.count)))
            room = potentialRooms[index]
        } else { room = roomForPosition(position: npc.position)!}
        
        
        let action = Action()
        action.moveCharacter = (npc.name, room.name, nil)
        
        return (action, Action.ActionType.Room, npc, self.currentRoom, self.currentEvent.currentStage, Action.ResolutionType.Exploration)
        
    }
    
    
    
    
    
    
    
    // MARK: ACTION RESOLUTION
    
    
    
    func resolveActionsInPipeline() {
        for actionSet in self.pipeline {
            // Actions currently executed in the order they are calculated
            // As the player's move is inserted at the start of the queue,
            
            if shouldActionSetBeExecuted(actionSet: actionSet) {
                print("pipeline: character is \(actionSet.2.name)")
                executeAction(action: actionSet.0, ofActionType: actionSet.1, forCharacter: actionSet.2, inRoom: actionSet.3, orInStage: actionSet.4, withResolutionType: actionSet.5)
            }
            
        }
        self.pipeline = []
    }
    
    
    // This function was created so that an NPC looking for the player
    // would not move PAST the player if they entered the same space.
    // Other conflicts that need to be resolved like this should certainly
    // come up - this is where the boilerplate code will go to deal with it.
    func shouldActionSetBeExecuted(actionSet: (Action, Action.ActionType, Character, Room, Stage?, Action.ResolutionType)) -> Bool {
        var bool = true
        
        // NPC related caveats
        if actionSet.2.name.lowercased() != "player" {
            for behavior in actionSet.2.behaviors {
                if behavior.isFollowingTheRules() {
                    switch behavior.type {
                    case .PursuePlayer:
                        if actionSet.2.position == self.player.position {
                            bool = false
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        return bool
    }
    
        
    
    // This is the function is the game's hub.
    // Any changes in the House come through here.
    //
    func executeAction(action: Action, ofActionType actionType: Action.ActionType, forCharacter character: Character, inRoom room: Room?, orInStage stage: Stage?, withResolutionType resolutionType: Action.ResolutionType) {
        
        switch resolutionType {
        case .Exploration:
            room!.revealItemsWithNames(itemNames: action.revealItems)
            room!.liberateItemsWithNames(itemNames: action.liberateItems)
            switch actionType {
            case .Item:
                self.resolveItemTypeAction(action: action, forCharacter: character, inRoomOrStage: room!)
            case .Room:
                room!.resolveChangesToActionsForAction(action: action)
            case .Inventory:
                character.resolveChangesToItemsForAction(action: action)
            }
            self.handleContextSensitiveActions(action: action, ofActionType: actionType, forCharacter: character, inRoomOrStage: room!)
            
        case .Event:
            stage!.revealItemsWithNames(itemNames: action.revealItems)
            stage!.liberateItemsWithNames(itemNames: action.liberateItems)
            switch actionType {
            case .Item:
                self.resolveItemTypeAction(action: action, forCharacter: character, inRoomOrStage: stage!)
            case .Room:
                stage!.resolveChangesToActionsForAction(action: action)
            case .Inventory:
                character.resolveChangesToItemsForAction(action: action)
            }
            self.handleContextSensitiveActions(action: action, ofActionType: actionType, forCharacter: character, inRoomOrStage: stage!)
        default:
            break
        }
        
        
        character.addItemsToInventory(items: action.addItems)
        
        // REMOVE AND DESTROY ITEMS IN PLAYER INVENTORY
        character.consumeItemsWithNames(itemNames: action.consumeItems)
        
        // MAKE A CHARACTER APPEAR
        self.spawnCharacters(characters: action.spawnCharacters)
        
        // MAKE AN INVISIBLE CHARACTER VISIBLE
        self.revealCharactersWithNames(characterNames: action.revealCharacters)
        
        // REMOVE A CHARACTER FROM PLAY
        self.removeCharactersWithNames(characterNames: action.removeCharacters)
        
        // MOVE CHARACTER TO A NEW ROOM
        self.moveCharacter(character: character, withAction: action)

    }
    
    
    
    
    func moveCharacter(character: Character, withAction action: Action) {
        if let moveCharacter = action.moveCharacter {
            
            
            // Moved based on direction
            if let directionName = moveCharacter.directionName {
                self.moveCharacter(withName: moveCharacter.characterName, toRoom: roomInDirection(direction: self.directionForString(string: directionName), fromPosition: character.position)!)
            } else {
            // Move based on room name
                self.moveCharacter(withName: moveCharacter.characterName, toRoom: roomForName(name: moveCharacter.roomName!)!)
            }
            
            
        }
    }
    
    
    
    
    func spawnCharacters(characters: [Character]) {
        // MAKE A CHARACTER APPEAR
        for character in characters {
            if let roomName = character.startingRoom { // Spawn character in room specified
                if let room = self.roomForName(name: roomName) {
                    room.characters += [character]
                    character.position = room.position
                }
            } else { // Spawn character in currentRoom
                print("ExC – spawning \(character.name) in current room")
                self.currentRoom.characters += [character]
                character.position = self.currentRoom.position
            }
            self.npcs += [character]
            print("ExC – \(character.name) IS IN THE HOUSE!")
        }
    }
    
    func revealCharactersWithNames(characterNames: [String]) {
        // MAKE AN INVISIBLE CHARACTER VISIBLE
        for characterName in characterNames {
            if let index = self.npcs.index(where: {$0.name == characterName}) {
                self.npcs[index].hidden = false
                print("ExC – \(self.npcs[index].name) IS REVEALED!")
            }
        }
    }
    
    func removeCharactersWithNames(characterNames: [String]) {
        // REMOVE A CHARACTER FROM PLAY
        for characterName in characterNames {
            print("ExC – characterName is \(characterName)")
            var character : Character?
            
            if let index = self.npcs.index(where: {$0.name == characterName}) {
                print("ExC – \(characterName) is at self.house.npcs[\(index)]")
                character = self.npcs[index]
                print("ExC – self.house.npcs.count was \(self.npcs.count)")
                self.npcs.remove(at: index)
                print("ExC – self.house.npcs.count is now \(self.npcs.count)")
                if let room = self.roomForPosition(position: (character?.position)!) {
                    if let i = room.characters.index(where: {$0.name == characterName}) {
                        room.characters.remove(at: i)
                    }
                }
            }
            
            if let index = self.currentRoom.characters.index(where: {$0.name == characterName}) {
                self.currentRoom.characters.remove(at: index)
            }
            
        }
    }
    
    func resolveItemTypeAction(action: Action, forCharacter character: Character, inRoomOrStage roomOrStage: ItemBased) {
        for i in 0 ..< roomOrStage.items.count {
            if let index = roomOrStage.items[i].actions.index(where: {$0.name == action.name}) {
                
                roomOrStage.items[i].actions[index].timesPerformed += 1
                
                // If the action has a REPLACE action
                if let replaceAction = action.replaceAction {
                    roomOrStage.items[i].actions[index] = replaceAction
                }
                
                // If the action can only be performed ONCE
                if action.onceOnly == true {
                    roomOrStage.items[i].actions.remove(at: index)
                }
                
                // If the action is a TAKE action
                if action.name.range(of: "Take") != nil {
                    character.items += [roomOrStage.items[i]]
                    
                    // *** STATS
                    if character.name == "player" {
                        if let itemsFound = self.player.stats["itemsFound"] {
                            if itemsFound.contains(roomOrStage.items[i].name) {
                                
                            } else {
                                var newArray = itemsFound
                                newArray.append(roomOrStage.items[i].name)
                                self.player.stats["itemsFound"] = newArray
                            }
                        }
                    }
                    
                    roomOrStage.items.remove(at: i)
                    
                }
                break // THIS keeps the loop from crashing as it examines an item that does not exist.
                // It also makes sure multiple similar actions aren't renamed.
                // this seems like a clumsy solution, but it currently works.
            }
        }
    }

    
    
    func handleContextSensitiveActions(action: Action, ofActionType actionType: Action.ActionType, forCharacter character: Character, inRoomOrStage roomOrStage: ItemBased) {
        switch actionType {
        case .Item:
            for i in 0 ..< roomOrStage.items.count {
                for o in 0 ..< roomOrStage.items[i].actions.count {
                    if roomOrStage.items[i].actions[o].name == action.name {
                        
                        let item = roomOrStage.items[i]
                        
                        
                        // OVEN ACTIONS
                        
                        if let oven = item as? Oven {
                            
                            print("ExC – Shit! an oven!")
                            if action.name.lowercased().range(of: "on") != nil {
                                oven.turnOn(atTime: self.gameClock.currentTime)
                            }
                            if action.name.lowercased().range(of: "off") != nil {
                                oven.turnOff()
                            }
                            if action.name.lowercased().range(of: "look") != nil {
                                oven.checkOven(atTime: self.gameClock.currentTime)
                            }
                        }
                    }
                }
            }
        default:
            break
        }
        
    }
    
    
    func setSafeBox() {
        if let boxData = UserDefaults.standard.data(forKey:"boxData") {
            if let box = NSKeyedUnarchiver.unarchiveObject(with: boxData) as? Item {
                self.safeBox = box
            }
        } else {
            if let index = self.necessaryRooms["Foyer"]!.items.index(where: {$0.name == "Box"}) {
                self.safeBox = self.necessaryRooms["Foyer"]!.items[index]
            }
        }
    }
    
    
    // MARK: ENCODING
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.gameClock = decoder.decodeObject(forKey: "gameClock") as! GameClock
        self.width = decoder.decodeInteger(forKey: "width")
        self.height = decoder.decodeInteger(forKey: "height")
        self.depth = decoder.decodeInteger(forKey: "depth")
        
        
        self.necessaryRooms = decoder.decodeObject(forKey: "necessaryRooms") as! [String : Room]
        self.rooms = decoder.decodeObject(forKey: "rooms") as! [Room]
        self.events = decoder.decodeObject(forKey: "events") as! [Event]
        self.player = decoder.decodeObject(forKey: "player") as! Character
        
        self.npcs = decoder.decodeObject(forKey: "npcs") as! [Character]
        self.layout = decoder.decodeObject(forKey: "layout") as! [[[Int]]]
        self.map = decoder.decodeObject(forKey: "map") as! [[[Room]]]
        self.currentRoom = decoder.decodeObject(forKey: "currentRoom") as! Room
        
        self.currentEvent = decoder.decodeObject(forKey: "currentEvent") as! Event
        self.skull = decoder.decodeObject(forKey: "skull") as! Skull
        self.safeBox = decoder.decodeObject(forKey: "safeBox") as! Item
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.gameClock, forKey: "gameClock")
        coder.encode(self.width, forKey: "width")
        coder.encode(self.height, forKey: "height")
        coder.encode(self.depth, forKey: "depth")
        
        coder.encode(self.necessaryRooms, forKey: "necessaryRooms")
        coder.encode(self.rooms, forKey: "rooms")
        coder.encode(self.events, forKey: "events")
        
        coder.encode(self.player, forKey: "player")
    
        coder.encode(self.npcs, forKey: "npcs")
        
        coder.encode(self.layout, forKey: "layout")
        coder.encode(self.map, forKey: "map")
        
        coder.encode(self.currentRoom, forKey: "currentRoom")
        
        coder.encode(self.currentEvent, forKey: "currentEvent")

        
        coder.encode(self.skull, forKey: "skull")
        coder.encode(self.safeBox, forKey: "safeBox")

    }
    
    init(
        gameClock : GameClock,
        width : Int,
        height : Int,
        depth : Int,
        necessaryRooms : [String : Room],
        rooms : [Room],
        events : [Event],
        player : Character,
        npcs : [Character],
        layout : [[[Int]]],
        map : [[[Room]]],
        currentRoom : Room,
        currentEvent : Event,
        skull : Skull,
        safeBox : Item,
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
        self.necessaryRooms = necessaryRooms
        self.rooms = rooms
        self.events = events
        self.player = player
        self.npcs = npcs
        self.layout = layout
        self.map = map
        self.currentRoom = currentRoom
        self.currentEvent = currentEvent
        self.skull = skull
        self.safeBox = safeBox
    }
    
    
    
}
