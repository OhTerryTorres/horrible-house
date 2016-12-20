//
//  GameControllerProtocol.swift
//  horrible house
//
//  Created by TerryTorres on 8/18/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit


enum GameMode : String { // This is set on the initialization of the different GameController subclasses.
    case Exploration, Event
}

enum TabIndex : Int {
    case house = 0
    case inventory = 1
    case map = 2
    case clock = 3
    case skull = 4
}

enum Sections : Int {
    case update = 0
    case explanation = 1
    case roomActions = 2
    case inventoryActions
    case ItemActions
    // Each item has its own section
    // In switch cases, they will count as Default
    case numberOfDefaultSections = 5 // This includes every section BUT Item actions, which vary each time.
    
}

class GameController : UITableViewController {
    var house = House()
    var update = ""
    var itemCount = 0
    var gameMode = GameMode.Event // *** Subclasses MUST override this property properly. ***
    var isInventoryEvent = false
    
    
    let sectionOffset = 3 // This is the number of sections that appear BEFORE the variable ones. Currently: update, explanation & roomActions.
    
   
    
    
    
    func triggerEvent( triggerEvent:(eventName: String, stageName: String?) ) {
        if let index = self.house.events.index(where:
            
            { $0.name == triggerEvent.eventName }) {
            if self.house.events[index].isFollowingTheRules() {
                switch gameMode {
                case .Exploration:
                    var dict = ["eventName" : triggerEvent.eventName]
                    if let stageName = triggerEvent.stageName {
                        dict = ["eventName" : triggerEvent.eventName, "stageName" : stageName]
                    }
                    performSegue(withIdentifier: "event", sender: dict as AnyObject)
                case .Event:
                    self.house.currentEvent = self.house.events[index]
                    self.house.currentEvent.currentStage = self.house.currentEvent.stages[0]
                    if let stageName = triggerEvent.stageName {
                        if let i = self.house.currentEvent.stages.index(where: { $0.name == stageName }) {
                            self.house.currentEvent.currentStage = self.house.currentEvent.stages[i]
                        }
                    }
                }
            }
        }
        if triggerEvent.eventName == "" {
            if self.isInventoryEvent {
                performSegue(withIdentifier: "exitToInventory", sender: nil)
            } else {
                performSegue(withIdentifier: "exit", sender: nil)
            }
        }
    }
    
