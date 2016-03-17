//
//  TableViewController.swift
//  horrible house
//
//  Created by TerryTorres on 3/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit



class TableViewController: UITableViewController {
    
    enum Sections : Int {
        case update = 0
        case explanation = 1
        case items = 2
        case actions = 3
        case directions = 4
        case numberOfSections = 5
    }

    struct LayoutOptions {
        // 0 is a No Room (wall).
        // 1 is a Room.
        // 2 is the Foyer.
        
        // This gives us two rows with four rooms.
        static let a = [
            [1, 2],
            [1, 1]
        ]
        // This gives us two rows with four rooms, withy noRooms (walls) on either side of the foyer.
        static let b = [
            [1, 1, 1],
            [0, 2, 0]
        ]
    }
    // .reverse makes it so that what you see is what you get: the bottom most array ends up being the first, and so on.
    
    enum Direction: String {
        case North, South, East, West
    }
    
    
    
    let house = House(layout: LayoutOptions.b)
    var currentRoom = Room(name: "null", explanation: "null", actions: [Action(name: "null")])
    var update = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make it so the player AUTOMATICALLY starts at the same position as the Foyer.
        setPlayerStartingRoom()
        
        self.title = self.currentRoom.name
        self.currentRoom.timesEntered = 1
        
        
        let topRow = house.layout[1]
        let bottomRow = house.layout[0]
        
