//
//  EventController.swift
//  horrible house
//
//  Created by TerryTorres on 3/21/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit

class EventController: UITableViewController {

    enum Sections : Int {
        case update = 0
        case explanation = 1
        case roomActions = 2
        case inventoryActions
        case numberOfSections = 4
        // Each item has its own section
        // In switch cases, they will count as Default
    }

    
    // self.house will allows access to self.house!.currentEvent and self.house.currntEvent.currentStage!
    // Then the house can be passed back to other viewcontrollers
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    var update = ""

    var isInventoryEvent = false
    
    
    
    
    
    func resolveAction(action: Action, isItemAction: Bool) {
        
        if let result = action.result { self.update = result }
        if let roomChange = action.roomChange { self.house.currentEvent.currentStage!.explanation = roomChange }
        
        for itemName in action.revealItems {
            print("EvC – revealItems")
            for item in self.house.currentEvent.currentStage!.items {
                if item.name == itemName {
                    item.hidden = false
                }
            }
        }
        
        for itemName in action.liberateItems {
            print("EvC – liberateItems")
            for item in self.house.currentEvent.currentStage!.items {
                if item.name == itemName {
                    item.canCarry = true
                    }
            }
        }
        
        for item in action.addItems {
            print("EvC – adding item to inventory")
            self.house.player.items += [item]
        }
        
        for itemName in action.consumeItems {
            for item in self.house.player.items {
                if item.name == itemName {
                    print("EvC – consuming item in inventory")
                    self.house.player.removeItemFromItems(withName: itemName)
                }
            }
        }
        
        for character in action.spawnCharacters {
            if let roomName = character.startingRoom {
                if let room = self.house.roomForName(roomName) {
                    room.characters += [character]
                    character.position = room.position
                }
            } else {
                print("EvC – spawning \(character.name) in current room")
                self.house.currentRoom.characters += [character]
                character.position = self.house.currentRoom.position
            }
            self.house.npcs += [character]
            print("EvC – \(character.name) IS IN THE HOUSE!")
        }
        
        for characterName in action.revealCharacters {
            for character in self.house.currentRoom.characters {
                if character.name == characterName {
                    character.hidden = false
                    character.position = self.house.currentRoom.position
                    self.house.npcs += [character]
                    print("EvC – \(character.name) IS REVEALED!")
                }
            }
        }
        
        for characterName in action.removeCharacters {
            var character = Character?()
            
            if let index = self.house.npcs.indexOf({$0.name == characterName}) {
                character = self.house.npcs[index]
                self.house.npcs.removeAtIndex(index)
            }
            
            if let c = character {
                
                if let index = self.house.map[c.position.z][c.position.y][c.position.x].characters.indexOf({ $0.name == c.name }) {
                    // ******
                    // Test this to see if characters need to be removed via the house.MAP or just the house.ROOMS array
                    // ******
                    self.house.map[c.position.z][c.position.y][c.position.x].characters.removeAtIndex(index)
                }
            }
            
            if let index = self.house.currentRoom.characters.indexOf({$0.name == characterName}) {
                self.house.currentRoom.characters.removeAtIndex(index)
            }
            
        }
        
        if isItemAction {
            print("EvC – isItemAction")
            for i in 0 ..< self.house.currentEvent.currentStage!.items.count {
                if let index = self.house.currentEvent.currentStage!.items[i].actions.indexOf({$0.name == action.name}) {
                    self.house.currentEvent.currentStage!.items[i].actions[index].timesPerformed += 1
                    
                    // If the action has a REPLACE action
                    if let replaceAction = action.replaceAction {
                        self.house.currentEvent.currentStage!.items[i].actions[index] = replaceAction
                    }
                    
                    // If the action can only be performed ONCE
                    if action.onceOnly == true {
                        print("item is \(self.house.currentEvent.currentStage!.items[i].name), action is \(self.house.currentEvent.currentStage!.items[i].actions[index].name)")
                        self.house.currentEvent.currentStage!.items[i].actions.removeAtIndex(index)
                    }
                    
                    // If the action is a TAKE action
                    if action.name.rangeOfString("Take") != nil {
                        self.house.player.items += [self.house.currentEvent.currentStage!.items[i]]
                        self.house.currentEvent.currentStage!.items.removeAtIndex(i)
                        
                        if let tabBarController = self.tabBarController as? TabBarController {
                            tabBarController.refreshViewControllers()
                        }
                        
                    }
                    break // THIS keeps the loop from crashing as it examines an item that does not exist.
                    // It also makes sure multiple similar actions aren't renamed.
                    // this seems like a clumsy solution, but it currently works.
                }
            }
        } else { // Room Actions
            print("EvC – isRoomAction")
            for i in 0 ..< self.house.currentEvent.currentStage!.actions.count {
                if self.house.currentEvent.currentStage!.actions[i].name == action.name {
                    action.timesPerformed += 1
                    if let replaceAction = action.replaceAction {
                        self.house.currentEvent.currentStage!.actions[i] = replaceAction
                    }
                    if action.onceOnly == true {
                        self.house.currentEvent.currentStage!.actions.removeAtIndex(i)
                    }
                    break
                }
            }
        }
        
        // This should be done before any transitions occur
        self.handleContextSensitiveActions(action, isItemAction: isItemAction)
        
        if let triggerEventName = action.triggerEventName { triggerEvent(forEventName: triggerEventName)}
        
        if let segue = action.segue { performSegueWithIdentifier(segue, sender: nil)}
        
        if let changeFloor = action.changeFloor {
            switch changeFloor {
            case 0:
                self.house.moveCharacter(withName: "player", toRoom: self.house.roomForPosition((x:self.house.player.position.x, y:self.house.player.position.x, z:0))!)
            case 1:
                self.house.moveCharacter(withName: "player", toRoom: self.house.roomForPosition((x:self.house.player.position.x, y:self.house.player.position.x, z:1))!)
            case 2:
                self.house.moveCharacter(withName: "player", toRoom: self.house.roomForPosition((x:self.house.player.position.x, y:self.house.player.position.x, z:2))!)
            default:
                break
            }
            self.update = ""
            self.title = self.house.currentRoom.name
        }
        
    }
    
