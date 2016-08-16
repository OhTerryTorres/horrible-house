//
//  ExplorationController.swift
//  horrible house
//
//  Created by TerryTorres on 3/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class ExplorationController: UITableViewController {
    
    enum TabIndex : Int {
        case house = 0
        case inventory = 1
        case map = 2
        case clock = 3
        case skull = 4
    }
    
    // self.house will allows access to self.house!.currentEvent and self.house.currntEvent.currentStage!
    // Then the house can be passed back to other viewcontrollers
    var house = House()
    var update = ""
    

    //
    // This can be changed so the starting room could potentially be a saved room from a previous session.
    //
    func setPlayerStartingRoom() {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("houseData") {
        } else {
            var room = Room?()
            room = self.house.foyer
            room?.timesEntered += 1
            self.house.player.addRoomNameToRoomHistory(room!.name)
            self.house.player.position = room!.position
        }        
    }
    
    
    func resolveAction(action: Action, actionType: Action.ActionType) {
        print("ExC – in resolveAction")

        
        if let result = action.result { self.update = self.translateSpecialText(result) }
        if let roomChange = action.roomChange { self.house.currentRoom.explanation = roomChange }
        
        for itemName in action.revealItems {
            if let index = self.house.currentRoom.items.indexOf({$0.name == itemName}) {
                print("ExC – \(itemName) is no longer hidden!")
                self.house.currentRoom.items[index].hidden = false
            }
        }
        for itemName in action.liberateItems {
            if let index = self.house.currentRoom.items.indexOf({$0.name == itemName}) {
                print("ExC – \(itemName) has been liberated and can be carried!")
                self.house.currentRoom.items[index].enableCarrying()
            }
        }
        
        for item in action.addItems {
            print("ExC – adding \(item.name) to inventory")
            self.house.player.items += [item]
        }
        
        for itemName in action.consumeItems {
            if let _ = self.house.player.items.indexOf({$0.name == itemName}) {
                print("ExC – consuming item in inventory")
                self.house.player.removeItemFromItems(withName: itemName)
            }
        }
        
        for character in action.spawnCharacters {
            if let roomName = character.startingRoom { // Spawn character in room specified
                if let room = self.house.roomForName(roomName) {
                    room.characters += [character]
                    character.position = room.position
                }
            } else { // Spawn character in currentRoom
                print("ExC – spawning \(character.name) in current room")
                self.house.currentRoom.characters += [character]
                character.position = self.house.currentRoom.position
            }
            self.house.npcs += [character]
            print("ExC – \(character.name) IS IN THE HOUSE!")
        }
        
        for characterName in action.revealCharacters {
            if let index = self.house.currentRoom.characters.indexOf({$0.name == characterName}) {
                let character = self.house.currentRoom.characters[index]
                character.hidden = false
                character.position = self.house.currentRoom.position
                self.house.npcs += [character]
                print("ExC – \(character.name) IS REVEALED!")
            }
        }
        
        for characterName in action.removeCharacters {
            print("ExC – characterName is \(characterName)")
            var character = Character?()
            
            if let index = self.house.npcs.indexOf({$0.name == characterName}) {
                print("ExC – \(characterName) is at self.house.npcs[\(index)]")
                character = self.house.npcs[index]
                print("ExC – self.house.npcs.count was \(self.house.npcs.count)")
                self.house.npcs.removeAtIndex(index)
                print("ExC – self.house.npcs.count is now \(self.house.npcs.count)")
            }
            
            if let c = character {
                
                if let index = self.house.map[c.position.z][c.position.y][c.position.x].characters.indexOf({ $0.name == c.name }) {
                    // ******
                    // Test this to see if characters need to be removed via the house.MAP or just the house.ROOMS array
                    // ******
                    self.house.map[c.position.z][c.position.y][c.position.x].characters.removeAtIndex(index)
                    print("ExC – \(c.name) is being removed from \(self.house.map[c.position.z][c.position.y][c.position.x].name)")
                }
            }
            
            if let index = self.house.currentRoom.characters.indexOf({$0.name == characterName}) {
                self.house.currentRoom.characters.removeAtIndex(index)
            }
            
        }
        
        switch actionType {
        case .Item:
            for i in 0 ..< self.house.currentRoom.items.count-1 {
                if let index = self.house.currentRoom.items[i].actions.indexOf({$0.name == action.name}) {
                    self.house.currentRoom.items[i].actions[index].timesPerformed += 1
                    
                    // If the action has a REPLACE action
                    if let replaceAction = action.replaceAction {
                        self.house.currentRoom.items[i].actions[index] = replaceAction
                    }
                    
                    // If the action can only be performed ONCE
                    if action.onceOnly == true {
                        self.house.currentRoom.items[i].actions.removeAtIndex(index)
                    }
                    
                    // If the action is a TAKE action
                    if action.name.rangeOfString("Take") != nil {
                        self.house.player.items += [self.house.currentRoom.items[i]]
                        self.house.currentRoom.items.removeAtIndex(i)
                        
                        if let tabBarController = self.tabBarController as? TabBarController {
                            tabBarController.refreshViewControllers()
                        }
                    }
                    break // THIS keeps the loop from crashing as it examines an item that does not exist.
                    // It also makes sure multiple similar actions aren't renamed.
                    // this seems like a clumsy solution, but it currently works.
                }
            }
        case .Room:
            
            if let index = self.house.currentRoom.actions.indexOf({$0.name == action.name}) {
                action.timesPerformed += 1
                if let replaceAction = action.replaceAction {
                    self.house.currentRoom.actions[index] = replaceAction
                }
                if action.onceOnly == true {
                    self.house.currentRoom.actions.removeAtIndex(index)
                }
            }
        case .Inventory:
            for item in self.house.player.items {
                if let index = item.actions.indexOf({$0.name == action.name}) {
                    if item.actions[index].isFollowingTheRules() {
                        item.actions[index].timesPerformed += 1
                        
                        // If the action has a REPLACE action
                        if let replaceAction = action.replaceAction {
                            item.actions[index] = replaceAction
                        }
                        
                        // If the action can only be performed ONCE
                        if action.onceOnly == true {
                            item.actions.removeAtIndex(index)
                        }
                        
                        break // THIS keeps the loop from crashing as it examines an item that does not exist.
                        // It also makes sure multiple similar actions aren't renamed.
                        // this seems like a clumsy solution, but it currently works.
                        
                    }
                }
            }
        }
        
        // This should be done before any transitions occur
        self.handleContextSensitiveActions(action, actionType: actionType)
        
        if let triggerEvent = action.triggerEvent { self.triggerEvent(triggerEvent)}
        
        if let segue = action.segue { performSegueWithIdentifier(segue.identifier, sender: action)}
        
        if let moveCharacter = action.moveCharacter {
            
            self.house.moveCharacter(withName: moveCharacter.characterName, toRoom: self.house.roomForPosition((x: (self.house.player.position.x + moveCharacter.positionChange.x), y: (self.house.player.position.y + moveCharacter.positionChange.y), z: (self.house.player.position.z + moveCharacter.positionChange.z   ) ))!)
            
            self.update = ""
            self.title = self.house.currentRoom.name
        }
    }
    
    func handleContextSensitiveActions(action: Action, actionType: Action.ActionType) {
        switch actionType {
        case .Item:
            for i in 0 ..< self.house.currentRoom.items.count {
                for o in 0 ..< self.house.currentRoom.items[i].actions.count {
                    if self.house.currentRoom.items[i].actions[o].name == action.name {
                        
                        let item = self.house.currentRoom.items[i]
                        
                        
                        // OVEN ACTIONS
                        
                        if let oven = item as? Oven {
                            
                            print("ExC – Shit! an oven!")
                            if action.name.lowercaseString.rangeOfString("on") != nil {
                                oven.turnOn(atTime: self.house.gameClock.currentTime)
                            }
                            if action.name.lowercaseString.rangeOfString("off") != nil {
                                oven.turnOff()
                            }
                            if action.name.lowercaseString.rangeOfString("look") != nil {
                                oven.checkOven(atTime: self.house.gameClock.currentTime)
                            }
                        }
                    }
                }
            }
        default:
            break
        }

    }
    
    func resolveDirection(forIndexPath indexPath: NSIndexPath) {
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        let text = currentCell.textLabel?.text?.lowercaseString
        if text!.rangeOfString("north") != nil {
            self.house.moveCharacter(withName: "player", toRoom: self.house.roomInDirection(House.Direction.North)!)
        } else if text!.rangeOfString("west") != nil {
            self.house.moveCharacter(withName: "player", toRoom: self.house.roomInDirection(House.Direction.West)!)
        } else if text!.rangeOfString("south") != nil {
            self.house.moveCharacter(withName: "player", toRoom: self.house.roomInDirection(House.Direction.South)!)
        } else if text!.rangeOfString("east") != nil {
            self.house.moveCharacter(withName: "player", toRoom: self.house.roomInDirection(House.Direction.East)!)
        }
    }
    
    func triggerEvent( triggerEvent:(eventName: String, stageName: String?) ) {
        if let index = self.house.events.indexOf({ $0.name == triggerEvent.eventName }) {
            if self.house.events[index].isFollowingTheRules() {
                print("ExC – moving to event \(self.house.events[index].name)")
                var dict = ["eventName" : triggerEvent.eventName]
                if let stageName = triggerEvent.stageName {
                    dict = ["eventName" : triggerEvent.eventName, "stageName" : stageName]
                }
                performSegueWithIdentifier("event", sender: dict as AnyObject)
            }
        }
    }
    
    func suddenEventDoesOccur() -> Bool {
        var bool = false
        if let eventName = self.house.getViableSuddenEventName() {
            if eventName != "" {
                self.triggerEvent( (eventName: eventName, String?() ) )
                bool = true
            }
        }
        return bool
    }
    
    func endTurn() {
        self.house.skull.updateSkull()
        
        // *******
        // Keep this commented out if we want time kept as REAL time
        //self.house.gameClock.passTimeByTurn()
        
        
        
        self.house.triggerNPCBehaviors()
        
        if self.house.gameClock.reachedEndTime && self.house.gameClock.didClockChime == false {
            self.clockChime()
        }
    }
    
    func clockChime() {
        let string = "You can hear the grandfather clock chime from the house's entrance, marking the hour."
        if self.update.characters.count > 0 {
            self.update = string + "\r\r" + self.update
        } else {
            self.update = string
        }
        self.house.gameClock.didClockChime = true
        
    }
    
    
    // This deals with text that needs to be formatted to include game properties.
    // ex. The current time.
    func translateSpecialText(string: String) -> String {
        var string = string
        if (string.rangeOfString("[currentTime]") != nil) {
            if self.house.gameClock.currentTime.minutes < 10 {
                print("XXXXX")
                string = string.stringByReplacingOccurrencesOfString("[currentTime]", withString: "\(self.house.gameClock.currentTime.hours):0\(self.house.gameClock.currentTime.minutes) and \(self.house.gameClock.currentTime.seconds) seconds")
            } else { 
            string = string.stringByReplacingOccurrencesOfString("[currentTime]", withString: "\(self.house.gameClock.currentTime.hours):\(self.house.gameClock.currentTime.minutes) and \(self.house.gameClock.currentTime.seconds) seconds")
            }
        }
        return string
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("ExC – leaving EXPLORATION CONTROLLER")
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            let ec = segue.destinationViewController as! EventController
            ec.house = self.house
            if let triggerEventDict = sender as? Dictionary<String, String> {
                ec.house.currentEvent = self.house.eventForName(triggerEventDict["eventName"]!)!
                ec.house.currentEvent.currentStage = ec.house.currentEvent.stages[0]
                if let stageName = triggerEventDict["stageName"] {
                    if let index = ec.house.currentEvent.stages.indexOf({$0.name == stageName}) {
                        ec.house.currentEvent.currentStage = ec.house.currentEvent.stages[index]
                    }
                }
                
            }
            
        }
        if segue.identifier == "piano" {
            let pc = segue.destinationViewController as! PianoController
            pc.house = self.house
        }
        if segue.identifier == "container" {
            let cc = segue.destinationViewController as! ContainerController
            
            let action = sender as! Action
            var itemName = action.name.stringByReplacingOccurrencesOfString("Look in {[item]", withString: "")
            itemName = itemName.stringByReplacingOccurrencesOfString("}", withString: "")
            if let index = self.house.currentRoom.items.indexOf({$0.name == itemName}) {
                cc.container = self.house.currentRoom.items[index]
            }
            
            
        }
        
        if segue.identifier == "gameOver" {
            let goc = segue.destinationViewController as! GameOverController
            let action = sender as! Action
            goc.messageLabel.text = action.segue?.qualifier
            
        }
        
        
    }
    
    
    // MARK: View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.setStyle()
        
        // Make it so the player AUTOMATICALLY starts at the same position as the Foyer.
        setPlayerStartingRoom()
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.refreshViewControllers()
        }
        
        
        self.title = self.house.currentRoom.name
        self.tabBarItem = UITabBarItem(title: "House", image: nil, tag: 0)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = self.house.currentRoom.name
        self.update = ""
        self.tableView.reloadData()
        print("ExC – reloading table")
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
    
    
    // MARK: Tableview Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return getNumberOfTableSections()
    }
    
    func getNumberOfTableSections() -> Int {
        var numberOfSections = 5
        for _ in self.house.currentRoom.items {
            numberOfSections += 1
        }
        return numberOfSections
    }
    
    
    // Table Section Key
    // 0: Update
    // 1: Explanation
    // 2: Room Actions
    // 3 through (sections.count - 3): Item Actions
    // sections.count - 2: Inventory Actions
    // sections.count - 1: Directions
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        switch ( section ) {
            
            // UPDATE
        case 0:
            // Hide update section if self.update is empty
            if ( self.update != "" ) {
                rows = 1
            }
            
            // ROOM EXPLANATION
        case 1:
            rows = 1
            
            // ROOM ACTIONS
        case 2:
            rows = self.house.currentRoom.actions.count
            
            // DIRECTIONS
        case getNumberOfTableSections()-1:
            rows = self.house.getRoomsAroundCharacter(self.house.player).count
            
            // INVENTORY ACTIONS
        case getNumberOfTableSections()-2:
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        rows += 1
                    }
                }
            }
            
            // ITEM ACTIONS
        default:
            // -3 to deal with the other table sections.
            if self.house.currentRoom.items.count > 0 {
                let item = self.house.currentRoom.items[section-3]
                rows = item.actions.count
            }
            
        }
        return rows
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.setStyle()
        
        cell.textLabel!.numberOfLines = 0
        
        // Configure the cell...
        switch ( indexPath.section ) {
            
            // UPDATE
        case 0:
            cell.textLabel!.setAttributedTextWithTags(self.update)
            cell.textLabel!.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
            cell.userInteractionEnabled = false
            
            // ROOM EXPLANATION
        case 1:
            cell.textLabel!.setAttributedTextWithTags(self.house.currentRoom.explanation)
            for detail in self.house.currentRoom.details {
                if detail.isFollowingTheRules() {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + detail.explanation
                    cell.textLabel!.setAttributedTextWithTags(string!)
                }
            }
            
            
            // Adds each item's "explanation" property to the room explanation.
            for item in self.house.currentRoom.items {
                if item.hidden == false {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + item.explanation
                    for detail in item.details {
                        if detail.isFollowingTheRules() {
                            string = string! + " " + detail.explanation
                        }
                    }
                    cell.textLabel!.setAttributedTextWithTags(string!)
                }
            }
            
            // Adds each non-hidden character's "explanation" property to the room explanation.
            for character in self.house.currentRoom.characters {
                print("ExC – \(character.name) is in currentRoom.characters")
                print("ExC – \(character.name)'s position \(character.position)")
                if character.hidden == false && character.name != "Player" {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + character.explanation
                    cell.textLabel!.setAttributedTextWithTags(string!)
                }
            }
            
            cell.userInteractionEnabled = false
            // ROOM ACTIONS
        case 2:
            let action = self.house.currentRoom.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
            
            // DIRECTIONS
        case getNumberOfTableSections()-1:
            let room = self.house.getRoomsAroundCharacter(self.house.player)[indexPath.row]
            var directionString = ""
            switch self.house.directionForRoom(room) {
            case .North:
                if room.timesEntered > 0 {
                    directionString = "Go north to {[room]\(room.name)}"
                } else { directionString = "Go north" }
            case .South:
                if room.timesEntered > 0 {
                    directionString = "Go south to {[room]\(room.name)}"
                } else { directionString = "Go south" }
            case .East:
                if room.timesEntered > 0 {
                    directionString = "Go east to {[room]\(room.name)}"
                } else { directionString = "Go east" }
            case .West:
                if room.timesEntered > 0 {
                    directionString = "Go west to {[room]\(room.name)}"
                } else { directionString = "Go west" }
            }
            cell.textLabel!.setAttributedTextWithTags(directionString)
            cell.userInteractionEnabled = true
            
            // INVENTORY ACTIONS
        case getNumberOfTableSections()-2:
            
            var inventoryActions : [Action] = []
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        inventoryActions += [action]
                    }
                }
            }
            let action = inventoryActions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
            
            
            // ITEM ACTIONS
        default:
            // -3 to deal with the other table sections.
            let item = self.house.currentRoom.items[indexPath.section-3]
            let action = item.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if suddenEventDoesOccur() == false {
            
            
            var action = Action?()
            
            switch ( indexPath.section ) {
                
            // ROOM ACTIONS
            case 2:
                print("ExC – selected Room Action \n")
                action = self.house.currentRoom.actions[indexPath.row]
                resolveAction(action!, actionType: Action.ActionType.Room)
                
            // DIRECTIONS
            case getNumberOfTableSections()-1:
                print("ExC – selected Direction \n")
                resolveDirection(forIndexPath: indexPath)
                self.update = ""
                self.title = self.house.currentRoom.name
                
                //self.tableView.reloadData()
                //let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                //self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
                //print("ExC – reloading table")
                
            // INVENTORY ACTIONS
            case getNumberOfTableSections()-2:
                print("ExC – selected Inventory Action \n")
                var inventoryActions : [Action] = []
                for item in self.house.player.items {
                    print("ExC – OH")
                    for action in item.actions {
                        print("ExC – MY")
                        if action.isFollowingTheRules() {
                            print("ExC – GOD")
                            inventoryActions += [action]
                        }
                    }
                }
                print("ExC – indexPath.row is \(indexPath.row)")
                if inventoryActions.count > indexPath.row {
                    print("ExC – BOOP, resolving inventoryActions[\(indexPath.row)]: \(inventoryActions[indexPath.row].name)")
                    action = inventoryActions[indexPath.row]
                    resolveAction(inventoryActions[indexPath.row], actionType: Action.ActionType.Inventory)
                }
                
                
                
            // ITEM ACTIONS
            default:
                print("ExC – selected Item Action \n")
                action = self.house.currentRoom.items[indexPath.section-3].actions[indexPath.row]
                resolveAction(action!, actionType: Action.ActionType.Item)
                
                break
            }
            
            
            if let _ = action?.triggerEvent {
                
            } else if let _ = action?.segue {
                self.endTurn()
            } else {
                
                self.endTurn()
                
                print("ExC – special table reload functions")
                
                if let actionName = action?.name {
                    if actionName.rangeOfString("Take") != nil { // TAKE: In case of picking up an item, slide in UPDATE section saying so.
                        
                        let sections = NSMutableIndexSet(indexesInRange: NSMakeRange(0, 1))
                        
                        self.tableView.reloadData()
                        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Left  )
                        print("ExC – reloading table")
                    } else { // In case of any other action, fade entire tableview
                        
                        if let _ = action?.moveCharacter {
                            self.tableView.reloadData()
                        }
                        let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                        self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
                        print("ExC – reloading table")
                    }
                } else { // DIRECTION: in case of moving from one room to another, fade entire tablevew.
                    self.tableView.reloadData()
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
                }
                
            }
            
            
            
            self.scrollToTop()
            
            
        }
        

    }
    
    func scrollToTop() {
        if (self.numberOfSectionsInTableView(self.tableView) > 0 ) {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            // let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            if numberOfRows > 0 && numberOfSections > 0 {
                // self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }
            
            let top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
            self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = UITableViewAutomaticDimension
        
        switch indexPath.section {
            
            // UPDATE
        case 0:
            break
            
            // ROOM EXPLANATION
        case 1:
            break
            
            // ROOM ACTIONS
        case 2:
            if self.house.currentRoom.actions[indexPath.row].isFollowingTheRules() == false {
                height = 0
            }
            
            // DIRECTIONS
        case getNumberOfTableSections()-1:
            break
            
        // INVENTORY ACTIONS
        case getNumberOfTableSections()-2:
            break
            
            // ITEM ACTIONS
        default:
            // -3 to deal with the other table sections.
            let item = self.house.currentRoom.items[indexPath.section-3]
            
            if item.hidden == true {
                height = 0
            }
            if item.actions[indexPath.row].name.rangeOfString("Take") != nil && item.canCarry == false {
                height = 0
            }
            if item.actions[indexPath.row].isFollowingTheRules() == false {
                height = 0
            }
        }

        
        
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch ( section ) {
            
        // UPDATE
        case 0:
            if self.update != "" {
                return "UPDATE"
            } else { return nil }
            
        // ROOM EXPLANATION
        case 1:
            return nil
            
        // ROOM ACTIONS
        case 2:
            return "ACT"
            
        // DIRECTIONS
        case getNumberOfTableSections()-1:
            return "MOVE"
            
        // ITEM ACTIONS
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        var frame = header.frame
        frame.size.height = 10
        header.frame = frame
        
        header.textLabel!.font = Font.headerFont
        header.textLabel!.frame = header.frame
        
        header.backgroundView?.backgroundColor = Color.foregroundColor
        header.textLabel!.textColor = Color.backgroundColor
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
