//
//  GameScene.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/5/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import SpriteKit
import GameplayKit


// Globals //
let mapDims:Double=200

let sampleDims:Int32=200

var map = SKSpriteNode(imageNamed: "map")
var center = SKSpriteNode(imageNamed: "tile01")


var biomeTexture = SKTexture()
var mapTexture=SKTexture()

var noiseMap=GKNoiseMap()

var mapList=[mapTile]()


// GameScene //

class GameScene: SKScene {

    // Constants
    let mainmenuState:Int=0
    let inGameState:Int=1
    let loadGameState:Int=2
    

    
    
    
    
    var myMap=MapClass()
    
    // Integers
    var currentState:Int=0
    
    
    // SpriteNodes
    let mmBG=SKSpriteNode(imageNamed: "mainmenuBG")
    let mmPlayButton=SKSpriteNode(imageNamed: "playButton")
    let mmLoadButton=SKSpriteNode(imageNamed: "loadButton")
    let mmLogo=SKSpriteNode(imageNamed: "mmLogo")
    let droneHUD=SKSpriteNode(imageNamed: "droneHUD")
    
    
    // Booleans
    var leftPressed:Bool=false
    var rightPressed:Bool=false
    var upPressed:Bool=false
    var downPressed:Bool=false
    var zoomOutPressed:Bool=false
    var zoomInPressed:Bool=false
    
    // Camera
    var cam=SKCameraNode()
    
    

    
    
    
    
    override func didMove(to view: SKView) {
        
        self.camera=cam
        addChild(cam)
        
        center.zPosition = -100
        addChild(center)
        
        //Init main menu
        
        mmBG.name="mmBG"
        mmBG.zPosition=0
        addChild(mmBG)
        
        mmPlayButton.position.x = -size.width*0.25
        mmPlayButton.name="mmPlayButton"
        mmPlayButton.zPosition=1
        mmBG.addChild(mmPlayButton)
        
        mmLoadButton.position.x = -size.width*0.25
        mmLoadButton.position.y = -size.height*0.15
        mmLoadButton.zPosition=1
        mmLoadButton.name="mmLoadButton"
        mmBG.addChild(mmLoadButton)
        
        
        
        mmLogo.zPosition=1
        mmLogo.name="mmLogo"
        mmLogo.position.x = -size.width*0.166
        mmLogo.position.y = size.height*0.333
        mmBG.addChild(mmLogo)
        
        // Temp
        map.zPosition=100
        map.isHidden=true
        map.name="map"
        cam.addChild(map)
        
        droneHUD.isHidden=true
        droneHUD.zPosition=10000
        droneHUD.alpha=0.7
        droneHUD.setScale(0.5)
        droneHUD.name="droneHUD"
        cam.addChild(droneHUD)
        
    } // didMove
    
    
    func touchDown(atPoint pos : CGPoint) {
        if currentState==mainmenuState
        {
            for thisNode in nodes(at: pos)
            {
                if thisNode.name=="mmPlayButton"
                {
                    changeState(to: inGameState)
                    myMap.seed=generateTerrainMap()
                    map.isHidden=true
                    
                } // if play button
            } // for each node
            
        } // if we're at the main menu
        
    } // touchDown
    
    func touchMoved(toPoint pos : CGPoint) {

    } // touchMoved
    
    func touchUp(atPoint pos : CGPoint) {

    } // touchUp
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    } // mouseDown
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    } // mouseDragged
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    } // mouseUp
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {

        case 0:
            if currentState==inGameState
            {
                leftPressed=true
            }
        case 2:
            if currentState==inGameState
            {
                rightPressed=true
            }
        case 1:
            if currentState==inGameState
            {
                downPressed=true
            }
            
        case 13:
            if currentState==inGameState
            {
                upPressed=true
            }
            
        case 27:
            if currentState==inGameState
            {
                zoomOutPressed=true
            }
            
        case 24:
            if currentState==inGameState
            {
                zoomInPressed=true
            }
            
        case 46:
            if currentState==inGameState
            {
                if map.isHidden==true
                {
                    map.isHidden=false
                }
                else
                {
                    map.isHidden=true
                }
            } // if we're in game
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        } // switch
    } // keyDown
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            
        case 0:
            if currentState==inGameState
            {
                leftPressed=false
            }
        case 2:
            if currentState==inGameState
            {
                rightPressed=false
            }
        case 1:
            if currentState==inGameState
            {
                downPressed=false
            }
            
        case 13:
            if currentState==inGameState
            {
                upPressed=false
            }
            
        case 27:
            if currentState==inGameState
            {
                zoomOutPressed=false
            }
            
        case 24:
            if currentState==inGameState
            {
                zoomInPressed=false
            }
        default:
            break
        } // switch
    } // keyUp
    
    
    func changeState(to: Int)
    {
        switch to
        {
            
        case inGameState:
            if currentState==mainmenuState
            {
                mmBG.isHidden=true
                currentState=inGameState
                map.isHidden=true
                myMap.seed=generateTerrainMap()
                genMap()
                drawMap()
                droneHUD.isHidden=false
            } // if we're leaving the main menu
            
        default:
            print("Error -- Should not happen")
            
        } // switch currentState
        
    } // func changeState
    
    
    func checkKeys()
    {
        if currentState==inGameState
        {
            if upPressed
            {
                cam.position.y += 25
            }
            if downPressed
            {
                cam.position.y -= 25
            }
            if leftPressed
            {
                cam.position.x -= 25
            }
            if rightPressed
            {
                cam.position.x += 25
            }
            
            if zoomOutPressed
            {
                let currentScale=cam.xScale
                cam.setScale(currentScale+0.01)
            }
            
            if zoomInPressed
            {
                let currentScale=cam.xScale
                cam.setScale(currentScale-0.01)
                
            }
            
        } // if we're in game
        
    } // checkKeys
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        checkKeys()
        
    } // update
} // class GameScene