        print("top row is    \(topRow[0]) \(topRow[1])")
        print("bottom row is \(bottomRow[0]) \(bottomRow[1])")
        
        
        print("current player position is \(house.player.position)")
        print("current room is \(roomForPosition(house.player.position)?.name)")
        print("0, 0 \(roomForPosition((x:0, y:0))!.name)")
        print("1, 0 \(roomForPosition((x:1, y:0))!.name)")
        print("0, 1 \(roomForPosition((x:0, y:1))!.name)")
        print("1, 1 \(roomForPosition((x:1, y:1))!.name)")
        
        
        
    }
    
    //
    //
    // This can be changed so the starting room could potentially be a saved room from a previous session.
    //
    func setPlayerStartingRoom() {
        var room = Room?()
        room = self.house.foyer
        self.currentRoom = room!
        self.house.player.position = self.currentRoom.position
        
    }
    
    
    // Get a room in the house for a set of x and y coordinates.
    func roomForPosition(position:(x: Int, y: Int)) -> Room? {
        var room = house.noRoom
        if ( position.y >= 0 && position.y < house.layout.count ) {
            let row = house.layout[position.y]
            if ( position.x >= 0 && position.x < row.count ) {
                room = self.house.map[position.y][position.x]
            }
        }
        return room
    }
    
    // Get the x, y position for a room in the house based on its name.
    func positionForRoom(room: Room) -> (x: Int, y: Int)? {
        var position = (x: 0, y: 0)
        for r: Room in self.house.rooms {
            if r.name == room.name {
                position = r.position
            }
        }
        return position
    }
    
    // Get a room for the name of any room in the house.rooms array
    func roomForName(name: String) -> Room? {
        var room = house.noRoom
        for r in house.rooms {
            if r.name == name {
                room = r
            }
        }
        return room
    }
    
    
    // Checks if room exists at position
    // Used to maintain the bounds of the house, so the player does not end up in a wall or outside.
    func doesRoomExistAtPosition(position:(x: Int, y: Int)) -> Bool {
        let room = roomForPosition(position)
        if ( room!.name == "No Room" || position.y < 0 || position.x < 0 || position.x >= house.width || position.y >= house.height ) {
            return false
        } else {
            return true
        }
    }
    
    
    // Get get a room in a direction adjacent to the player
    // Used to find out what the room is before entering it.
    func roomInDirection(direction:Direction) -> Room? {
        var potentialPosition = (x: house.player.position.x, y: house.player.position.y)
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
            potentialPosition = house.player.position
        }
        let potentialRoom = roomForPosition(potentialPosition)
        
        return potentialRoom
    }
    
    // Find out what direction a room is in, based on the player's position.
    // Currently used to output directions the player can move in,
    // which in turns is vital for actually moving the player in that direction.
    func directionForRoom(room:Room) -> Direction {
        var d = Direction.North
        if room.position.x < house.player.position.x {
            d = Direction.West
        } else if room.position.x > house.player.position.x {
            d = Direction.East
        } else if room.position.y < house.player.position.y {
            d = Direction.South
        } else if room.position.y > house.player.position.y {
            d = Direction.North
        }
        return d
    }
    
    // Checks for rooms around house.playerPosition
    // Needed to output the number of directions the player can actually move in,
    // which is necessary for navigation and the tableview display itself.
    func getRoomsAroundPlayer() -> [Room] {
        var roomsAroundPlayer = [Room]()
        let roomPositionToNorth = (house.player.position.x, house.player.position.y+1)
        let roomPositionToWest = (house.player.position.x-1, house.player.position.y)
        let roomPositionToSouth = (house.player.position.x, house.player.position.y-1)
        let roomPositionToEast = (house.player.position.x+1, house.player.position.y)
        if ( doesRoomExistAtPosition(roomPositionToNorth) ) {
            roomsAroundPlayer.append(roomForPosition(roomPositionToNorth)!)
            print("\(roomForPosition(roomPositionToNorth)!.name) is to the north")
        } else { print("there is no room to the north") }
        if ( doesRoomExistAtPosition(roomPositionToWest) ) {
            roomsAroundPlayer.append(roomForPosition(roomPositionToWest)!)
            print("\(roomForPosition(roomPositionToWest)!.name) is to the west")
        } else { print("there is no room to the west") }
        if ( doesRoomExistAtPosition(roomPositionToSouth) ) {
            roomsAroundPlayer.append(roomForPosition(roomPositionToSouth)!)
            print("\(roomForPosition(roomPositionToSouth)!.name) is to the south")
        } else { print("there is no room to the south") }
        if ( doesRoomExistAtPosition(roomPositionToEast) ) {
            roomsAroundPlayer.append(roomForPosition(roomPositionToEast)!)
            print("\(roomForPosition(roomPositionToEast)!.name) is to the east")
        } else { print("there is no room to the east") }
        return roomsAroundPlayer
    }
    
    
    
    // MARK: Moving around
    
    //
    //
    //
    //
    //
    //
    //
    // Make this so any character position passed in is moved to the new room?
    func moveToRoom(room:Room) {
        room.timesEntered++
        house.player.position = room.position
        self.title = room.name
        self.currentRoom = room
        self.update = ""
        self.tableView.reloadData()
    }
    
    
    
    // MARK: Tableview Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return Sections.numberOfSections.rawValue
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var rows = 0
        switch ( section ) {
        case Sections.update.rawValue:
            // Hide update section if self.update is empty
            if ( self.update != "" ) {
                rows = 1
            }
        case Sections.explanation.rawValue:
            rows = 1
        case Sections.items.rawValue:
            // Displays options to interact with carryable items, if any are present.
            rows = (self.currentRoom.items?.count)!
        case Sections.actions.rawValue:
            self.currentRoom.actionsToDisplay = removeActionsThatAreNotFollowingTheRules(self.currentRoom.actions!)
            rows = self.currentRoom.actionsToDisplay!.count
        case Sections.directions.rawValue:
            rows = getRoomsAroundPlayer().count
        default:
            break;
        }
        return rows
    }

    func removeActionsThatAreNotFollowingTheRules(var actions: [Action]) -> [Action] {
        var i = 0
        for action in actions {
            if areRulesBeingFollowedForObject(action) == false {
                actions.removeAtIndex(i)
            } else { i++ }
        }
        return actions
    }
    
    func areRulesBeingFollowedForDetail(detail: Detail) -> Bool {
        var followed = true
        if detail.rules != nil {
            for rule in detail.rules! {
                print("rule.name is \(rule.name)")
                print("rule.type is \(rule.type)")
                switch ( rule.type) {
                    
                case Rule.RuleType.hasItem:
                    print("hasItem??")
                    followed = false
                    if let _ = house.player.items!.indexOf({$0.name == rule.name}) {
                        followed = true
                        print("YAYAYAYAYAYAYA")
                    }
                    
                case Rule.RuleType.nopeHasItem:
                    print("nopeHasItem??")
                    followed = true
                    if let _ = house.player.items!.indexOf({$0.name == rule.name}) {
                        followed = false
                        print("YOYOYOYOYOYOYO")
                    }
                    
                case Rule.RuleType.metCharacter:
                    break
                case Rule.RuleType.nopeMetCharacter:
                    break
                case Rule.RuleType.enteredRoom:
                    var i = 0; for room in house.rooms {
                        if room.timesEntered > 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.nopeEnteredRoom:
                    var i = 0; for room in house.rooms {
                        if room.timesEntered == 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.triggeredEvent:
                    break
                case Rule.RuleType.nopeTriggeredEvent:
                    break
                default:
                    break;
                }
            }
        }
        
        return followed
    }
    
    func areRulesBeingFollowedForObject(object: AnyObject) -> Bool {
        var followed = true
        if object.rules != nil {
            for rule in object.rules!! {
                print("rule.name is \(rule.name)")
                print("rule.type is \(rule.type)")
                switch ( rule.type) {
                    
                case Rule.RuleType.hasItem:
                    print("hasItem??")
                    followed = false
                    if let _ = house.player.items!.indexOf({$0.name == rule.name}) {
                        followed = true
                        print("\(rule.name) is present! So the rule is being followed.")
                    }
                    
                case Rule.RuleType.nopeHasItem:
                    print("nopeHasItem??")
                    followed = true
                    if let _ = house.player.items!.indexOf({$0.name == rule.name}) {
                        followed = false
                        print("\(rule.name) is NOT present! So the rule is being followed.")
                    }
                    
                case Rule.RuleType.metCharacter:
                    break
                case Rule.RuleType.nopeMetCharacter:
                    break
                case Rule.RuleType.enteredRoom:
                    var i = 0; for room in house.rooms {
                        if room.timesEntered > 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.nopeEnteredRoom:
                    var i = 0; for room in house.rooms {
                        if room.timesEntered == 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.triggeredEvent:
                    break
                case Rule.RuleType.nopeTriggeredEvent:
                    break
                default:
                    break;
                }
            }
        }
        
        return followed
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        switch ( indexPath.section ) {
        case Sections.update.rawValue:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.text = self.update
        case Sections.explanation.rawValue:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.text = self.currentRoom.explanation
            if let details = self.currentRoom.details {
                for detail in details {
                    if areRulesBeingFollowedForObject(detail) {
                         cell.textLabel!.text = "\(cell.textLabel!.text) \(detail)"
                    }
                }
            }
            cell.userInteractionEnabled = false
        case Sections.items.rawValue:
            let item = self.currentRoom.items![indexPath.row]
            cell.textLabel!.text = "Take \(item.name)"
            cell.userInteractionEnabled = true
        case Sections.actions.rawValue:
            let action = self.currentRoom.actionsToDisplay![indexPath.row]
            cell.textLabel!.text = action.name
            cell.userInteractionEnabled = true
        case Sections.directions.rawValue:
            let room = getRoomsAroundPlayer()[indexPath.row]
            switch directionForRoom(room) {
                case .North:
                    if room.timesEntered > 0 {
                        cell.textLabel!.text = "Go north to \(room.name)"
                    } else { cell.textLabel!.text = "Go north" }
                case .South:
                    if room.timesEntered > 0 {
                        cell.textLabel!.text = "Go south to \(room.name)"
                    } else { cell.textLabel!.text = "Go south" }
                case .East:
                    if room.timesEntered > 0 {
                        cell.textLabel!.text = "Go east to \(room.name)"
                    } else { cell.textLabel!.text = "Go east" }
                case .West:
                    if room.timesEntered > 0 {
                        cell.textLabel!.text = "Go west to \(room.name)"
                    } else { cell.textLabel!.text = "Go west" }
                }
        default:
            break;
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch ( indexPath.section ) {
        case Sections.items.rawValue:
            addItemToInventory(self.currentRoom.items![indexPath.row])
        case Sections.actions.rawValue:
            resolveAction(self.currentRoom.actionsToDisplay![indexPath.row])
        case Sections.directions.rawValue:
            let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            if currentCell.textLabel?.text?.lowercaseString.rangeOfString("north") != nil {
                moveToRoom(roomInDirection(Direction.North)!)
            } else if currentCell.textLabel?.text?.lowercaseString.rangeOfString("west") != nil {
                moveToRoom(roomInDirection(Direction.West)!)
            } else if currentCell.textLabel?.text?.lowercaseString.rangeOfString("south") != nil {
                moveToRoom(roomInDirection(Direction.South)!)
            } else if currentCell.textLabel?.text?.lowercaseString.rangeOfString("east") != nil {
                moveToRoom(roomInDirection(Direction.East)!)
            }
        default:
            break
        }
    }
    
    
    func resolveAction(action: Action) {
        action.timesPerformed++
        if let result = action.result { self.update = result }
        if let roomChange = action.roomChange { self.currentRoom.explanation = roomChange }
        if let itemToPresent = action.itemToPresent {
            if self.currentRoom.items != nil { self.currentRoom.items?.append(itemToPresent) }
            else { self.currentRoom.items = [itemToPresent] }
            action.canPerformMoreThanOnce = false
        }
        if action.canPerformMoreThanOnce == false {
            for var i = 0; i < self.currentRoom.actions?.count; i++ {
                if self.currentRoom.actions![i].name == action.name { self.currentRoom.actions?.removeAtIndex(i) }
            }
        }
        print("explanation is \(self.currentRoom.explanation)")
        
        self.tableView.reloadData()
    }
    
    
    func addItemToInventory(item: Item) {
        if self.house.player.items != nil { self.house.player.items?.append(item) }
        else { self.house.player.items = [item] }
        for var i = 0; i < self.currentRoom.items?.count; i++ {
            if self.currentRoom.items![i].name == item.name { self.currentRoom.items?.removeAtIndex(i) }
        }
        self.update = "Got \(item.name)."
        
        print("\rItems in player's inventory:")
        for i in self.house.player.items! {
            print("\(i.name)")
        }
        print("\r")
        
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