    func handleContextSensitiveActions(action: Action, isItemAction: Bool) {
        if isItemAction {
            for i in 0 ..< self.house.currentRoom.items.count {
                if let _ = self.house.currentRoom.items[i].actions.indexOf({$0.name == action.name}) {
                        
                    let item = self.house.currentRoom.items[i]
                    
                    
                    // OVEN ACTIONS
                    
                    if let oven = item as? Oven {
                        
                        print("EvC – Shit! an oven!")
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
    }
    
    
    func triggerEvent(forEventName eventName: String) {
        for event in self.house.events {
            if event.name == eventName {
                if event.isFollowingTheRules() {
                    self.house.currentEvent = event
                }
            }
        }
        if eventName == "" {
            print("EvC – exiting event")
            if self.isInventoryEvent {
                print("EvC – about to exit to Inventory")
                performSegueWithIdentifier("exitToInventory", sender: nil)
            } else {
                performSegueWithIdentifier("exit", sender: nil)
            }
        }
    }
    
    // This deals with text that needs to be formatted to include game properties.
    // ex. The current time.
    func translateSpecialText(string: String) -> String {
        var newString = ""
        if (string.rangeOfString("[currentTime]") != nil) {
            newString = string.stringByReplacingOccurrencesOfString("[currentTime]", withString: "\(self.house.gameClock.currentTime.hours):\(self.house.gameClock.currentTime.minutes)")
        }
        return newString
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        self.house.currentEvent.completed = true
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "exit" {
            let ec = segue.destinationViewController as! ExplorationController
            ec.house = self.house
        }
        if segue.identifier == "exitToInventory" {
            let ic = segue.destinationViewController as! InventoryController
            ic.house = self.house
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.refreshViewControllers()
        }
        
        self.house.currentEvent.setCurrentStage()
        self.navigationItem.setHidesBackButton(true, animated:false);
        self.title = self.house.currentEvent.currentStage!.name
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
    }
    
    // MARK: Tableview Functions
    
    func getNumberOfTableSections() -> Int {
        var numberOfSections = Sections.numberOfSections.rawValue
        for _ in self.house.currentEvent.currentStage!.items {
            numberOfSections += 1
        }
        return numberOfSections
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return getNumberOfTableSections()
    }
    
    
    // Table Section Key
    // 0: Update
    // 1: Explanation
    // 2: Room Actions
    // 3 through (sections.count - 2): Item Actions
    // sections.count: Directions
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        switch ( section ) {
            
            // UPDATE
        case Sections.update.rawValue:
            // Hide update section if self.update is empty
            if ( self.update != "" ) {
                rows = 1
            }
            
            // ROOM EXPLANATION
        case Sections.explanation.rawValue:
            rows = 1
            
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            rows = self.house.currentEvent.currentStage!.actions.count
            
        // INVENTORY ACTIONS
        case Sections.inventoryActions.rawValue:
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        print("EvC – rows += 1")
                        rows += 1
                    }
                }
            }
            
            // ITEM ACTIONS
        default:
            // -2 to deal with the other table sections.
            if self.house.currentEvent.currentStage!.items.count > 0 {
                let item = self.house.currentEvent.currentStage!.items[section-4]
                rows = item.actions.count
            }
        }
        
        return rows
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        // Configure the cell...
        switch ( indexPath.section ) {
            
            // UPDATE
        case Sections.update.rawValue:
            cell.textLabel!.numberOfLines = 0
            cell.textLabel!.setAttributedTextWithTags(self.update)
            cell.userInteractionEnabled = false
            
            // EVENT EXPLANATION
        case Sections.explanation.rawValue:
            cell.textLabel!.numberOfLines = 0
            cell.textLabel!.setAttributedTextWithTags(self.house.currentEvent.currentStage!.explanation)
            for item in self.house.currentEvent.currentStage!.items {
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
            cell.userInteractionEnabled = false
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            let action = self.house.currentEvent.currentStage!.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
            
        case Sections.inventoryActions.rawValue:
            
            var inventoryActions : [Action] = []
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        print("EvC – rows += 1 FUCK")
                        inventoryActions += [action]
                    }
                }
            }
            let action = inventoryActions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
            
