//
//  GameScene.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/5/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene {

    // Constants
    let mainmenuState:Int=0
    let inGameState:Int=1
    
    
    
    
    
    
    // Game Variables
    var myMap=MapClass()
    var currentState:Int=0
    
    
    // SpriteNodes
    let mmBG=SKSpriteNode(imageNamed: "mainmenuBG")
    let mmPlayButton=SKSpriteNode(imageNamed: "playButton")
    
    override func didMove(to view: SKView) {
        
        
        //Init main menu
        
        mmBG.name="mmBG"
        mmBG.zPosition=0
        addChild(mmBG)
        
        mmPlayButton.position.x = -size.width*0.25
        mmPlayButton.name="mmPlayButton"
        mmPlayButton.zPosition=1
        addChild(mmPlayButton)
        
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
