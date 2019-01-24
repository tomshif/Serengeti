//
//  GameScene.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/5/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import SpriteKit
import GameplayKit

extension String {
    var westernArabicNumeralsOnly: String {
        let pattern = UnicodeScalar("0")..."9"
        return String(unicodeScalars
            .compactMap { pattern ~= $0 ? Character($0) : nil })
    }
}

// Globals //
let mapDims:Double=172

let sampleDims:Int32=172

var map = SKSpriteNode(imageNamed: "map")
var center = SKSpriteNode(imageNamed: "tile01")


var biomeTexture = SKTexture()
var mapTexture=SKTexture()

var noiseMap=GKNoiseMap()
var biomeMap=GKNoiseMap()

var mapList=[mapTile]()

let BIRDCOUNT:Int=100

let ENTITYHERD:Int=0
let SADDLECATHERD:Int=2
let BIRDFLOCK:Int=4
let ZEBRAHERD:Int=6
let SPRINGBOKHERD:Int=8
let CHEETAHHERD:Int=10
let BUZZARDFLOCK:Int=12

let ENTITYHERDSIZE:CGFloat=10
let BIRDFLOCKSIZE:Int=20

var entityHerdCount:Int=0

var treeMaster=SKSpriteNode(imageNamed: "treeVariation1")

// GameScene //

class GameScene: SKScene {

    // Constants
    let mainmenuState:Int=0
    let inGameState:Int=1
    let loadGameState:Int=2
    let mapGenState:Int=4
    let genMapZonesState:Int=6
    let MAXUPDATECYCLES:Int=8
    
    let WATERZONECOUNT:Int=25
    let RESTZONECOUNT:Int=10
    let FOODZONECOUNT:Int=50
    let TESTENTITYCOUNT:Int=100
    let BUZZARDCOUNT:Int=24
    let TREECOUNT:Int=20000
    
    let PARKINFOUPDATEFREQ:Double=2.0
    
    var mapGenDelay:Int=0
    
    let MAXZOOM:CGFloat=0.5
    let MINZOOM:CGFloat=2.5
    let DRONEPOWER:CGFloat=0.3
    let DRONEMAXSPEED:CGFloat=30.0
    let DRONEINERTIA:CGFloat=0.025
    var nextLightning:Double=32.00
    var rainChange:Double=0.00
    
    var myMap=MapClass()
    
    // Integers
    var currentState:Int=0
    var waterZonesSpawned:Int=0
    var restZonesSpawned:Int=0
    var foodZonesSpawned:Int=0
    var currentCycle:Int=0
    var entityHerdSpawns:Int=0
    var lastLightUpdate:Int=0
    var buzzardsSpawned:Int=0
    var treesSpawned:Int=0
    
    // SpriteNodes - Main Menu
    
    let mmBG=SKSpriteNode(imageNamed: "mmBGMockup")
    let mmPlayButton=SKSpriteNode(imageNamed: "playButton")
    let mmLoadButton=SKSpriteNode(imageNamed: "loadButton")
    let mmHowButton=SKSpriteNode(imageNamed: "loadButton")
    let mmLogo=SKSpriteNode(imageNamed: "mmLogo")
    let mmGenerating=SKSpriteNode(imageNamed: "mmGeneratingMap")
    let mmHowPlay=SKSpriteNode(imageNamed: "mmHowToPlay")
    
    // SpriteNodes - In Game HUD
    let droneHUD=SKSpriteNode(imageNamed: "hudReticle")
    let hudTimeBG=SKSpriteNode(imageNamed: "hudTextbox")
    let hudMsgBG=SKSpriteNode(imageNamed: "hudTextbox")
    let hudNVG=SKSpriteNode(imageNamed: "hudNightVision")
    let hudAltArrow=SKSpriteNode(imageNamed: "hudAltArrow")
    let hudParkInfo=SKSpriteNode(imageNamed: "hudParkInfo")
    let hudAltBar=SKSpriteNode(imageNamed: "hudAltBar")
    
    
    // ShapeNodes - In Game HUD
    let hudMapMarker=SKShapeNode(circleOfRadius: 5)
    var hudLightMask=SKShapeNode()
    var light=SKLightNode()
    
    
    // SKLabels
    let mmGenSplinesLabel=SKLabelNode(fontNamed: "Arial")
    let mmGenWaterLabel=SKLabelNode(fontNamed: "Arial")
    let mmGenRestLabel=SKLabelNode(fontNamed: "Arial")
    let mmGenAnimalsLabel=SKLabelNode(fontNamed: "Arial")
    let mmGenFoodLabel=SKLabelNode(fontNamed: "Arial")
    let mmGenTreeLabel=SKLabelNode(fontNamed: "Arial")
    
    let hudTimeLabel=SKLabelNode(fontNamed: "Arial")
    let hudMsgLabel=SKLabelNode(fontNamed: "Arial")
    let hudTimeScaleLabel=SKLabelNode(fontNamed: "Arial")
    let hudAltitudeLabel=SKLabelNode(fontNamed: "Arial")
    let hudCoordLabel=SKLabelNode(fontNamed: "Arial")
    let hudSpeedLabel=SKLabelNode(fontNamed: "Arial")
    let hudPITotalAnimals=SKLabelNode(fontNamed: "Arial")
    let hudPICheetah=SKLabelNode(fontNamed: "Arial")
    let hudPISpringbok=SKLabelNode(fontNamed: "Arial")
    let hudPIWarthog=SKLabelNode(fontNamed: "Arial")
    let hudPIZebra=SKLabelNode(fontNamed: "Arial")
    let hudSeasonLabel=SKLabelNode(fontNamed: "Arial")
    
    
    // Sounds
    let thunder01=SKAudioNode(fileNamed: "thunder01")
    