    func suddenEventDoesOccur() -> Bool {
        var bool = false
        if let eventName = self.house.getViableSuddenEventName() {
            if eventName != "" {
                self.triggerEvent( triggerEvent: (eventName: eventName, nil ) )
                bool = true
            }
        }
        return bool
    }
    
    
    func handleTransitionsForAction(action: Action) {
        // Resets the house from the mirror
        if action.name.lowercased().range(of: "it was different") != nil {
            // Nullify the current house data
            UserDefaults.standard.removeObject(forKey: "mapData")
            UserDefaults.standard.removeObject(forKey: "roomsData")
            UserDefaults.standard.removeObject(forKey: "necessaryRoomsData")
            UserDefaults.standard.synchronize()
            self.house = House(layout: House.LayoutOptions.a)
            self.house.gameClock.startTimer()
        }
        
        if let triggerEvent = action.triggerEvent {
            self.triggerEvent(triggerEvent: triggerEvent)
        }
        
        if let segue = action.segue {
            performSegue(withIdentifier: segue.identifier, sender: action)
        }
        
        
        if let _ = action.moveCharacter {
            self.update = ""
            
        }
        
        
    }
    
    
    
    
    func getMoveAction(forIndexPath indexPath: IndexPath) -> Action {
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        let direction = self.house.directionForString(string: (currentCell.textLabel?.text?.lowercased())!)
        var room = Room()
        
        switch direction {
        case .North:
            room = self.house.roomInDirection(direction: House.Direction.North, fromPosition: self.house.player.position)!
        case .West:
            room = self.house.roomInDirection(direction: House.Direction.West, fromPosition: self.house.player.position)!
        case .South:
            room = self.house.roomInDirection(direction: House.Direction.South, fromPosition: self.house.player.position)!
        case .East:
            room = self.house.roomInDirection(direction: House.Direction.East, fromPosition: self.house.player.position)!
        case.Upstairs:
            room = self.house.roomInDirection(direction: House.Direction.Upstairs, fromPosition: self.house.player.position)!
        case.Downstairs:
            room = self.house.roomInDirection(direction: House.Direction.Downstairs, fromPosition: self.house.player.position)!
        default:
            room = self.house.currentRoom
        }
        
        
        let action = Action()
        action.result = ""
        action.moveCharacter = (self.house.player.name, room.name, nil)
        return action
    }

    
    func endTurn() {
        self.house.skull.updateSkull()
        if self.house.gameClock.reachedEndTime && self.house.gameClock.didClockChime == false {
            self.clockChime()
        }
        if self.gameMode == GameMode.Exploration {
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.refreshViewControllers()
            }
            
            self.house.gameClock.turnsPassed += 1
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
    
    
    
    // MARK: Tableview Functions
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var string : String?
        switch ( section ) {
        // UPDATE
        case Sections.update.rawValue:
            if self.update != "" {
                string = "UPDATE"
            } else { string = nil }
            
        // ROOM EXPLANATION
        case Sections.explanation.rawValue:
            string = nil
            
        // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            switch gameMode {
            case .Exploration:
                if self.house.currentRoom.actions.count == 0 && self.itemCount == 0 {
                    string = nil
                } else { string = "ACT" }
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    string = "ACT"
                    if currentStage.actions.count == 0 && self.itemCount == 0 {
                        string = nil
                    }
                } else if self.itemCount == 0 { string = nil }
                else { string = "ACT" }
            }
            
            
        // DIRECTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-1:
            if gameMode == GameMode.Event {
                string = nil
            } else { string = "MOVE" }
            
            
        // ITEM ACTIONS
        default:
            string = nil
        }
        
        return string
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            switch gameMode {
            case .Exploration:
                rows = self.house.currentRoom.actions.count
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    rows = currentStage.actions.count
                } else { rows = 0 }
                
            }
            
            
        // DIRECTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-1:
            switch gameMode {
            case .Exploration:
                rows = self.house.getRoomsAroundCharacter(character: self.house.player).count
            case .Event:
                rows = 0
            }
            
        // INVENTORY ACTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-2:
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        rows += 1
                    }
                }
            }
            
        // ITEM ACTIONS
        default:
            // Sections.offset.rawValue to deal with the other table sections.
            switch gameMode {
            case .Exploration:
                if self.house.currentRoom.items.count > 0 {
                    let item = self.house.currentRoom.items[section-sectionOffset]
                    rows = item.actions.count
                }
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    if currentStage.items.count > 0 {
                        let item = currentStage.items[section-sectionOffset]
                        rows = item.actions.count
                    }
                } else { rows = 0 }
                
            }
            
            
        }

        return rows
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.setStyle()
        
        cell.textLabel!.numberOfLines = 0
        
        // Configure the cell...
        switch ( indexPath.section ) {
            
        // UPDATE
        case Sections.update.rawValue:
            cell.textLabel!.setAttributedTextWithTags(string: self.update)
            cell.textLabel!.baselineAdjustment = UIBaselineAdjustment.alignBaselines
            cell.isUserInteractionEnabled = false
            
        // ROOM EXPLANATION
        case Sections.explanation.rawValue:
            var items : [Item] = []
            
            switch gameMode {
            case .Exploration:
                cell.textLabel!.setAttributedTextWithTags(string: self.house.currentRoom.explanation)
                for detail in self.house.currentRoom.details {
                    if detail.isFollowingTheRules() {
                        var string = cell.textLabel?.attributedText?.string
                        if string == "" { string = detail.explanation }
                        else { string = string! + " " + detail.explanation }
                        cell.textLabel!.setAttributedTextWithTags(string: string!)
                    }
                }
                items = self.house.currentRoom.items
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    print("currentStage.explanation is \(currentStage.explanation)")
                    cell.textLabel!.setAttributedTextWithTags(string: currentStage.explanation)
                    items = currentStage.items
                }
                
            }
            
            
            // Adds each item's "explanation" property to the room explanation.
            for item in items {
                if item.hidden == false {
                    var string = cell.textLabel?.attributedText?.string
                    string = string! + " " + item.explanation
                    for detail in item.details {
                        if detail.isFollowingTheRules() {
                            string = string! + " " + detail.explanation
                        }
                    }
                    cell.textLabel!.setAttributedTextWithTags(string: string!)
                }
            }
            
            switch gameMode {
            case .Exploration:
                // Adds each non-hidden character's "explanation" property to the room explanation.
                for character in self.house.currentRoom.characters {
                    if character.hidden == false && character.name != "Player" {
                        var string = cell.textLabel?.attributedText?.string
                        string = string! + " " + character.explanation
                        cell.textLabel!.setAttributedTextWithTags(string: string!)
                    }
                }
            case .Event:
                break
            }
            
            cell.isUserInteractionEnabled = false
            
        // ROOM ACTIONS
        case Sections.roomActions.rawValue:
            var action = Action()
            switch gameMode {
            case .Exploration:
                action = self.house.currentRoom.actions[indexPath.row]
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    action = currentStage.actions[indexPath.row]
                }
            }
            cell.textLabel!.setAttributedTextWithTags(string: action.name)
            cell.isUserInteractionEnabled = true
            
        // DIRECTIONS
            
            // This should only display in the Exploration controller
            // as only Event controller shouldn't even display
            // any rows
            
        case getNumberOfTableSections(forNumberOfItems: itemCount)-1:
            let room = self.house.getRoomsAroundCharacter(character: self.house.player)[indexPath.row]
            var directionString = ""
            switch self.house.directionForRoom(roomA: room, fromRoom: self.house.currentRoom) {
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
            case .Upstairs:
                if room.timesEntered > 0 {
                    directionString = "Go upstairs to {[room]\(room.name)}"
                } else { directionString = "Go upstairs" }
            case .Downstairs:
                if room.timesEntered > 0 {
                    directionString = "Go downstairs to {[room]\(room.name)}"
                } else { directionString = "Go downstairs" }
            case .Default:
                directionString = "Go nowhere"
            }
            cell.textLabel!.setAttributedTextWithTags(string: directionString)
            cell.isUserInteractionEnabled = true
            
        // INVENTORY ACTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-2:
            
            var inventoryActions : [Action] = []
            for item in self.house.player.items {
                for action in item.actions {
                    if action.isFollowingTheRules() {
                        inventoryActions += [action]
                    }
                }
            }
            let action = inventoryActions[indexPath.row]
            cell.textLabel!.setAttributedTextWithTags(string: action.name)
            cell.isUserInteractionEnabled = true
            
            
        // ITEM ACTIONS
        default:
            // Sections.offset.rawValue to deal with the other table sections.
            var item = Item()
            switch gameMode {
            case .Exploration:
                item = self.house.currentRoom.items[indexPath.section-sectionOffset]
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    item = currentStage.items[indexPath.section-sectionOffset]
                }
                
            }
            if item.actions.count > 0 {
                let action = item.actions[indexPath.row]
                cell.textLabel!.setAttributedTextWithTags(string: action.name)
            }
            
            
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        var bool = false
        
        switch gameMode {
        case .Exploration:
            bool = suddenEventDoesOccur()
        case .Event:
            break
        }
        
        if bool == false {
            
            
            //***
            // EXECUTING NPC ACTIONS
            //***
            // NPCs move just before the player does, technically,
            // but it's basically "at the same time"
            
            switch gameMode {
            case .Exploration:
                self.house.triggerNPCBehaviors()
            case .Event:
                break
            }
            
            
            //***
            // SETTING UP PLAYER ACTION
            //***
            
            var action : Action?
            var actionType = Action.ActionType.Room
            var resolutionType = Action.ResolutionType.Exploration
            
            switch ( indexPath.section ) {
                
            // ROOM ACTIONS
            case Sections.roomActions.rawValue:
                actionType = Action.ActionType.Room
                switch gameMode {
                case .Exploration:
                    action = self.house.currentRoom.actions[indexPath.row]
                    resolutionType = Action.ResolutionType.Exploration
                    
                case .Event:
                    if let currentStage = self.house.currentEvent.currentStage {
                        action = currentStage.actions[indexPath.row]
                    }
                    resolutionType = Action.ResolutionType.Event
                }
                
            // DIRECTIONS
            case getNumberOfTableSections(forNumberOfItems: itemCount)-1:
                
                action = getMoveAction(forIndexPath: indexPath)
                resolutionType = Action.ResolutionType.Exploration
                
                
            // INVENTORY ACTIONS
            case getNumberOfTableSections(forNumberOfItems: itemCount)-2:
                actionType = Action.ActionType.Inventory
                var inventoryActions : [Action] = []
                for item in self.house.player.items {
                    for action in item.actions {
                        if action.isFollowingTheRules() {
                            inventoryActions += [action]
                        }
                    }
                }
                if inventoryActions.count > indexPath.row {
                    action = inventoryActions[indexPath.row]
                    switch gameMode {
                    case .Exploration:
                        resolutionType = Action.ResolutionType.Exploration
                    case .Event:
                        resolutionType = Action.ResolutionType.Event
                    }
                }
                
                
            // ITEM ACTIONS
            default:
                actionType = Action.ActionType.Item
                switch gameMode {
                case .Exploration:
                    action = self.house.currentRoom.items[indexPath.section-sectionOffset].actions[indexPath.row]
                    resolutionType = Action.ResolutionType.Exploration
                case .Event:
                    if let currentStage = self.house.currentEvent.currentStage {
                        action = currentStage.items[indexPath.section-sectionOffset].actions[indexPath.row]
                    }
                    resolutionType = Action.ResolutionType.Event
                }
            }
            
            
            
            //***
            // ADDING PLAYER ACTION SET TO PIPELINE
            //***
            
            self.house.pipeline.insert((action!, actionType, self.house.player, self.house.currentRoom, self.house.currentEvent.currentStage, resolutionType), at: 0)
            
            
            //self.house.executeAction(action!, ofActionType: actionType, forCharacter: self.house.player, inRoom: self.house.currentRoom, orInStage: self.house.currentEvent.currentStage, withResolutionType: resolutionType)
            self.handleTransitionsForAction(action: action!)
            
            
            // This resolves action properties particular to GameController
            if let a = action {
                // SHOW UPDATE
                if let result = a.result { self.update = self.translateSpecialText(string: result) }
                else { self.update = "" }
                
                // CHANGE ROOM EXPLANATION
                if let roomChange = a.roomChange {
                    switch gameMode {
                    case .Exploration:
                        self.house.currentRoom.explanation = roomChange
                    case .Event:
                        if let currentStage = self.house.currentEvent.currentStage {
                            currentStage.explanation = roomChange
                        }
                    }
                }
            }
            
            
            
            //***
            // QUEUEING ALL CHARACTER ACTIONS IN HOUSE
            // AND THEN EXECUTING THEM
            //***
            
            self.house.resolveActionsInPipeline()
            
            
            
            //***
            // PREPARATION FOR THE NEXT TURN
            //***
            // Everything that has to be done AFTER the player's action
            // but BEFORE the table reloads is done in END TURN
            self.endTurn()
            
            self.resetItemCount()
            self.tableView.reloadData()
            
            var sections = NSIndexSet(indexesIn: NSMakeRange(0, tableView.numberOfSections))
            var animation = UITableViewRowAnimation.fade
            
            
            // If action is merely shifiting an event to a new stage
            if let _ = action?.triggerEvent {
                if gameMode == GameMode.Event {
                    self.tableView.reloadSections(sections as IndexSet, with: animation)
                }
                
            } else if let _ = action?.segue {
            } else {
                
                if let actionName = action?.name {
                    if actionName.range(of: "Take") != nil {
                        // TAKE: In case of picking up an item, slide in UPDATE section saying so.
                        sections = NSMutableIndexSet(indexesIn: NSMakeRange(0, 1))
                        animation = UITableViewRowAnimation.left
                        
                    } else {
                        // In case of any other action, fade entire tableview
                        sections = NSIndexSet(indexesIn: NSMakeRange(0, tableView.numberOfSections))
                        
                    }
                } else {
                    // DIRECTION: in case of moving from one room to another, fade entire tablevew.
                    sections = NSIndexSet(indexesIn: NSMakeRange(0, tableView.numberOfSections))

                }
                
                self.tableView.reloadSections(sections as IndexSet, with: animation)
                
                
            }
            
            if gameMode == GameMode.Exploration {
                self.scrollToTop()
                self.title = self.house.currentRoom.name
            }
            
            
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
            var action = Action()
            switch gameMode {
            case .Exploration:
                action = self.house.currentRoom.actions[indexPath.row]
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    action = currentStage.actions[indexPath.row]
                }
                
            }
            if action.isFollowingTheRules() == false {
                height = 0
            }
            
        // DIRECTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-1:
            break
            
        // INVENTORY ACTIONS
        case getNumberOfTableSections(forNumberOfItems: itemCount)-2:
            break
            
        // ITEM ACTIONS
        default:
            // Sections.offset.rawValue to deal with the other table sections.
            var item = Item()
            switch gameMode {
            case .Exploration:
                item = self.house.currentRoom.items[indexPath.section-sectionOffset]
            case .Event:
                if let currentStage = self.house.currentEvent.currentStage {
                    item = currentStage.items[indexPath.section-sectionOffset]
                }
            }
            
            if item.hidden == true {
                height = 0
            }
            if item.actions[indexPath.row].name.range(of: "Take") != nil && item.canCarry == false {
                height = 0
            }
            if item.actions[indexPath.row].isFollowingTheRules() == false {
                height = 0
            }
        }
        
        return height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfTableSections(forNumberOfItems: self.itemCount)
    }
    
    func getNumberOfTableSections(forNumberOfItems itemCount:Int) -> Int {
        var numberOfSections = Sections.numberOfDefaultSections.rawValue
        for _ in 0 ..< itemCount {
            numberOfSections += 1
        }
        return numberOfSections
    }
    

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        var frame = header.frame
        frame.size.height = 10
        header.frame = frame
        
        header.textLabel!.font = Font.headerFont
        header.textLabel!.frame = header.frame
        
        header.backgroundView?.backgroundColor = Color.foregroundColor
        header.textLabel!.textColor = Color.backgroundColor
    }
    
    func scrollToTop() {
        if (self.numberOfSections(in: self.tableView) > 0 ) {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            // let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            if numberOfRows > 0 && numberOfSections > 0 {
                // self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }
            
            let top = IndexPath(row: Foundation.NSNotFound, section: 0);
            self.tableView.scrollToRow(at: top, at: UITableViewScrollPosition.top, animated: true);

        }
    }
    
    
    func resetItemCount() {
        switch gameMode {
        case .Exploration:
            self.itemCount = self.house.currentRoom.items.count
        case .Event:
            if let currentStage = self.house.currentEvent.currentStage {
                self.itemCount = currentStage.items.count
            } else { self.itemCount = 0 }
            
        }
    }
    
    
    // MARK: View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        self.house.gameClock.startTimer()
        
        self.tableView.setStyle()

        
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        
        switch gameMode {
        case .Exploration:
            self.tabBarItem = UITabBarItem(title: "House", image: nil, tag: 0)
            self.title = self.house.currentRoom.name
        case .Event:
            self.tabBarItem = UITabBarItem(title: "House", image: nil, tag: 0)
            self.title = self.house.currentEvent.name
        }
        
        self.scrollToTop()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        switch gameMode {
        case .Exploration:
            self.update = ""
            self.title = self.house.currentRoom.name
            
            resetItemCount()
            self.tableView.reloadData()
            
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.refreshViewControllers()
            }
        case .Event:
            resetItemCount()
            self.tableView.reloadData()
            if self.tabBarController?.tabBar.isHidden == false {
                self.tabBarController?.tabBar.isHidden = true
            }
        }
        
        

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        print("segue.identifier is \(segue.identifier)")
        
        switch gameMode {
        case .Exploration:
            break
        case .Event:
            self.house.currentEvent.completed = true
        }
        
        
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
        
        if segue.identifier == "event" {
            if let triggerEventDict = sender as? Dictionary<String, String> {
                self.house.currentEvent = self.house.eventForName(name: triggerEventDict["eventName"]!)!
                self.house.currentEvent.currentStage = self.house.currentEvent.getStageThatFollowsRulesFromStagesArray(stages: self.house.currentEvent.stages)
                if let stageName = triggerEventDict["stageName"] {
                    if let index = self.house.currentEvent.stages.index(where: {$0.name == stageName}) {
                        self.house.currentEvent.currentStage = self.house.currentEvent.stages[index]
                    }
                }
                
            let ec = segue.destination as! EventController
            ec.house = self.house
            
            }
            
        }
        if segue.identifier == "piano" {
            let pc = segue.destination as! PianoController
            pc.house = self.house
        }
        if segue.identifier == "container" {
            let cc = segue.destination as! ContainerController
            
            let action = sender as! Action
            var itemName = action.name.replacingOccurrences(of: "Look in {[item]", with: "")
            itemName = itemName.replacingOccurrences(of: "}", with: "")
            if let index = self.house.currentRoom.items.index(where: {$0.name == itemName}) {
                cc.container = self.house.currentRoom.items[index]
            }
            
            
        }
        
        if segue.identifier == "exit" {
            let ec = segue.destination as! ExplorationController
            ec.house = self.house
        }
        if segue.identifier == "exitToInventory" {
            let ic = segue.destination as! InventoryController
            ic.house = self.house
        }
        
        if segue.identifier == "gameOver" {
            let goc = segue.destination as! GameOverController
            let action = sender as! Action
            if let segue = action.segue {
                if let qualifier = segue.qualifier {
                    goc.message = qualifier
                }
            }
            
        }
        
        
    }
    
    
    // This deals with text that needs to be formatted to include game properties.
    // ex. The current time.
    func translateSpecialText(string: String) -> String {
        var string = string
        if (string.range(of: "[currentTime]") != nil) {
            if self.house.gameClock.currentTime.minutes < 10 {
                string = string.replacingOccurrences(of: "[currentTime]", with: "\(self.house.gameClock.currentTime.hours):0\(self.house.gameClock.currentTime.minutes) and \(self.house.gameClock.currentTime.seconds) seconds")
            } else {
                string = string.replacingOccurrences(of: "[currentTime]", with: "\(self.house.gameClock.currentTime.hours):\(self.house.gameClock.currentTime.minutes) and \(self.house.gameClock.currentTime.seconds) seconds")
            }
        }
        return string
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.tabBarController?.tabBar.isHidden == true {
            self.tabBarController?.tabBar.isHidden = false
        }
        (UIApplication.shared.delegate as! AppDelegate).house = self.house
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

