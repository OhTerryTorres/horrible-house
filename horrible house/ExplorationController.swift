//
//  ExplorationController.swift
//  horrible house
//
//  Created by TerryTorres on 3/9/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit



class ExplorationController: UITableViewController {
    
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
    
    
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    var update = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make it so the player AUTOMATICALLY starts at the same position as the Foyer.
        setPlayerStartingRoom()
        
        self.title = self.house.currentRoom.name
        
        
    }

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
        self.house.currentRoom = room
        self.update = ""
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
            rows = self.house.currentRoom.items.count
            print("rows for ITEMS is \(rows)")
        case Sections.actions.rawValue:
            rows = self.house.currentRoom.numberOfActionsThatFollowTheRules()
            print("rows for ACTIONS is \(rows)")
        case Sections.directions.rawValue:
            rows = self.house.getRoomsAroundPlayer().count
            print("rows for DIRECTIONS is \(rows)")
        default:
            break;
        }
        return rows
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
            cell.textLabel!.text = self.house.currentRoom.explanation
            for detail in self.house.currentRoom.details {
                if detail.isFollowingTheRules() {
                    cell.textLabel!.text = "\(self.house.currentRoom.explanation) \(detail.explanation)"
                }
            }
            cell.userInteractionEnabled = false
        case Sections.items.rawValue:
            let item = self.house.currentRoom.items[indexPath.row]
            cell.textLabel!.text = "Take \(item.name)"
            cell.userInteractionEnabled = true
        case Sections.actions.rawValue:
            let action = self.house.currentRoom.actions[indexPath.row]
            cell.textLabel!.text = action.name
            cell.userInteractionEnabled = true
        case Sections.directions.rawValue:
            let room = self.house.getRoomsAroundPlayer()[indexPath.row]
            switch self.house.directionForRoom(room) {
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
            let item = self.house.currentRoom.items[indexPath.row]
            self.house.player.addItemToItems(item)
            self.house.currentRoom.removeItemFromItems(withName:item.name)
            self.update = "Got \(item)"
        case Sections.actions.rawValue:
            resolveAction(self.house.currentRoom.actions[indexPath.row])
        case Sections.directions.rawValue:
            resolveDirection(forIndexPath: indexPath)
            self.update = ""
            self.title = self.house.currentRoom.name
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    
    func resolveAction(action: Action) {
        action.timesPerformed++
        if let result = action.result { self.update = result }
        if let roomChange = action.roomChange { self.house.currentRoom.explanation = roomChange }
        for item in action.items {
            self.house.currentRoom.items.append(item)
            action.onceOnly = true
        }
        
        for var i = 0; i < self.house.currentRoom.actions.count; i++ {
            if self.house.currentRoom.actions[i].name == action.name {
                self.house.currentRoom.actions[i].timesPerformed += 1
                if let replaceAction = action.replaceAction {
                    self.house.currentRoom.actions[i] = replaceAction
                }
                if action.onceOnly == true {
                    self.house.currentRoom.actions.removeAtIndex(i)
                }
            }
        }
        
        if let triggerEventName = action.triggerEventName { triggerEvent(forEventName: triggerEventName)}
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
                    performSegueWithIdentifier("event", sender: event)
                }
            }
        }
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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "event" {
            let ec = segue.destinationViewController as! EventController
            ec.house = self.house
            ec.house?.currentEvent = sender as! Event
        }
        
        
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = UITableViewAutomaticDimension
        if self.house.currentRoom.actions[indexPath.row].isFollowingTheRules() == false {
            height = 0
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
