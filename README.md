# HORRIBLE HOUSE

Horrible House is a haunted house text adventure for iOS. You are in a mysterious haunted house for mysterious reasons, and you must explore it until midnight, at which point… Something bad might happen!

Horrible House acts as a template on which to build other adventures using the Rooms and Events .plist files. This README will act as a walkthrough of some of the highlights in Horrible House that are open for customization.

##The ‘House’ class
An object in the House class is created at the game’s beginning to control the room layout, NPC behavior, and the execution of actions and player choices. It works in tandem with the GameController to do most of the work.

###House.layout and LayoutOptions
House’s layout variable is the basis for the game’s room layout. Layout is an array of an array of an array of Int values. This variable can be set to any of the preset LayoutOptions – by default, LayoutOptions.a.

static let a = [
            [[6, 1, 0, 0],
            [1, 1, 0, 0,],
            [0, 0, 0, 0,]], // second floor = 2
            
            [[5, 1, 1, 3],
            [0, 1, 1, 0],
            [0, 0, 2, 0]], // first floor = 1
            
            [[0, 0, 1, 4],
            [0, 0, 1, 1],
            [0, 0, 0, 0]]  // basement = 0
        ]

The numerical values in the LayoutOptions correspond to certain kinds of rooms, as defined in House’s RoomType struct.

1 corresponds to a room in the Rooms.plist. Rooms 0 and 2 to 6 correspond to rooms in the NecessaryRooms.plist, including stairways between different floors, the starting room, and placeholders where no room exist. NecessaryRooms.plist and LayoutOptions can be changed to add rooms that will be present in every game.

All LayoutOptions, however, have to be uniform. That is, every floor array needs to have the same number of rows and columns. A crash is possible, otherwise.

##Data structure of the room .plist files
Each .plist contains a dictionary. Each dictionary, in turn, contains dictionaries of inhabitable rooms. Along with information for each room – like a name and description – the room dictionaries contain arrays of other dictionaries of items in the room. The item dictionaries in turn contain arrays of dictionaries of actions that can be performed with those items. On the creation of the House object at the game’s start, these dictionaries are all used to initialized every room, item, and action.


###Rooms.plist
Most of Horrible House is made up of the data in this property list. They contain the rooms in the game house, and they in turn contain every item that can be interacted with. Editing the Rooms and NecessaryRooms .plist files will be the main way you can customize how the game’s flow and content is arranged.

###NecessaryRooms.plist
These rooms are meant to appear in a every game, and their position is meant to be static. Upon creation of the game’s House object, the data here is stored in a dictionary: House.necessaryRooms. The keys for each room are defined in the House class in the RoomType struct’s roomName function. If the names of any Necessary Rooms change, the corresponding string listed in the roomName function should be changed.

####Placement Guidelines
Placement guidelines are optional parameters within a room dictionary that can define where rooms in the house are ultimately placed. They are dictionaries that contain either key-value pairs, or just keys that are used as keywords themselves.
- floor: which floor the room is meant to be on. By default, the values options are 0 (basement), 1, and 2.
- edge: room is place at the edge the floor, with a wall on at least one side.
- middle: room is in the middle of the floor, surrounded on most sides by another room.
If, while the house object is first initialized, every room’s placement guidelines are unable to be satisfied, placement guidelines may be broken at random.

####Shuffling the room layout
If you wish you define a static layout to your house object, simply search for and comment out “rooms.shuffle()”. Have the house laid out the way you wish for it to be will likely require testing.

###Events.plist
Events, as outlined in the Event.plist, are context-sensitive situations that are triggered based on actions that take place in rooms, or even other events. They can be arranged to take place in more than one location depending on when and how they are triggered. Events are broken down into stages, allowing events to be manifest in different ways depending on rules sets, (items held, previous events triggered). Stages, like rooms, are organized into dictionaries that in turn contain other arrays of dictionaries that allow the player to make different choices.

##Items
Although rooms themselves can contain actions and provide the player with interactions, but player actions are tied to items within rooms. 

###Item Keywords
- hidden: the item is not visible to the player unless revealed through an action
- canCarry: the item can be taken by the player and added to their inventory
- maxCapacity: if a number value is paired with this key, the item becomes a container and can be use to contain other, different items.

##Actions
Action objects become the choices your player can take and the method by which they can interact with items in the game world. Every change to the game world of consequence is done by executing and resolving actions.

###Action Keywords 
- result: displayed after the action is executed
- roomChange: replaces the explanatory description of the current room/stage
- revealItems: the items named in this array are made to be no longer hidden
- liberateItems: the items named in this array are allowed to be picked up and carried by the player
- addItems: the items named in this array are added directly to the player’s inventory
- consumeItems: the items named in this array are removed from the player’s inventory
- spawnCharacters: the character dictionaries in this array are use to initialize new characters, either in the current room or a room named in the character’s startingRoom key.
- revealCharacters: the characters named in this array are made to be no longer hidden
- removeCharacters: the characters named in this array are removed entirely from the current game.
- onceOnly: this key is use to destroy this action after being executed once.
- triggerEvent: the event named in this dictionary is triggered at the stage named in this dictionary.
- replaceAction: this defines a new action that take the place of the current action.
- moveCharacter: this dictionary defines a character name, and either a room name or direction name, and is used to move that character to that place.
- segue: this dictionary tells the GameController to go to another view controller defined by the “identifier” key. The optional “qualifier” key is used to pass information to that new view controller, depending on the situation.

##Rules
Rules are used to define whether are not a player can interact with the game in certain ways, i.e., whether an action can be performed, whether an event can be triggered, or whether certain details in a room can be noticed. Similarly, these can be used to decide how NPCs behave. Rules are arrays of strings that can be added to actions, details, events, and stages, formatted in such a way so that the game can understand what rule is being asked for.
- hasItemName
- metCharacterName
- enteredRoomName
- completedEventName
- inRoomWithCharacterName
- timePassedHH:MM
- didStoreItemName
- occupyingRoomName
In the case that you wish to check the negative of one of these rules (for example, if the player does NOT have an item), then add the word “nope” to the beginning of your rule and capitalize the next word (nopeHasItemName).

##NPC Behaviors
NPC characters, like the player, can carry items. NPCs can also be given an array of behaviors. These behaviors can be executed based on the rules associated with them. Currently, NPCs can stay in the room they’re spawned (Default), roam from room to room (Random), or go to the room the player is in (PursuePlayer).

##Tab Bar Items
The GameController is embedded in a Tab Bar Controller. Depending on what the player is holding, the available tabs can change. Picking up your first item adds the Inventory tab. Depending on the items picked up, the Map and Time tabs can be added.

##Skull.plist
Horrible House is built to have an talking Skull item simply called “Skull.” Possessing it allows access to the Skull tab. The skull comments on items, room, and other facets of the house depending on what is written in the Skull plist.

##Style Class
The Style class contains two Structs: Color and Font. These can be changed to alter the general style of UI elements throughout the game.