    // Booleans
    var leftPressed:Bool=false
    var rightPressed:Bool=false
    var upPressed:Bool=false
    var downPressed:Bool=false
    var zoomOutPressed:Bool=false
    var zoomInPressed:Bool=false
    var nightVisionEnabled:Bool=true
    var showParkInfo:Bool=false
    var showYearlyChange:Bool=true
    var isRaining:Bool=false
    
    
    // Camera
    var cam=SKCameraNode()
    
    // Vectors
    var droneVec=CGVector(dx: 0, dy: 0)
    
    // Particle Effects
    let rainNode=SKEmitterNode(fileNamed: "rainTest01.sks")
    
    // NSDates
    var lastParkInfoUpdate=NSDate()
    var lastLightning=NSDate()
    var lastRainChange=NSDate()
    
    // Others
    
    var lightningAction=SKAction()

    
    
    
    
    override func didMove(to view: SKView) {
        
        rainChange=Double(random(min: 5, max: 60.00))
        

        myMap.info.map=myMap
        
        self.camera=cam
        addChild(cam)
        
        rainNode!.particleBirthRate=0
        rainNode!.zPosition=4998
        rainNode!.targetNode=scene
        cam.addChild(rainNode!)

        
        let hudLightMaskRect=CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        hudLightMask=SKShapeNode(rect: hudLightMaskRect)
        hudLightMask.fillColor=NSColor.init(calibratedRed: 0, green: 0.5, blue: 0, alpha: 1.0)
        hudLightMask.strokeColor=NSColor.systemGreen
        hudLightMask.alpha=0.5
        hudLightMask.isHidden=true
        
        hudLightMask.zPosition=4999
        cam.addChild(hudLightMask)
        
        
        //center.colorBlendFactor=0.5
        addChild(center)
        center.zPosition = -1000
        
        //Init main menu
        
        mmBG.name="mmBG"
        mmBG.zPosition=0
        addChild(mmBG)
        
        mmPlayButton.position.x = size.width*0.3
        mmPlayButton.position.y = size.height*0.1
        mmPlayButton.name="mmPlayButton"
        mmPlayButton.zPosition=1
        mmPlayButton.alpha=0.00001
        mmBG.addChild(mmPlayButton)
        
        mmLoadButton.position.x = size.width*0.3
        mmLoadButton.position.y = -size.height*0.05
        mmLoadButton.zPosition=1
        mmLoadButton.name="mmLoadButton"
        mmLoadButton.alpha=0.00001
        mmBG.addChild(mmLoadButton)
        
        mmHowButton.position.x = size.width*0.3
        mmHowButton.position.y = -size.height*0.15
        mmHowButton.zPosition=1
        mmHowButton.name="mmHowButton"
        mmHowButton.alpha=0.00001
        mmBG.addChild(mmHowButton)
        
        mmHowPlay.zPosition=3
        mmHowPlay.isHidden=true
        mmHowPlay.name="mmHowToPlay"
        mmBG.addChild(mmHowPlay)
        
        
        mmLogo.zPosition=1
        mmLogo.name="mmLogo"
        mmLogo.position.x = -size.width*0.166
        mmLogo.position.y = size.height*0.333
        mmBG.addChild(mmLogo)
        
        mmGenerating.zPosition=2
        mmGenerating.isHidden=true
        mmBG.addChild(mmGenerating)
        
        mmGenSplinesLabel.zPosition=3
        mmGenSplinesLabel.fontSize=22
        mmGenSplinesLabel.position.y = mmGenerating.size.height*0.10
        mmGenSplinesLabel.text="Reticulating Splines: 0%"
        mmGenerating.addChild(mmGenSplinesLabel)
        
        mmGenWaterLabel.zPosition=3
        mmGenWaterLabel.fontSize=22
        mmGenWaterLabel.position.y = 0
        mmGenWaterLabel.text="Hitting the hot tub: 0%"
        mmGenerating.addChild(mmGenWaterLabel)
        
        mmGenRestLabel.zPosition=3
        mmGenRestLabel.fontSize=22
        mmGenRestLabel.position.y = -mmGenerating.size.height*0.1
        mmGenRestLabel.text="Taking a nap: 0%"
        mmGenerating.addChild(mmGenRestLabel)
        
        mmGenFoodLabel.zPosition=3
        mmGenFoodLabel.fontSize=22
        mmGenFoodLabel.position.y = -mmGenerating.size.height*0.2
        mmGenFoodLabel.text="Cooking dinner: 0%"
        mmGenerating.addChild(mmGenFoodLabel)

        mmGenTreeLabel.zPosition=3
        mmGenTreeLabel.fontSize=22
        mmGenTreeLabel.position.y = -mmGenerating.size.height*0.3
        mmGenTreeLabel.text="Tending the garden: 0%"
        mmGenerating.addChild(mmGenTreeLabel)
        
        mmGenAnimalsLabel.zPosition=3
        mmGenAnimalsLabel.fontSize=22
        mmGenAnimalsLabel.position.y = -mmGenerating.size.height*0.4
        mmGenAnimalsLabel.text="Rescuing pit bulls: 0%"
        mmGenerating.addChild(mmGenAnimalsLabel)
        
        hudTimeBG.position.x = 0
        hudTimeBG.position.y = size.height/2-hudTimeBG.size.height/2
        hudTimeBG.isHidden=true
        hudTimeBG.zPosition=5000
        cam.addChild(hudTimeBG)
        
        hudTimeLabel.text="Time"
        hudTimeLabel.fontSize=22
        hudTimeLabel.zPosition=5001
        hudTimeLabel.position.y=hudTimeBG.size.height*0.25
        hudTimeBG.addChild(hudTimeLabel)
        
        hudSeasonLabel.text="Wet Season"
        hudSeasonLabel.fontSize=22
        hudSeasonLabel.zPosition=5001
        hudSeasonLabel.position.y = 0
        hudTimeBG.addChild(hudSeasonLabel)
        
        hudTimeScaleLabel.text="TimeScale"
        hudTimeScaleLabel.fontSize=22
        hudTimeScaleLabel.zPosition=5001
        hudTimeScaleLabel.position.y = -hudTimeBG.size.height*0.25
        hudTimeBG.addChild(hudTimeScaleLabel)
        
        hudMsgBG.position.x = -size.width/2+hudTimeBG.size.width/2
        hudMsgBG.position.y = -size.height/2+hudTimeBG.size.height/2
        hudMsgBG.alpha=0.0
        hudMsgBG.name="hudMsgBG"
        hudMsgBG.zPosition=5000
        cam.addChild(hudMsgBG)
        
        hudMsgLabel.text="Message"
        hudMsgLabel.fontSize=16
        hudMsgLabel.zPosition=5001
        hudMsgLabel.numberOfLines=5
        hudMsgLabel.preferredMaxLayoutWidth=hudMsgBG.size.width*0.85
        hudMsgBG.addChild(hudMsgLabel)
        
        hudMapMarker.zPosition=10001
        hudMapMarker.alpha=0.75
        map.addChild(hudMapMarker)
        
        hudNVG.isHidden=true
        hudNVG.zPosition=5000
        hudNVG.alpha=0.9
        cam.addChild(hudNVG)
        
        // Temp
        map.zPosition=10000
        map.isHidden=true
        map.name="map"
        map.position.x = size.width/2-map.size.width/2
        map.position.y = size.height/2-map.size.height/2
        map.alpha=0.75
        cam.addChild(map)
        
        droneHUD.isHidden=true
        droneHUD.zPosition=10000
        droneHUD.alpha=0.7
        droneHUD.setScale(1.0)
        droneHUD.name="droneHUD"
        cam.addChild(droneHUD)
        
        hudAltBar.zPosition=10000
        hudAltBar.alpha=0.7
        hudAltArrow.name="hudAltBar"
        droneHUD.addChild(hudAltBar)
        hudAltBar.position.x = -droneHUD.size.width/2-hudAltBar.size.width
        
        
        hudAltArrow.zPosition=10000
        hudAltArrow.alpha=0.7
        hudAltArrow.name="hudAltArrow"
        droneHUD.addChild(hudAltArrow)
        hudAltArrow.position.x = -droneHUD.size.width/2-hudAltBar.size.width/2-hudAltArrow.size.width
        
        hudAltitudeLabel.zPosition=10000
        hudAltitudeLabel.name="hudAltLabel"
        hudAltitudeLabel.fontColor=NSColor(calibratedRed: 0.314, green: 1.0, blue: 1.0, alpha: 1.0)
        hudAltitudeLabel.text="Altitude: 200m"
        hudAltitudeLabel.fontSize=16
        droneHUD.addChild(hudAltitudeLabel)
        hudAltitudeLabel.position.x = -droneHUD.size.width*0.82
        
        hudCoordLabel.zPosition=10000
        hudCoordLabel.name="hudCoordLabel"
        hudCoordLabel.fontColor=NSColor(calibratedRed: 0.314, green: 1.0, blue: 1.0, alpha: 1.0)
        hudCoordLabel.text="Coordinates: 32x, 34y"
        hudCoordLabel.fontSize=16
        droneHUD.addChild(hudCoordLabel)
        hudCoordLabel.position.y = -droneHUD.size.height*0.58
        
        hudSpeedLabel.zPosition=10000
        hudSpeedLabel.name="hudSpeedLabel"
        hudSpeedLabel.fontColor=NSColor(calibratedRed: 0.314, green: 1.0, blue: 1.0, alpha: 1.0)
        hudSpeedLabel.text="Speed"
        hudSpeedLabel.fontSize=16
        droneHUD.addChild(hudSpeedLabel)
        hudSpeedLabel.position.y = droneHUD.size.height/2
        
        hudParkInfo.isHidden=true
        hudParkInfo.position.x = -size.width/2+hudParkInfo.size.width/2
        hudParkInfo.zPosition=10000
        hudParkInfo.name="hudParkInfo"
        cam.addChild(hudParkInfo)
        
        hudPITotalAnimals.zPosition=10001
        hudPITotalAnimals.name="hudPITAnimals"
        hudPITotalAnimals.fontColor=NSColor.white
        hudPITotalAnimals.text="Total Animals"
        hudPITotalAnimals.fontSize=18
        hudParkInfo.addChild(hudPITotalAnimals)
        hudPITotalAnimals.position.y = hudParkInfo.size.height*0.35
        
        hudPICheetah.zPosition=10001
        hudPICheetah.name="hudPICheetah"
        hudPICheetah.fontColor=NSColor.white
        hudPICheetah.text="Cheetah: "
        hudPICheetah.fontSize=18
        hudParkInfo.addChild(hudPICheetah)
        hudPICheetah.position.y = hudParkInfo.size.height*0.3
        
        hudPISpringbok.zPosition=10001
        hudPISpringbok.name="hudPISpringbok"
        hudPISpringbok.fontColor=NSColor.white
        hudPISpringbok.text="Springbok:"
        hudPISpringbok.fontSize=18
        hudParkInfo.addChild(hudPISpringbok)
        hudPISpringbok.position.y = hudParkInfo.size.height*0.25
        
        hudPIWarthog.zPosition=10001
        hudPIWarthog.name="hudPIWarthog"
        hudPIWarthog.fontColor=NSColor.white
        hudPIWarthog.text="Warthog:"
        hudPIWarthog.fontSize=18
        hudParkInfo.addChild(hudPIWarthog)
        hudPIWarthog.position.y = hudParkInfo.size.height*0.20
        
        hudPIZebra.zPosition=10001
        hudPIZebra.name="hudPIZebra"
        hudPIZebra.fontColor=NSColor.white
        hudPIZebra.text="Warthog:"
        hudPIZebra.fontSize=18
        hudParkInfo.addChild(hudPIZebra)
        hudPIZebra.position.y = hudParkInfo.size.height*0.15
        
        thunder01.autoplayLooped=false
        addChild(thunder01)
        thunder01.run(SKAction.stop())
        
        
        

    } // didMove
    
    
    func touchDown(atPoint pos : CGPoint) {
        if currentState==mainmenuState
        {
            for thisNode in nodes(at: pos)
            {
                if thisNode.name=="mmPlayButton"
                {
                    if mmHowPlay.isHidden
                    {
                        mmGenerating.isHidden=false
                        changeState(to: mapGenState)
                        //myMap.seed=generateTerrainMap()
                        
                        map.isHidden=true
                    }
                } // if play button
                
                if thisNode.name=="mmHowButton"
                {
                    if mmHowPlay.isHidden
                    {
                        mmHowPlay.isHidden=false
                    }
                    else
                    {
                        mmHowPlay.isHidden=true
                    }
                } // if it's the how to play button
                
                if thisNode.name=="mmHowToPlay"
                {
                    mmHowPlay.isHidden=true
                } // if it's the how to play pop up
                
            
            } // for each node
            
            
            
        } // if we're at the main menu
        
        
        if currentState==inGameState
        {
            print("Click")
            for thisNode in nodes(at: pos)
            {
                if thisNode.name=="hudMsgBG" || thisNode.name=="hudMsgLabel"
                {
                    print("Msg Click")
                    let index=myMap.msg.getArchivedCount()
                    var message=myMap.msg.readArchivedMessage(index: index-1)
                    var ent=message.westernArabicNumeralsOnly
                    let entNum=ent.prefix(4)
                    print("Entity Num: \(entNum)")
                    for ents in myMap.entList
                    {
                        if ents.name.contains(entNum)
                        {
                            // compute distance to point
                            let dx=ents.sprite.position.x-cam.position.x
                            let dy=ents.sprite.position.y-cam.position.y
                            let dist=hypot(dy, dx)
                            let time=dist/DRONEMAXSPEED/60
                            cam.run(SKAction.move(to: ents.sprite.position, duration: TimeInterval(time)))
                            break
                        } // if we can pull the entity from the entList
                    } // for each entity
                    
                } // if we click on the hudMessage
            } // for each node
        } // if we're in game
        
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
            
            
        case 16: // Y
            if showYearlyChange
            {
                showYearlyChange=false
                myMap.msg.sendCustomMessage(message: "Showing total change.")
            }
            else
            {
                showYearlyChange=true
                myMap.msg.sendCustomMessage(message: "Showing annual change.")
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
            
        case 30: // [
            if currentState==inGameState
            {
                if !myMap.increaseTimeScale()
                {
                    myMap.msg.sendCustomMessage(message: "\(myMap.getTimeScale())x - Maximum time acceleration.")
                }
            }
            
        case 33: // ]
            if currentState==inGameState
            {
                if !myMap.decreaseTimeScale()
                {
                    myMap.msg.sendCustomMessage(message: "\(myMap.getTimeScale())x - Minimum time acceleration.")
                }
            }
            
        case 34: // I
            if currentState==inGameState
            {
                if hudParkInfo.isHidden
                {
                    hudParkInfo.isHidden=false
                }
                else
                {
                    hudParkInfo.isHidden=true
                }
            }

            
        case 39: // '
            flashLightning()
            
        case 45: // N
            if currentState==inGameState
            {
                if nightVisionEnabled
                {
                    nightVisionEnabled=false
                }
                else
                {
                    nightVisionEnabled=true
                }
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
            
            
        case mapGenState:
            if currentState==mainmenuState
            {
                mmGenerating.isHidden=false
                currentState=mapGenState

                

            } // if we're coming from the main menu
        default:
            print("Error changing state -- Should not happen")
            
        } // switch currentState
        
    } // func changeState
    
    func generateMap()
    {
        myMap.seed=generateTerrainMap()
        genMap()
        drawMap()
        currentState=genMapZonesState
    } // func generateMap
    
    func genMapZones()
    {
        if waterZonesSpawned < WATERZONECOUNT
        {
            genWaterZone(theMap: myMap, theScene: self)
            waterZonesSpawned += 1
            
            mmGenSplinesLabel.text="Reticulating splines: 100%"
            mmGenWaterLabel.text=String(format: "Hitting the hot tub: %2.0f%%", (CGFloat(waterZonesSpawned)/CGFloat(WATERZONECOUNT))*100)
            
        } // if we need to spawn a water zone
        else if restZonesSpawned < RESTZONECOUNT
        {
            genRestZone(theMap: myMap, theScene: self)
            restZonesSpawned += 1
            
            mmGenRestLabel.text=String(format: "Taking a nap: %2.0f%%", (CGFloat(restZonesSpawned)/CGFloat(RESTZONECOUNT))*100)
        } // if we need to spawn a rest zone
        else if foodZonesSpawned < FOODZONECOUNT
        {
            genFoodZone(theMap: myMap, theScene: self)
            foodZonesSpawned += 1
            
            mmGenFoodLabel.text=String(format: "Cooking dinner: %2.0f%%", (CGFloat(foodZonesSpawned)/CGFloat(FOODZONECOUNT))*100)
        } // if we need to spawn a food zone
        else if treesSpawned < TREECOUNT
        {
            drawTree(theMap: myMap, theScene: self)
            treesSpawned+=10
            mmGenTreeLabel.text=String(format: "Tending the garden: %2.0f%%", (CGFloat(treesSpawned)/CGFloat(TREECOUNT))*100)
            
        } // if we need to spawn trees
        else if entityHerdSpawns < TESTENTITYCOUNT
        {
            let type=random(min: 0, max: 1.0)
            
            mmGenAnimalsLabel.text=String(format: "Rescuing pit bulls: %2.0f%%", (CGFloat(entityHerdSpawns)/(CGFloat(TESTENTITYCOUNT)+CGFloat(BUZZARDCOUNT))*100))
            let x=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let y=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let pos = CGPoint(x: x, y: y)
            
            if type > 0.6
            {
                spawnHerd(type: ENTITYHERD, loc: pos)
            }
            else if type > 0.45
            {
                spawnHerd(type: ZEBRAHERD, loc: pos)
            }
            else if type > 0.1
            {
                spawnHerd(type: SPRINGBOKHERD, loc: pos)
            }
            else
            {
                spawnHerd(type: CHEETAHHERD, loc: pos)
            }
            
            entityHerdSpawns += 1

            
        } // if we need to spawn animals
        else if buzzardsSpawned < BUZZARDCOUNT
        {
            mmGenAnimalsLabel.text=String(format: "Rescuing pit bulls: %2.0f%%", ((CGFloat(buzzardsSpawned)+CGFloat(entityHerdSpawns))/(CGFloat(TESTENTITYCOUNT)+CGFloat(BUZZARDCOUNT))*100))
            let x=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let y=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let pos = CGPoint(x: x, y: y)
            spawnHerd(type: BUZZARDFLOCK, loc: pos)
            buzzardsSpawned += 1
    
        } // if we need to spawn buzzards
        else
        {
            currentState=inGameState
            droneHUD.isHidden=false
            mmBG.isHidden=true
            map.isHidden=true
            hudTimeBG.isHidden=false
            hudLightMask.isHidden=false
            myMap.info.updateCounts()
            myMap.info.archiveCounts(year: 0)
        } // if we're finished generating map
        

    } // genMapZones
    
    func checkKeys()
    {
        if currentState==inGameState
        {
            if upPressed
            {
                let speed=hypot(droneVec.dy, droneVec.dx)
                if speed < DRONEMAXSPEED
                {
                    droneVec.dy+=DRONEPOWER
                }
            }
            if downPressed
            {
                let speed=hypot(droneVec.dy, droneVec.dx)
                if speed < DRONEMAXSPEED
                {
                    droneVec.dy -= DRONEPOWER
                }
            }
            if leftPressed
            {
                let speed=hypot(droneVec.dy, droneVec.dx)
                if speed < DRONEMAXSPEED
                {
                    droneVec.dx -= DRONEPOWER
                }
            }
            if rightPressed
            {
                let speed=hypot(droneVec.dy, droneVec.dx)
                if speed < DRONEMAXSPEED
                {
                    droneVec.dx += DRONEPOWER
                }
            }
            
            if zoomOutPressed
            {
                if cam.xScale < MINZOOM
                {
                    let currentScale=cam.xScale
                    cam.setScale(currentScale+0.01)
                } // if we can zoom out
            } // if zoom out
            
            if zoomInPressed
            {
                if cam.xScale > MAXZOOM
                {
                    let currentScale=cam.xScale
                    cam.setScale(currentScale-0.01)
                } // if we can zoom in
                
            } // if zoom in
            
        } // if we're in game
        
    } // checkKeys
    
    func spawnFlock()
    {
        if myMap.birdList.count < BIRDCOUNT
        {
            let chance=random(min: 0, max: 1.0)
            if chance > 0.98
            {
                spawnHerd(type: BIRDFLOCK, loc: CGPoint(x: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8), y: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)))
            } // chance
        } // if we have too few birds
        
    } // func spawnFlock
    
    func spawnHerd(type: Int, loc: CGPoint)
    {
        if type==ENTITYHERD
        {
            let herdsize=Int(random(min: ENTITYHERDSIZE*0.5, max: ENTITYHERDSIZE*1.5))
            //let herdsize=1
            let tempLeader=TestClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter)
           
            
            tempLeader.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            myMap.entList.append(tempLeader)
            myMap.entityCounter+=1
            
            for _ in 1...herdsize
            {
                
                let tempEnt=TestClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, ldr: tempLeader)
               
                
                tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                myMap.entList.append(tempEnt)
                myMap.entityCounter+=1
                
            } // for each member of the herd
            
        } // if we're spawning EntityClass
        
        if type==ZEBRAHERD
        {

            let herdsize=Int(random(min: ENTITYHERDSIZE*0.5, max: ENTITYHERDSIZE*1.5))
            //let herdsize=1
            let tempLeader=ZebraClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: nil)
           
            
            tempLeader.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            myMap.entList.append(tempLeader)
            myMap.entityCounter+=1
            
            for _ in 1...herdsize
            {
                
                let tempEnt=ZebraClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: tempLeader)
                
                
                tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                myMap.entList.append(tempEnt)
                myMap.entityCounter+=1
                
            } // for each member of the herd
            
        } // if we're spawning zebras
        
        if type==SPRINGBOKHERD
        {
            
            
            //let herdsize=1
            let tempLeader=SpringbokClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: nil)
          
            let herdsize=Int(random(min: CGFloat(tempLeader.MINHERD), max: CGFloat(tempLeader.MAXHERD)*0.5))
            tempLeader.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            myMap.entList.append(tempLeader)
            myMap.entityCounter+=1
            
            for _ in 1...herdsize
            {
                
                let tempEnt=SpringbokClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: tempLeader)
              
                
                tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                myMap.entList.append(tempEnt)
                myMap.entityCounter+=1
                
            } // for each member of the herd
            
        } // if we're spawning springbok
        
        if type==CHEETAHHERD
        {
            

            let tempLeader=CheetahClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: nil)
            
            
            tempLeader.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            myMap.entList.append(tempLeader)
            myMap.entityCounter+=1
            let chance=random(min: 0, max: 1.0)
            if chance > 0.95
            {
                for _ in 1...2
                {
                    
                    let tempEnt=CheetahClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: tempLeader)
                    
                    
                    tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                    myMap.entList.append(tempEnt)
                    myMap.entityCounter+=1
                    
                } // for each member of the herd
            }
            else if chance > 0.85
            {
                let tempEnt=CheetahClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: myMap.entityCounter, leader: tempLeader)
                
                
                tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                myMap.entList.append(tempEnt)
                myMap.entityCounter+=1
                
            }

            
        } // if we're spawning springbok
        
        if type==BIRDFLOCK
        {
            let tempLeaderBird=BirdClass(theMap: myMap, theScene: self, pos: loc, isLdr: true, ldr: nil)
            tempLeaderBird.sprite.zRotation=random(min:0, max:CGFloat.pi*2)
            myMap.birdList.append(tempLeaderBird)
            let birdNum=Int(random(min: 1, max: CGFloat(BIRDFLOCKSIZE)))
            for _ in 1...birdNum
            {
                let tempBird=BirdClass(theMap: myMap, theScene: self, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), isLdr: false, ldr: tempLeaderBird)
                tempBird.sprite.zRotation=random(min:0,max:CGFloat.pi*2)
                myMap.birdList.append(tempBird)
                
            } // for each bird in the flock
        } // if we're spawning a bird flock
        
        if type==BUZZARDFLOCK
        {
            let tempLeaderBird=BuzzardClass(theMap: myMap, theScene: self, pos: loc, isLdr: true, ldr: nil)
            tempLeaderBird.sprite.zRotation=random(min:0, max:CGFloat.pi*2)
            myMap.buzzardList.append(tempLeaderBird)
            
        }
        
    } // func spawnHerd

    func checkAmbientSpawns()
    {
        
        if myMap.birdList.count < BIRDCOUNT
        {
            let chance=random(min: 0, max: 1.0)
            if chance > 0.0
            {
                spawnHerd(type: BIRDFLOCK, loc: CGPoint(x: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8), y: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)))
            } // chance
        } // if we have too few birds
        
        if myMap.buzzardList.count < BUZZARDCOUNT
        {
            spawnHerd(type: BUZZARDFLOCK, loc: CGPoint(x: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8), y: random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)))
            
            
        }
        
    } // func checkAmbientSpawns
    
    func flashLightning()
    {
        let currentColor=self.hudLightMask.fillColor
        let currentAlpha=self.hudLightMask.alpha
        var nv:Bool=false
        var flashColor=NSColor()
    
        if (myMap.getTimeOfDay() < 5*60 || myMap.getTimeOfDay() > 22*60)
        {
            if nightVisionEnabled
            {
                flashColor=NSColor.green
                nv=true
            }
            else
            {
                flashColor=NSColor.white
            }
            
        }
        else
        {
            flashColor=NSColor.white
        }
        
        let flashOn=SKAction.run {
            self.nightVisionEnabled=false
            self.hudLightMask.fillColor=flashColor
            
        }
        let flashOff=SKAction.run {
            self.nightVisionEnabled=nv
            self.hudLightMask.fillColor=currentColor
        }
        
        let num=Int(random(min: 1, max: 2.99))
        let sequence=SKAction.sequence([flashOn, SKAction.fadeAlpha(to: 0.6, duration: TimeInterval(random(min: 0.01, max: 0.1))),  SKAction.wait(forDuration: TimeInterval(random(min: 0.01, max: 0.1))), SKAction.fadeAlpha(to: currentAlpha, duration: TimeInterval(random(min: 0.01, max: 0.14))), flashOff])
        var numSeq=SKAction()
        if num==1
        {
            numSeq=sequence
        }
        else if num==2
        {
            numSeq=SKAction.sequence([sequence, SKAction.wait(forDuration: TimeInterval(random(min: 0.01, max: 0.8))),sequence])
        }
        
        
        hudLightMask.run(numSeq)
        
        let thunderSound=Int(random(min: 1.0, max: 4.999999999))
        hudLightMask.run(SKAction.playSoundFileNamed("thunder0\(thunderSound).wav", waitForCompletion: false))

    } // flashLightning
    
    func updateAnimals()
    {
        for i in 0..<myMap.entList.count
        {
            let updateReturn=myMap.entList[i].update(cycle: currentCycle)
        }
        // update birds
        for i in 0..<myMap.birdList.count
        {
            myMap.birdList[i].update(cycle: currentCycle)
        }
        for i in 0..<myMap.buzzardList.count
        {
            myMap.buzzardList[i].update(cycle: currentCycle)
        }
        
        
        myMap.cleanUpEntities()
    } // func updateAnimals
    
    func updateHUD()
    {
        
        // first update the drone
        if !leftPressed && !rightPressed
        {
            droneVec.dx*=(1-DRONEINERTIA)

        } // don't apply inertia if we're accelerating on that axis
        
        if !upPressed && !downPressed
        {
            droneVec.dy*=(1-DRONEINERTIA)
        } // don't apply inertia if we're accelerating on that axis
        cam.position.x+=droneVec.dx
        cam.position.y+=droneVec.dy
        
        
        hudTimeLabel.text=myMap.getTimeAsString()
        if myMap.isRainySeason()
        {
            hudSeasonLabel.text="Rainy Season"
        }
        else
        {
            hudSeasonLabel.text="Dry Season"
        }
        hudTimeScaleLabel.text = "\(myMap.getTimeScale())x"
        
        let dx=((myMap.BOUNDARY+cam.position.x)/myMap.BOUNDARY)-1
        let dy = ((myMap.BOUNDARY+cam.position.y)/myMap.BOUNDARY)-1
        
        hudMapMarker.position.x = dx*map.size.width/2
        hudMapMarker.position.y = -dy*map.size.height/2
        
        // update altitude
        let ratio=(cam.xScale-0.5)/2.0

        let altArrowRatio=ratio-0.5
        hudAltArrow.position.y=altArrowRatio*hudAltBar.size.height*0.92
        let alt=ratio*198+51
        hudAltitudeLabel.text=String(format:"%2.0f m",alt)
        hudAltitudeLabel.position.y = altArrowRatio*hudAltBar.size.height*0.92
        
        let piDelta = -lastParkInfoUpdate.timeIntervalSinceNow
        if !hudParkInfo.isHidden && piDelta > PARKINFOUPDATEFREQ
        {
            myMap.info.updateCounts()

            lastParkInfoUpdate=NSDate()
            
        }
        

        if showYearlyChange
        {
            var sign:String=""
            hudPITotalAnimals.text="Animals: \(myMap.info.getAnimalCount())"
            
            if myMap.info.getCheetahChange() > 0
            {
                sign="+"
            }
            
            hudPICheetah.text="Cheetah: \(myMap.info.getCheetahCount()) (\(sign)\(myMap.info.getCheetahChange()))"
            if myMap.info.getWarthogChange() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPIWarthog.text="Warthogs: \(myMap.info.getWarthogCount()) ( \(sign)\(myMap.info.getWarthogChange()) )"
            if myMap.info.getSpringbokChange() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPISpringbok.text="Springbok: \(myMap.info.getSpringbokCount()) ( \(sign)\(myMap.info.getSpringbokChange()) )"
            if myMap.info.getZebraChange() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPIZebra.text="Zebra: \(myMap.info.getZebraCount()) ( \(sign)\(myMap.info.getZebraChange()) )"
            
        }
        else
        {
            var sign:String=""
            hudPITotalAnimals.text="Animals: \(myMap.info.getAnimalCount())"
            
            if myMap.info.getCheetahChangeTotal() > 0
            {
                sign="+"
            }
            
            hudPICheetah.text="Cheetah: \(myMap.info.getCheetahCount()) (\(sign)\(myMap.info.getCheetahChangeTotal()))"
            if myMap.info.getWarthogChangeTotal() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPIWarthog.text="Warthogs: \(myMap.info.getWarthogCount()) ( \(sign)\(myMap.info.getWarthogChangeTotal()) )"
            if myMap.info.getSpringbokChangeTotal() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPISpringbok.text="Springbok: \(myMap.info.getSpringbokCount()) ( \(sign)\(myMap.info.getSpringbokChangeTotal()) )"
            if myMap.info.getZebraChangeTotal() > 0
            {
                sign="+"
            }
            else
            {
                sign=""
            }
            hudPIZebra.text="Zebra: \(myMap.info.getZebraCount()) ( \(sign)\(myMap.info.getZebraChangeTotal()) )"
            

            
        }
        // update coords
        let coordX=dx*myMap.MAPWIDTH
        let coordY=dy*myMap.MAPWIDTH
        hudCoordLabel.text=String(format: "X:%3.0f, Y:%3.0f",coordX,coordY)
        
        // update speed
        let speed=hypot(droneVec.dy, droneVec.dx)
        hudSpeedLabel.text=String(format: "Speed: %2.1f",speed)
        
       
        
        
        if myMap.msg.getUnreadCount() > 0
        {
            hudMsgBG.removeAllActions()
            hudMsgBG.alpha=1.0
            hudMsgLabel.text=myMap.msg.readNextMessage()
            let runAction=SKAction.sequence([SKAction.wait(forDuration: 4.0), SKAction.fadeOut(withDuration: 1.0)])
            hudMsgBG.run(runAction)
            //msgBG.run(SKAction.fadeOut(withDuration: 5.0))
        } // if we have unread messages
    } // func updateHUD
    
    func adjustLighting()
    {
        if myMap.getTimeOfDay() < 300
        {

            if nightVisionEnabled
            {
                hudLightMask.fillColor=NSColor(calibratedRed: 0, green: 0.5, blue: 0, alpha: 1.0)
                hudLightMask.alpha=0.5
                //hudNVG.alpha=0.9
                //hudNVG.isHidden=false
            }
            else
            {
                hudLightMask.fillColor=NSColor.black
                hudLightMask.alpha=0.9
                //hudNVG.isHidden=true
            }
        }
        else if myMap.getTimeOfDay() < 480
        {
            let lightRatio = ((myMap.getTimeOfDay()-300)/180)
            let r=lightRatio
            var gb=lightRatio-0.2
            
            if gb < 0
            {
                gb = 0
            }
   

            hudLightMask.fillColor=NSColor(calibratedRed: r, green: gb, blue: gb, alpha: 1.0)
            hudLightMask.alpha -= 0.001*myMap.getTimeScale()
            if hudLightMask.alpha < 0
            {
                hudLightMask.alpha=0
            }

        } // else
        else if myMap.getTimeOfDay() < 1200 // 8pm
        {
            
            hudLightMask.alpha=0
            
            
        }
        else if myMap.getTimeOfDay() < 1320 // 10pm
        {
            let lightRatio = ((1260-myMap.getTimeOfDay())/60)
            var b=lightRatio-0.5
            var rg=lightRatio
         
           
            if rg > 1.0
            {
                rg = 1.0
            }
            if b < 0
            {
                b=0
            }
            if rg < 0
            {
                rg=0
            }

            hudLightMask.alpha += 0.002*myMap.getTimeScale()
            if hudLightMask.alpha > 0.9
            {
                hudLightMask.alpha=0.9
                
            }
            hudLightMask.fillColor=NSColor(calibratedRed: rg, green: rg, blue: b, alpha: 1.0)
        } // if between 8pm - 10pm
        else
        {

            if nightVisionEnabled
            {
                hudLightMask.fillColor=NSColor(calibratedRed: 0, green: 0.5, blue: 0, alpha: 1.0)
                hudLightMask.alpha=0.5
            }
            else
            {
                hudLightMask.fillColor=NSColor.black
                hudLightMask.alpha=0.9
            }
            
        } // if between 10pm and midnight
    } // func adjustLighting
    
    func updateWeather()
    {
        if myMap.isRainySeason()
        {
            center.color=NSColor.green
            if -lastRainChange.timeIntervalSinceNow > rainChange
            {
                if isRaining
                {
                    isRaining=false
                    rainChange=Double(random(min: 15, max: 35))
                    lastRainChange=NSDate()
                }
                else
                {
                    isRaining=true
                    rainChange=Double(random(min: 15, max: 35))
                    lastRainChange=NSDate()
                }
            } // if it's time to change the rain
            
        } // if it's rainy season
        else
        {
            isRaining=false
            center.color=NSColor.white
        } // if it's not rainy season
        
        if isRaining
        {
            rainNode!.particleBirthRate=1400
            if -lastLightning.timeIntervalSinceNow > nextLightning
            {
                flashLightning()
                nextLightning=Double(random(min: 15, max: 40))
                lastLightning=NSDate()
            } // if it's time for lightning
            
            
        } // if it's raining
        else
        {
            rainNode!.particleBirthRate=0
        } // if it's not raining
        
    } // updateWeather
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        switch currentState
        {
        case inGameState:
            myMap.timePlus()
            lastLightUpdate+=1
            if lastLightUpdate > 5
            {
                if !hudLightMask.hasActions()
                {
                    adjustLighting()
                    lastLightUpdate=0
                } //
            }
            currentCycle+=1
            if currentCycle > MAXUPDATECYCLES
            {
                currentCycle=0
            }

            updateHUD()
            checkKeys()
            checkAmbientSpawns()
            updateAnimals()
            updateWeather()
            
        case mapGenState:
                generateMap()
            
        case genMapZonesState:
            genMapZones()
           
        default:
            break
            
        } // switch currentState

        
    } // update
} // class GameScene
