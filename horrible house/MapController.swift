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
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    
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
        
        self.roomNameBar.isTranslucent = false
        self.roomNameBar.barTintColor = Color.backgroundColor
        
        
        
        
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
        
        let changeFloorButton = UIBarButtonItem(title: string, style: UIBarButtonItemStyle.plain, target: self, action: #selector(changeFloor))
        navigationItem.rightBarButtonItem = changeFloorButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("VIEWWILLAPPEAR")
        self.house = (UIApplication.shared.delegate as! AppDelegate).house
        
        // tabBarHeight might need adjusting often as the map screen is tweaked.
        self.currentFloor = self.house.player.position.z
        self.setFloorButton()
        let tabBarHeight = self.roomNameBar.frame.height + self.roomNameBar.frame.height
        self.mapDisplayView.frame.size.width = self.view.frame.width + (self.view.frame.width * 0.02)
        self.mapDisplayView.frame.size.height = self.view.frame.height
        self.mapDisplayView.frame.size.height -= tabBarHeight
        self.mapDisplayView.frame.size.height -= tabBarHeight * 0.8
        
        self.displayMap()
    }
    override func viewWillDisappear(_ animated: Bool) {
        (UIApplication.shared
            .delegate as! AppDelegate).house = self.house
        print("VIEWWILLDISAPPEAR")
        self.roomNameBar.isHidden = true
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
        
        
        
        for y in stride(from: heightByRooms, to: -1, by: -1) {
            print("y is \(y)")
            for x in stride(from: widthByRooms, to: -1, by: -1) {
                print("x is \(x)")
                let roomView = UIView()
                roomView.frame = CGRect(
                    x: x * roomWidth,
                    y: y * roomHeight,
                    width: roomWidth ,
                    height: roomHeight
                )
                
                let room = house.roomForPosition(position: (x:Int(x), y:Int(y), z:self.currentFloor))
                
                //**********
                // failsafe
                // the foyer's timesEntered is 0 when the game starts for some reason
                // This just forces the issue.
                if room!.name == "Foyer" {
                    room!.timesEntered += 1
                }
                
                if room!.name != "No Room" {
                    print("\(room!.name)")
                    roomView.backgroundColor = UIColor.black
                    
                    if (room?.timesEntered)! > 0 {
                        
                        let roomDetailView = UIView()
                        let detailX = CGFloat(roomWidth * 0.125)
                        let detailY = CGFloat(roomHeight * 0.125)
                        let detailWidth = CGFloat(roomWidth * 0.75)
                        let detailHeight = CGFloat(roomHeight * 0.75)
                        roomDetailView.frame = CGRect(
                            x: detailX,
                            y: detailY,
                            width: detailWidth,
                            height: detailHeight
                        )

                        if let index = self.house.player.roomHistory.index(where: {$0 == room?.name}) {
                            if index == 0 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor
                            }
                            if index == 1 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor.withAlphaComponent(0.6)
                            }
                            if index == 2 {
                                roomDetailView.backgroundColor = Color.mapCurrentColor.withAlphaComponent(0.3)
                            }
                        } else {
                            roomDetailView.backgroundColor = UIColor.darkGray
                        }
                        
                        
                        roomView.addSubview(roomDetailView)
                        
                        roomView.transform = CGAffineTransform(scaleX: 1, y: -1)
                        
                        
                        // MARK: *** Map Button stuff??
                        
                        
                        let roomButton = SuperButton(type: UIButtonType.custom) as SuperButton
                        roomButton.qualifier = room!.name
                        
                        let buttonX = CGFloat(roomWidth * 0.125)
                        let buttonY = CGFloat(roomHeight * 0.125)
                        let buttonWidth = CGFloat(roomWidth * 0.75)
                        let buttonHeight = CGFloat(roomHeight * 0.75)
                        roomButton.frame = CGRect(
                            x: buttonX,
                            y: buttonY,
                            width: buttonWidth,
                            height: buttonHeight
                        )
                        
                        roomButton.titleLabel?.text = room!.name
                        
                        roomButton.addTarget(self, action: #selector(displayRoomInfo), for:.touchDown)
                        
                        roomButton.showsTouchWhenHighlighted = true
                        
                        roomView.addSubview(roomButton)
                    }
                    
                } else { roomView.backgroundColor = UIColor.darkGray }
                
                self.mapDisplayView.addSubview(roomView)
                
                // Flips map upside down, to match the house layout.
                self.mapDisplayView.transform = CGAffineTransform(scaleX: 1, y: -1)
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
        nameItem.tintColor = UIColor.black
        self.roomNameBar.items! += [nameItem]
        
        
        // Icon for PLAYER
        if self.house.currentRoom.name == sender.qualifier {
            let iconItem = UIBarButtonItem()
            iconItem.title = "🙋"
            self.roomNameBar.items! += [iconItem]
        }
        
        // Icon for NPC
        if (self.house.roomForName(name: sender.qualifier)?.characters.count)! > 0 || (self.house.necessaryRooms[sender.qualifier]?.characters.count)! > 0 {
            let iconItem = UIBarButtonItem()
            iconItem.title = "🐙"
            self.roomNameBar.items! += [iconItem]
        }

        
        self.roomNameBar.isHidden = false
        
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
