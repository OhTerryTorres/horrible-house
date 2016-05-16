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
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    var update = ""
    

    //
    // This can be changed so the starting room could potentially be a saved room from a previous session.
    //
    func setPlayerStartingRoom() {
        var room = Room?()
        room = self.house.foyer
        room?.timesEntered++
        self.house.currentRoom = room!
        self.house.player.position = self.house.currentRoom.position
        
    }
    
    
    
    
    
    func resolveAction(action: Action, isItemAction: Bool) {
        if let result = action.result { self.update = self.translateSpecialText(result) }
        if let roomChange = action.roomChange { self.house.currentRoom.explanation = roomChange }
        
        for itemName in action.revealItems {
            for item in self.house.currentRoom.items {
                if item.name == itemName {
                    item.hidden = false
                }
            }
        }
        for itemName in action.liberateItems {
            for item in self.house.currentRoom.items {
                if item.name == itemName {
                    item.canCarry = true
                }
            }
        }
        
        if isItemAction {
            for var i = 0; i < self.house.currentRoom.items.count; i++ {
                for var o = 0; o < self.house.currentRoom.items[i].actions.count; o++ {
                    if self.house.currentRoom.items[i].actions[o].name == action.name {
                        self.house.currentRoom.items[i].actions[o].timesPerformed += 1
                        
                        // If the action has a REPLACE action
                        if let replaceAction = action.replaceAction {
                            self.house.currentRoom.items[i].actions[o] = replaceAction
                        }
                        
                        // If the action can only be performed ONCE
                        if action.onceOnly == true {
                            self.house.currentRoom.items[i].actions.removeAtIndex(o)
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
            }
        } else { // Room Actions
            for var i = 0; i < self.house.currentRoom.actions.count; i++ {
                if self.house.currentRoom.actions[i].name == action.name {
                    action.timesPerformed += 1
                    if let replaceAction = action.replaceAction {
                        self.house.currentRoom.actions[i] = replaceAction
                    }
                    if action.onceOnly == true {
                        self.house.currentRoom.actions.removeAtIndex(i)
                    }
                    break
                }
            }
        }
        
        // This should be done before any transitions occur
        self.handleContextSensitiveActions(action, isItemAction: isItemAction)
        
        if let triggerEventName = action.triggerEventName { triggerEvent(forEventName: triggerEventName)}
        
        if let segue = action.segue { performSegueWithIdentifier(segue, sender: action)}
        
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
    
    func triggerEvent(forEventName eventName: String) {
        for event in self.house.events {
            if event.name == eventName {
                if event.isFollowingTheRules() {
                    print("moving to event \(event.name)")
                    performSegueWithIdentifier("event", sender: event)
                }
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("leaving EXPLORATION CONTROLLER")
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            let ec = segue.destinationViewController as! EventController
            ec.house = self.house
            ec.house.currentEvent = sender as! Event
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
        
        
    }
    
    
    // MARK: View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.update = ""
        self.tableView.reloadData()
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
    
    
    
    
    
    
    // MARK: Tableview Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return getNumberOfTableSections()
    }
    
    func getNumberOfTableSections() -> Int {
        var numberOfSections = 4
        for _ in self.house.currentRoom.items {
            numberOfSections++
        }
        return numberOfSections
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
            rows = self.house.getRoomsAroundPlayer().count
            
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
        
        // Configure the cell...
        switch ( indexPath.section ) {
            
            // UPDATE
        case 0:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.setAttributedTextWithTags(self.update)
            cell.userInteractionEnabled = false
            
            // ROOM EXPLANATION
        case 1:
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel!.setAttributedTextWithTags(self.house.currentRoom.explanation)
            for detail in self.house.currentRoom.details {
                if detail.isFollowingTheRules() {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + detail.explanation
                    cell.textLabel!.setAttributedTextWithTags(string!)
                }
            }
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
            cell.userInteractionEnabled = false
            // ROOM ACTIONS
        case 2:
            let action = self.house.currentRoom.actions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(action.name)
            cell.userInteractionEnabled = true
            
            // DIRECTIONS
        case getNumberOfTableSections()-1:
            let room = self.house.getRoomsAroundPlayer()[indexPath.row]
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
        switch ( indexPath.section ) {
            
            // ROOM ACTIONS
        case 2:
            resolveAction(self.house.currentRoom.actions[indexPath.row], isItemAction: false)
            
            // DIRECTIONS
        case getNumberOfTableSections()-1:
            resolveDirection(forIndexPath: indexPath)
            self.update = ""
            self.title = self.house.currentRoom.name
            
            // ITEM ACTIONS
        default:
            resolveAction(self.house.currentRoom.items[indexPath.section-3].actions[indexPath.row], isItemAction: true)
            
            break
        }
        self.tableView.reloadData()
        self.house.skull.updateSkull()
        self.house.gameClock.passTimeByTurn()
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
