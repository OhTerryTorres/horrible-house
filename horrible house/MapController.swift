//
//  MapController.swift
//  horrible house
//
//  Created by TerryTorres on 4/7/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import Foundation
import UIKit

class MapController: UIViewController {
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    
    var widthByRooms : CGFloat {
        return CGFloat(house.width)
    }
    var heightByRooms : CGFloat {
        return CGFloat(house.width)
    }
    
    var currentFloor = 0
    
    @IBOutlet var mapDisplayView: UIView!
    @IBOutlet var roomNameLabel: UILabel!
    @IBOutlet var roomNameBar: UIToolbar!
    
    override func viewDidLoad() {
        self.title = "Map"
        self.tabBarItem = UITabBarItem(title: "Map", image: nil, tag: 2)
                
        self.mapDisplayView.frame.size.width = self.view.frame.width + (self.view.frame.width * 0.02)
        self.mapDisplayView.frame.size.height = self.view.frame.height
        
        
        // tabBarHeight might need adjusting often as the map screen is tweaked.
        
        let tabBarHeight = self.roomNameBar.frame.height + self.roomNameBar.frame.height
        self.mapDisplayView.frame.size.height -= tabBarHeight
        self.mapDisplayView.frame.size.height -= tabBarHeight * 0.8
        
        self.roomNameBar.translucent = false
        self.roomNameBar.barTintColor = Color.backgroundColor
        
        self.currentFloor = self.house.player.position.z
        self.setFloorButton()
        
        
    }
    
    func setFloorButton() {
        var string = ""
        switch (self.currentFloor) {
        case 0:
            string = "B"
        case 1:
            string = "1"
        case 2:
            string = "2"
        default:
            break
        }
        
        let changeFloorButton = UIBarButtonItem(title: string, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MapController.changeFloor))
        navigationItem.rightBarButtonItem = changeFloorButton
    }
    
    override func viewWillAppear(animated: Bool) {
        print("VIEWWILLAPPEAR")
        self.currentFloor = self.house.player.position.z
        self.setFloorButton()
        self.displayMap()
    }
    override func viewWillDisappear(animated: Bool) {
        print("VIEWWILLDISAPPEAR")
        self.roomNameBar.hidden = true
    }
    
    func displayMap() {
        for view in self.mapDisplayView.subviews {
            view.removeFromSuperview()
        }
        
        let width = self.mapDisplayView.frame.size.width
        let height = self.mapDisplayView.frame.size.height
        
        let roomWidth = width / CGFloat(widthByRooms)
        let roomHeight = height / CGFloat(heightByRooms)
        
        print("heightByRooms is \(heightByRooms)")
        print("widthByRooms is \(widthByRooms)")
        
        
        
        for y in heightByRooms.stride(to: -1, by: -1) {
            print("y is \(y)")
            for x in widthByRooms.stride(to: -1, by: -1) {
                print("x is \(x)")
                let roomView = UIView()
                roomView.frame = CGRectMake(
                    x * roomWidth,
                    y * roomHeight,
                    roomWidth ,
                    roomHeight
                )
                
                let room = house.roomForPosition((x:Int(x), y:Int(y), z:self.currentFloor))
                
                if room!.name != "No Room" {
                    print("\(room!.name)")
                    roomView.backgroundColor = UIColor.blackColor()
                    
                    if room?.timesEntered > 0 {
                        
                        let roomDetailView = UIView()
                        let detailX = CGFloat(roomWidth * 0.125)
                        let detailY = CGFloat(roomHeight * 0.125)
                        let detailWidth = CGFloat(roomWidth * 0.75)
                        let detailHeight = CGFloat(roomHeight * 0.75)
                        roomDetailView.frame = CGRectMake(
                            detailX,
                            detailY,
                            detailWidth,
                            detailHeight
                        )
                        
                        if let index = self.house.player.roomHistory.indexOf({$0 == room?.name}) {
                            if index == 0 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor
                            }
                            if index == 1 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor.colorWithAlphaComponent(0.6)
                            }
                            if index == 2 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor.colorWithAlphaComponent(0.3)
                            }
                        } else {
                            roomDetailView.backgroundColor = UIColor.darkGrayColor()
                        }
                        
                        
                        roomView.addSubview(roomDetailView)
                        
                        roomView.transform = CGAffineTransformMakeScale(1, -1)
                        
                        
                        // MARK: *** Map Button stuff??
                        
                        
                        let roomButton = SuperButton(type: UIButtonType.Custom) as SuperButton
                        roomButton.qualifier = room!.name
                        
                        let buttonX = CGFloat(roomWidth * 0.125)
                        let buttonY = CGFloat(roomHeight * 0.125)
                        let buttonWidth = CGFloat(roomWidth * 0.75)
                        let buttonHeight = CGFloat(roomHeight * 0.75)
                        roomButton.frame = CGRectMake(
                            buttonX,
                            buttonY,
                            buttonWidth,
                            buttonHeight
                        )
                        
                        roomButton.titleLabel?.text = room!.name
                        
                        roomButton.addTarget(self, action: #selector(MapController.displayRoomInfo(_:)), forControlEvents:.TouchDown)
                        
                        roomButton.showsTouchWhenHighlighted = true
                        
                        roomView.addSubview(roomButton)
                    }
                    
                } else { roomView.backgroundColor = UIColor.darkGrayColor() }
                
                self.mapDisplayView.addSubview(roomView)
                
                // Flips map upside down, to match the house layout.
                self.mapDisplayView.transform = CGAffineTransformMakeScale(1, -1)
            }
        }
    }

    
    func displayRoomInfo(sender: SuperButton) {
        print("\(sender.qualifier)")
        
        //
        
        // Set up room name display
        
        self.roomNameBar.items = []
        
        let nameItem = UIBarButtonItem()
        nameItem.title = sender.qualifier
        nameItem.tintColor = UIColor.blackColor()
        self.roomNameBar.items! += [nameItem]
        
        
        // Icon for PLAYER
        if self.house.currentRoom.name == sender.qualifier {
            let iconItem = UIBarButtonItem()
            iconItem.title = "🙋"
            self.roomNameBar.items! += [iconItem]
        }
        
        // Icon for NPC
        if self.house.roomForName(sender.qualifier)?.characters.count > 0 || self.house.necessaryRooms[sender.qualifier]?.characters.count > 0 {
            let iconItem = UIBarButtonItem()
            iconItem.title = "🐙"
            self.roomNameBar.items! += [iconItem]
        }

        
        self.roomNameBar.hidden = false
        
    }
    
    func changeFloor() {
        self.currentFloor += 1
        if self.currentFloor > 2 {
            self.currentFloor = 0
        }
        
        self.setFloorButton()
        
        self.displayMap()
    }
    
    
}