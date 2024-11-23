# Fall 2024 - Intro to Game Design @ SUNY New Paltz
* Name: Benjamin Jon
* [Trello Board](https://trello.com/b/xEwWLpOi/godot-core-game-mechanic)
* [Proposal](https://docs.google.com/document/d/1pc96bL5eg8kmmHi8BilyL7ZiBCj0U-8YZ9nW7z4o3qc/edit?usp=sharing)
* [itch.io](https://jonb1.itch.io/game)

### 2024-11-2 3hr Add Enemy Turn Timer
* Enemy now takes 0.8 seconds to turn, allowing the player a chance to strike

### 2024-11-22 4hr Fix Mage Fireball Glitch, Add TileMap
* Fixed Mage Fireball Spawning Glitch
* Fireball blast is now oriented correctly
* TileMap created with death boundary

### 2024-11-16 5hr Refactor Movement, Add Jump/Gravity, Add Basic Map, Add Enemy Teleport
* Movement is now handled more gracefully both technically and visually
* There is now an acceleration and deceleration, making a move pleasurable movement experience
* Movement updates are only implemented on the Player
* The player can now jump and fall due to gravity
* Created a basic map with platforms and boundaries 
* Enemy can randomly teleport closer to the player if it passes a certain radius

### 2024-11-04 1hr Add Cloak Ability to Rogue
* Rogue can now invoke cloak ability by pressing R

### 2024-10-28 3.5hr Implement Base Character Class to Enemy
* Enemy now uses Base Character Class
* Enemy Character Unlocked After Defeating

### 2024-10-27 2hr Create Base Character Class
* Create Base Character Class 
* Update Player Class to extend Character

### 2024-10-20 4hr Added Enemy And Simple Combat
* Added Enemy 
* Added Attacking 

### 2024-10-19 - 7hr Added Fireball Shooting for Mage and Fix Bugs
* Added a fireball
* Fix Timer bugs

### 2024-10-15 - 1hr Added Animations and an Attack Timer
* Added Animations for Mage and Rogue
* Added an Attack Timer
* Fine tuned pecific values

### 2024-10-14 - 6hr Created Mage and Rogue Resources and Implemented Character Switching
* Create Mage and Rogue Resources
* Implement Character Switching
* Add Rogue and Mage Animations
* WIP To Apply Animations on Games

### 2024-10-08 - 4hr Created a State Machine Design, and added Animation Player
* Attempted to improve the state machine design to fix an animation bug
* Still a work in progress
* Shifted from AnimationSprite2D to AnimationPlayer to handle animations as a quick fix for animation bug

### 2024-10-07 - 4.5hr Created a Rogue class, Base Character class, and Animation State Machine
* Create Base Character Class containing variables and animation state machine
* Created a Rogue Class extending Base Character

### 2024-10-05 - 2hr Set up Repository and Watched Godot Tutorial
* Set up Git/GitHub Repository
* Watched Godot Tutorials on how to make players

