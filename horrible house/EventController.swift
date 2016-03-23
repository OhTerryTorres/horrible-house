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
        case items = 2
        case actions = 3
        case numberOfSections = 4
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
    
    var house = House?()
    var event = Event?()
    var currentStage = Stage()
    var update = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make it so the player AUTOMATICALLY starts at the same position as the Foyer.
        self.setCurrentStage()
        self.navigationItem.setHidesBackButton(true, animated:false);
        self.title = self.currentStage.name
        
        
        
    }
    
    func setCurrentStage() {
        if let stages = self.event?.stages {
            for stage in stages {
                if self.areRulesBeingFollowedForObject(stage) {
                    self.currentStage = stage
                }
            }
        }
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
            rows = (self.currentStage.items?.count)!
        case Sections.actions.rawValue:
            self.currentStage.actionsToDisplay = removeActionsThatAreNotFollowingTheRules(self.currentStage.actions!)
            rows = self.currentStage.actionsToDisplay!.count
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
    
    
    // I want to get rid of this function, but it screws with areRulesBeingFollowedForObject.
    // AnyObjects... Go figure.
    
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
                    if let _ = house!.player.items!.indexOf({$0.name == rule.name}) {
                        followed = true
                        print("YAYAYAYAYAYAYA")
                    }
                    
                case Rule.RuleType.nopeHasItem:
                    print("nopeHasItem??")
                    followed = true
                    if let _ = house!.player.items!.indexOf({$0.name == rule.name}) {
                        followed = false
                        print("YOYOYOYOYOYOYO")
                    }
                    
                case Rule.RuleType.metCharacter:
                    break
                case Rule.RuleType.nopeMetCharacter:
                    break
                case Rule.RuleType.enteredRoom:
                    var i = 0; for room in house!.rooms {
                        if room.timesEntered > 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.nopeEnteredRoom:
                    var i = 0; for room in house!.rooms {
                        if room.timesEntered == 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.completedEvent:
                    break
                case Rule.RuleType.nopeCompletedEvent:
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
        if let rules = object.rules as [Rule]? {
            for rule in rules {
                print("rule.name is \(rule.name)")
                print("rule.type is \(rule.type)")
                switch ( rule.type) {
                    
                case Rule.RuleType.hasItem:
                    print("hasItem??")
                    followed = false
                    if let _ = house!.player.items!.indexOf({$0.name == rule.name}) {
                        followed = true
                        print("\(rule.name) is present! So the rule is being followed.")
                    }
                    
                case Rule.RuleType.nopeHasItem:
                    print("nopeHasItem??")
                    followed = true
                    if let _ = house!.player.items!.indexOf({$0.name == rule.name}) {
                        followed = false
                        print("\(rule.name) is NOT present! So the rule is being followed.")
                    }
                    
                case Rule.RuleType.metCharacter:
                    break
                case Rule.RuleType.nopeMetCharacter:
                    break
                case Rule.RuleType.enteredRoom:
                    var i = 0; for room in house!.rooms {
                        if room.timesEntered > 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.nopeEnteredRoom:
                    var i = 0; for room in house!.rooms {
                        if room.timesEntered == 0 { i++ }
                    }; if i == 0 { followed = false }
                case Rule.RuleType.completedEvent:
                    break
                case Rule.RuleType.nopeCompletedEvent:
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
            cell.textLabel!.text = self.currentStage.explanation
            cell.userInteractionEnabled = false
        case Sections.items.rawValue:
            let item = self.currentStage.items![indexPath.row]
            cell.textLabel!.text = "Take \(item.name)"
            cell.userInteractionEnabled = true
        case Sections.actions.rawValue:
            let action = self.currentStage.actionsToDisplay![indexPath.row]
            cell.textLabel!.text = action.name
            cell.userInteractionEnabled = true
        default:
            break;
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch ( indexPath.section ) {
        case Sections.items.rawValue:
            addItemToInventory(self.currentStage.items![indexPath.row])
        case Sections.actions.rawValue:
            resolveAction(self.currentStage.actionsToDisplay![indexPath.row])
        default:
            break
        }
    }
    
    
    func resolveAction(action: Action) {
        
        action.timesPerformed++
        if let result = action.result { self.update = result }
        if let roomChange = action.roomChange { self.currentStage.explanation = roomChange }
        if let items = action.items {
            for item in items {
                if self.currentStage.items != nil { self.currentStage.items?.append(item) }
                else { self.currentStage.items = [item] }
                action.canPerformMoreThanOnce = false
            }
        }
        
        for var i = 0; i < self.currentStage.actions?.count; i++ {
            if self.currentStage.actions![i].name == action.name {
                self.currentStage.actions![i].timesPerformed += 1
                if let replaceAction = action.replaceAction {
                    self.currentStage.actions![i] = replaceAction
                }
                if action.canPerformMoreThanOnce == false {
                    self.currentStage.actions?.removeAtIndex(i)
                }
            }
        }
        
        if let triggerEvent = action.triggerEvent {
            if triggerEvent.name == "" {
                performSegueWithIdentifier("exit", sender: nil)
            } else {
                self.event = triggerEvent
                self.setCurrentStage()
            }
        }
        
        print("explanation is \(self.currentStage.explanation)")
        
        self.tableView.reloadData()
    }
    
    
    
    func addItemToInventory(item: Item) {
        if self.house!.player.items != nil { self.house!.player.items?.append(item) }
        else { self.house!.player.items = [item] }
        for var i = 0; i < self.currentStage.items?.count; i++ {
            if self.currentStage.items![i].name == item.name { self.currentStage.items?.removeAtIndex(i) }
        }
        self.update = "Got \(item.name)."
        
        print("\rItems in player's inventory:")
        for i in self.house!.player.items! {
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