            // ITEM ACTIONS
        default:
            // -4 to deal with the other table sections.
            let item = self.house.currentEvent.currentStage!.items[indexPath.section-4]
            print("\(item.name) has a cell now")
            let action = item.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var action = Action?()
        
        switch ( indexPath.section ) {
            
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            print("EvC – room action selected")
            action = self.house.currentEvent.currentStage!.actions[indexPath.row]
            resolveAction(action!, isItemAction: false)
            
        // INVENTORY ACTIONS
        case Sections.inventoryActions.rawValue:
            print("EvC – selected Inventory Action \n")
            var inventoryActions : [Action] = []
            for item in self.house.player.items {
                print("EvC – OH")
                for action in item.actions {
                    print("EvC – MY")
                    if action.isFollowingTheRules() {
                        print("EvC – GOD")
                        inventoryActions += [action]
                    }
                }
            }
            print("EvC – indexPath.row is \(indexPath.row)")
            if inventoryActions.count > indexPath.row {
                print("EvC – BOOP")
                resolveAction(inventoryActions[indexPath.row], isItemAction: true)
            }
            
            // ITEM ACTIONS
        default:
            print("EvC – item action selected")
            action = self.house.currentEvent.currentStage!.items[indexPath.section-4].actions[indexPath.row]
            resolveAction(action!, isItemAction: true)
            
            break
        }
        
        // self.tableView.reloadData()
        
        if let _ = action?.triggerEventName {
            
        } else {
            
            if let actionName = action?.name {
                if actionName.rangeOfString("Take") != nil {
                    print("EvC – animating table changes (TAKE action")
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections-1))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    print("EvC – animating table changes")
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
                
        
        self.house.skull.updateSkull()
        
        
        if let _ = action?.triggerEventName {
            
        } else if let _ = action?.segue{
            
        } else {
            
            if let actionName = action?.name {
                if actionName.rangeOfString("Take") != nil {
                    
                    let sections = NSMutableIndexSet(indexesInRange: NSMakeRange(0, 1))
                    
                    self.tableView.reloadData()
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Left  )
                } else {
                    
                    if let _ = action?.changeFloor {
                        self.tableView.reloadData()
                    }
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
            
        }
        
        self.scrollToTop()
        
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
        case Sections.update.rawValue:
            break
            
            // ROOM EXPLANATION
        case Sections.explanation.rawValue:
            break
            
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            if self.house.currentEvent.currentStage!.actions[indexPath.row].isFollowingTheRules() == false {
                height = 0
            }
            
            // ITEM ACTIONS
        default:
            // -3 to deal with the other table sections.
            let item = self.house.currentEvent.currentStage!.items[indexPath.section-4]
    
            if item.hidden == true {
                print("EvC – \(item.name) IS HIDDEN!")
                height = 0
            }
            if item.actions[indexPath.row].name.rangeOfString("Take") != nil && item.canCarry == false {
                print("EvC – \(item.name) cannot be carried!")
                height = 0
            }
            if item.actions[indexPath.row].isFollowingTheRules() == false {
                print("EvC – \(item.actions[indexPath.row].name) is not following the rules!")
                height = 0
            }
            
            print("EvC – HEIGHT – item is \(item.name), height is \(height)")
            
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch ( section ) {
            
        // UPDATE
        case Sections.update.rawValue:
            if self.update != "" {
                return "UPDATE"
            } else { return nil }
            
        // ROOM EXPLANATION
        case Sections.explanation.rawValue:
            return nil
            
        // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            return "ACT"
            
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
        
        header.textLabel!.font = UIFont.boldSystemFontOfSize(10)
        header.textLabel!.frame = header.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
