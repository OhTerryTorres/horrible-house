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
        case numberOfSections = 3
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
            print("revealItems")
            for item in self.house.currentEvent.currentStage!.items {
                if item.name == itemName {
                    item.hidden = false
                }
            }
        }
        
        for itemName in action.liberateItems {
            print("liberateItems")
            for item in self.house.currentEvent.currentStage!.items {
                if item.name == itemName {
                    item.canCarry = true
                }
            }
        }
        
        for itemName in action.consumeItems {
            for item in self.house.player.items {
                if item.name == itemName {
                    print("consuming item in inventory")
                    self.house.player.removeItemFromItems(withName: itemName)
                }
            }
        }
        
        if isItemAction {
            print("isItemAction")
            for var i = 0; i < self.house.currentEvent.currentStage!.items.count; i++ {
                for var o = 0; o < self.house.currentEvent.currentStage!.items[i].actions.count; o++ {
                    if self.house.currentEvent.currentStage!.items[i].actions[o].name == action.name {
                        self.house.currentEvent.currentStage!.items[i].actions[o].timesPerformed += 1
                        
                        // If the action has a REPLACE action
                        if let replaceAction = action.replaceAction {
                            self.house.currentEvent.currentStage!.items[i].actions[o] = replaceAction
                        }
                        
                        // If the action can only be performed ONCE
                        if action.onceOnly == true {
                            self.house.currentEvent.currentStage!.items[i].actions.removeAtIndex(o)
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
            }
        } else { // Room Actions
            print("isRoomAction")
            for var i = 0; i < self.house.currentEvent.currentStage!.actions.count; i++ {
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
            for var i = 0; i < self.house.currentRoom.items.count; i++ {
                for var o = 0; o < self.house.currentRoom.items[i].actions.count; o++ {
                    if self.house.currentRoom.items[i].actions[o].name == action.name {
                        
                        let item = self.house.currentRoom.items[i]
                        
                        
                        // OVEN ACTIONS
                        
                        if let oven = item as? Oven {
                            
                            print("Shit! an oven!")
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
            print("exiting event")
            if self.isInventoryEvent {
                print("about to exit to Inventory")
                performSegueWithIdentifier("exitToInventory", sender: nil)
            } else {
                performSegueWithIdentifier("exit", sender: nil)
            }
        }
    }
    
    // This deals with text that needs to be formatted to include game properties.
    // ex. The current time.
    func translateSpecialText(var string: String) -> String {
        if (string.rangeOfString("[currentTime]") != nil) {
            string = string.stringByReplacingOccurrencesOfString("[currentTime]", withString: "\(self.house.gameClock.currentTime.hours):\(self.house.gameClock.currentTime.minutes)")
        }
        return string
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
            numberOfSections++
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
            
            // ITEM ACTIONS
        default:
            // -2 to deal with the other table sections.
            if self.house.currentEvent.currentStage!.items.count > 0 {
                let item = self.house.currentEvent.currentStage!.items[section-section]
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
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.setAttributedTextWithTags(self.update, isAnimated: true)
            cell.userInteractionEnabled = false
            
            // EVENT EXPLANATION
        case Sections.explanation.rawValue:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.setAttributedTextWithTags(self.house.currentEvent.currentStage!.explanation, isAnimated: false)
            for item in self.house.currentEvent.currentStage!.items {
                if item.hidden == false {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + item.explanation
                    for detail in item.details {
                        if detail.isFollowingTheRules() {
                            string = string! + " " + detail.explanation
                        }
                    }
                    cell.textLabel!.setAttributedTextWithTags(string!, isAnimated: false)
                }
            }
            cell.userInteractionEnabled = false
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            let action = self.house.currentEvent.currentStage!.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name, isAnimated: false)
            cell.userInteractionEnabled = true
            
            // ITEM ACTIONS
        default:
            // -3 to deal with the other table sections.
            let item = self.house.currentEvent.currentStage!.items[indexPath.section-indexPath.section]
            let action = item.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name, isAnimated: false)
            cell.userInteractionEnabled = true
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var action = Action?()
        
        switch ( indexPath.section ) {
            
            // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            print("room action selected")
            action = self.house.currentEvent.currentStage!.actions[indexPath.row]
            resolveAction(action!, isItemAction: false)
            
            // ITEM ACTIONS
        default:
            print("item action selected")
            action = self.house.currentEvent.currentStage!.items[indexPath.section-indexPath.section].actions[indexPath.row]
            resolveAction(action!, isItemAction: true)
            
            break
        }
        print("row \(indexPath.row) in section \(indexPath.section) selected")
        
        // self.tableView.reloadData()
        print("number of sections is \(tableView.numberOfSections)")
        
        if let _ = action?.triggerEventName {
            
        } else {
            
            if let actionName = action?.name {
                if actionName.rangeOfString("Take") != nil {
                    print("JAJAJAJA")
                    print("animating table changes (TAKE action")
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections-1))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Automatic)
                } else {
                    print("GAGAGAGA")
                    print("animating table changes")
                    let sections = NSIndexSet(indexesInRange: NSMakeRange(0, tableView.numberOfSections))
                    self.tableView.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
        }
        
        
        
        self.house.skull.updateSkull()
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
            let item = self.house.currentEvent.currentStage!.items[indexPath.section-indexPath.section]
            if item.hidden == true {
                print("\(item.name) IS HIDDEN!")
                height = 0
            }
            if item.actions[indexPath.row].name.rangeOfString("Take") != nil && item.canCarry == false {
                height = 0
            }
            if item.actions[indexPath.row].isFollowingTheRules() == false {
                print("\(item.actions[indexPath.row].name) is not following the rules")
                height = 0
            }
            
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
