
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
    
    override init(){
        
    }
    
    init(layout: [[[Int]]]) {
        super.init()
        
        self.layout = self.reverseLayout(layout)
        (self.width, self.height, self.depth) = getDimensionsFromLayout(layout)
        self.necessaryRooms = getNecessaryRoomsDictFromPlistName("NecessaryRooms")
        self.events = getEventsFromPlist(withFilename: "Events")
        self.rooms = getRoomsFromPlist(withFilename: "Rooms")
        self.drawMap()
        
        // Player starts in foyer on initilization
        if let foyer = self.necessaryRooms["Foyer"] {
            foyer.timesEntered += 1
            self.currentRoom = foyer
            self.player.position = self.currentRoom.position
            self.player.addRoomNameToRoomHistory(self.currentRoom.name)
        }
        
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
        return dict
    }
    
    func dictForPlistFilename(filename: String) -> Dictionary<String,AnyObject> {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! Dictionary<String,AnyObject>
    }
    
    func getRoomsFromPlist(withFilename filename: String) -> [Room] {
        var rooms : [Room] = []
        for (_, value) in self.dictForPlistFilename("Rooms") {
            let room = Room(withDictionary: value as! Dictionary<String,AnyObject>)
            rooms += [room]
        }
        
        rooms.shuffleInPlace()
        return rooms
    }
    
    func getEventsFromPlist(withFilename filename: String) -> [Event] {
        var events : [Event] = []
        for (_, value) in self.dictForPlistFilename("Events") {
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
        var floor = prepopulatedFloor(dimensions)
        
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
                        room = self.necessaryRooms[RoomType.roomName(self.layout[z][y][x])]!
                        self.necessaryRooms[RoomType.roomName(self.layout[z][y][x])]!.position = (x:x, y:y, z:z)
                    }
                    
                    room.position = (x:x, y:y, z:z)
                    room.isInHouse = true //
                    floor[y][x] = room
                    self.addCharactersInRoomToNPCsArray(room)
                    print("drawMap - room at \(room.position) is \(room.name)")
                } // end of x for loop
            } // end of y for loop
            self.map += [floor]
            floor = prepopulatedFloor(dimensions)
        } // end of z for loop
        
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
                if ( key.rangeOfString("floor") != nil ) {
                    let floorNumber = value as! Int
                    
                    if floorNumber != position.z {
                        bool = false
                    }
                }
                if ( key.rangeOfString("edge") != nil ) {
                    if ( position.x == 0 || position.x == self.width-1 || position.y == 0 || position.y == self.height-1 ) {
                        
                    } else {
                        bool = false
                    }
                }
                
                if ( key.rangeOfString("middle") != nil ) {
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
        var room = Room()
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
        var room = Room()
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
        if let room = roomForPosition(character.position) {
            if room.name == self.necessaryRooms[RoomType.roomName(RoomType.stairsUpToFirst)]!.name || room.name == self.necessaryRooms[RoomType.roomName(RoomType.stairsUpToSecond)]!.name {
                bool = true
            }
        }
        
        return bool
    }
    
    
    func canCharacterGoDownstairs(character: Character) -> Bool {
        var bool = false
        if let room = roomForPosition(character.position) {
            if room.name == self.necessaryRooms[RoomType.roomName(RoomType.stairsDownToFirst)]!.name || room.name == self.necessaryRooms[RoomType.roomName(RoomType.stairsDownToBasement)]!.name {
                bool = true
            }
        }
        return bool
    }
    
    func moveCharacter(withName name:String, toRoom room:Room) {
        print("HOUSE – in moveCharacter")
        
        // MOVE PLAYER
        if name.lowercaseString.rangeOfString("player") != nil {
            self.player.position = room.position
            self.player.addRoomNameToRoomHistory(room.name)
            self.setCurrentRoomToPlayerRoom()
        } else {
            
        // MOVE NPC
            if let npc = self.characterForName(name) {
                if let currentRoom = roomForPosition(npc.position) {
                    if let index = currentRoom.characters.indexOf({$0.name == npc.name}) {
                        currentRoom.characters.removeAtIndex(index)
                    }
                }
                room.characters += [npc]
                npc.position = room.position
                npc.addRoomNameToRoomHistory(room.name)
            }
        }
    }
    
    func setCurrentRoomToPlayerRoom() {
        self.currentRoom = self.roomForPosition(self.player.position)!
        self.currentRoom.timesEntered += 1
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
            print("HOUSE – \(npc.name) was at \(roomForPosition(npc.position)?.name) (\(npc.position))")
            for behavior in npc.behaviors {
                if behavior.isFollowingTheRules() {
                    switch behavior.type {
                        
                    // Wander from room too room randomly
                    case .Random:
                        self.npcBehaviorRandom(npc)

                    case .PursuePlayer:
                        self.npcBehaviorPursuePlayer(npc)
                        
                    default:
                        break
                    }
                    print("HOUSE – \(npc.name) is now at \(roomForPosition(npc.position)?.name) (\(npc.position))\r")
                    
                    break
                }
            }
        }
    }
    
    func npcBehaviorRandom(npc: Character) {
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
        
        moveCharacter(withName: npc.name, toRoom: potentialRooms[index])
    }
    
    func npcBehaviorPursuePlayer(npc: Character) {
        let currentPosition = npc.position
        var targetPosition = self.player.position
        var potentialPosition = currentPosition
        
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
    }
    
    
    
    
    
    
    // MARK: ACTION RESOLUTION
    
    
    
        
    
    
    func resolveAction(action: Action, ofActionType actionType: Action.ActionType, forCharacter character: Character, inRoom room: Room?, orInStage stage: Stage?, withResolutionType resolutionType: Action.ResolutionType) {
        print("ExC – in resolveAction")
        
        switch resolutionType {
        case .Exploration:
            room!.revealItemsWithNames(action.revealItems)
            room!.liberateItemsWithNames(action.liberateItems)
            switch actionType {
            case .Item:
                self.resolveItemTypeAction(action, forCharacter: character, inRoomOrStage: room!)
            case .Room:
                room!.resolveChangesToActionsForAction(action)
            case .Inventory:
                character.resolveChangesToItemsForAction(action)
            }
            self.handleContextSensitiveActions(action, ofActionType: actionType, forCharacter: character, inRoomOrStage: room!)
            
        case .Event:
            stage!.revealItemsWithNames(action.revealItems)
            stage!.liberateItemsWithNames(action.liberateItems)
            switch actionType {
            case .Item:
                self.resolveItemTypeAction(action, forCharacter: character, inRoomOrStage: stage!)
            case .Room:
                stage!.resolveChangesToActionsForAction(action)
            case .Inventory:
                character.resolveChangesToItemsForAction(action)
            }
            self.handleContextSensitiveActions(action, ofActionType: actionType, forCharacter: character, inRoomOrStage: stage!)
        default:
            break
        }
        
        
        character.addItemsToInventory(action.addItems)
        
        // REMOVE AND DESTROY ITEMS IN PLAYER INVENTORY
        character.consumeItemsWithNames(action.consumeItems)
        
        // MAKE A CHARACTER APPEAR
        self.spawnCharacters(action.spawnCharacters)
        
        // MAKE AN INVISIBLE CHARACTER VISIBLE
        self.revealCharactersWithNames(action.revealCharacters)
        
        // REMOVE A CHARACTER FROM PLAY
        self.removeCharactersWithNames(action.removeCharacters)
        
        // MOVE CHARACTER TO A NEW ROOM
        self.moveCharacterWithAction(action)
        
        
    }
    
    
    
    
    func moveCharacterWithAction(action: Action) {
        if let moveCharacter = action.moveCharacter {
            
            self.moveCharacter(withName: moveCharacter.characterName, toRoom: self.roomForPosition((x: (self.player.position.x + moveCharacter.positionChange.x), y: (self.player.position.y + moveCharacter.positionChange.y), z: (self.player.position.z + moveCharacter.positionChange.z   ) ))!)
            
            
        }
    }
    
    
    
    
    func spawnCharacters(characters: [Character]) {
        // MAKE A CHARACTER APPEAR
        for character in characters {
            if let roomName = character.startingRoom { // Spawn character in room specified
                if let room = self.roomForName(roomName) {
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
            if let index = self.npcs.indexOf({$0.name == characterName}) {
                self.npcs[index].hidden = false
                print("ExC – \(self.npcs[index].name) IS REVEALED!")
            }
        }
    }
    
    func removeCharactersWithNames(characterNames: [String]) {
        // REMOVE A CHARACTER FROM PLAY
        for characterName in characterNames {
            print("ExC – characterName is \(characterName)")
            var character = Character?()
            
            if let index = self.npcs.indexOf({$0.name == characterName}) {
                print("ExC – \(characterName) is at self.house.npcs[\(index)]")
                character = self.npcs[index]
                print("ExC – self.house.npcs.count was \(self.npcs.count)")
                self.npcs.removeAtIndex(index)
                print("ExC – self.house.npcs.count is now \(self.npcs.count)")
                if let room = self.roomForPosition((character?.position)!) {
                    if let i = room.characters.indexOf({$0.name == characterName}) {
                        room.characters.removeAtIndex(i)
                    }
                }
            }
            
            if let index = self.currentRoom.characters.indexOf({$0.name == characterName}) {
                self.currentRoom.characters.removeAtIndex(index)
            }
            
        }
    }
    
    func resolveItemTypeAction(action: Action, forCharacter character: Character, inRoomOrStage roomOrStage: ItemBased) {
        for i in 0 ..< roomOrStage.items.count-1 {
            if let index = roomOrStage.items[i].actions.indexOf({$0.name == action.name}) {
                
                roomOrStage.items[i].actions[index].timesPerformed += 1
                
                // If the action has a REPLACE action
                if let replaceAction = action.replaceAction {
                    roomOrStage.items[i].actions[index] = replaceAction
                }
                
                // If the action can only be performed ONCE
                if action.onceOnly == true {
                    roomOrStage.items[i].actions.removeAtIndex(index)
                }
                
                // If the action is a TAKE action
                if action.name.rangeOfString("Take") != nil {
                    character.items += [roomOrStage.items[i]]
                    roomOrStage.items.removeAtIndex(i)
                    
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
                            if action.name.lowercaseString.rangeOfString("on") != nil {
                                oven.turnOn(atTime: self.gameClock.currentTime)
                            }
                            if action.name.lowercaseString.rangeOfString("off") != nil {
                                oven.turnOff()
                            }
                            if action.name.lowercaseString.rangeOfString("look") != nil {
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
    
    
    
    
    // MARK: ENCODING
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        
        self.gameClock = decoder.decodeObjectForKey("gameClock") as! GameClock
        self.width = decoder.decodeIntegerForKey("width")
        self.height = decoder.decodeIntegerForKey("height")
        self.depth = decoder.decodeIntegerForKey("depth")
        
        
        self.necessaryRooms = decoder.decodeObjectForKey("necessaryRooms") as! [String : Room]
        self.rooms = decoder.decodeObjectForKey("rooms") as! [Room]
        self.events = decoder.decodeObjectForKey("events") as! [Event]
        self.player = decoder.decodeObjectForKey("player") as! Character
        
        self.npcs = decoder.decodeObjectForKey("npcs") as! [Character]
        self.layout = decoder.decodeObjectForKey("layout") as! [[[Int]]]
        self.map = decoder.decodeObjectForKey("map") as! [[[Room]]]
        self.currentRoom = decoder.decodeObjectForKey("currentRoom") as! Room
        
        self.currentEvent = decoder.decodeObjectForKey("currentEvent") as! Event
        self.skull = decoder.decodeObjectForKey("skull") as! Skull
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.gameClock, forKey: "gameClock")
        coder.encodeInteger(self.width, forKey: "width")
        coder.encodeInteger(self.height, forKey: "height")
        coder.encodeInteger(self.depth, forKey: "depth")
        
        coder.encodeObject(self.necessaryRooms, forKey: "necessaryRooms")
        coder.encodeObject(self.rooms, forKey: "rooms")
        coder.encodeObject(self.events, forKey: "events")
        
        coder.encodeObject(self.player, forKey: "player")
    
        coder.encodeObject(self.npcs, forKey: "npcs")
        
        coder.encodeObject(self.layout, forKey: "layout")
        coder.encodeObject(self.map, forKey: "map")
        
        coder.encodeObject(self.currentRoom, forKey: "currentRoom")
        
        coder.encodeObject(self.currentEvent, forKey: "currentEvent")

        
        coder.encodeObject(self.skull, forKey: "skull")

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
    }
    
}