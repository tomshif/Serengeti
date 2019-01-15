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

var treeMaster=SKSpriteNode(imageNamed: "tree01")

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
    let TREECOUNT:Int=1000
    
    var mapGenDelay:Int=0
    
    
    
    var myMap=MapClass()
    
    // Integers
    var currentState:Int=0
    var waterZonesSpawned:Int=0
    var restZonesSpawned:Int=0
    var foodZonesSpawned:Int=0
    var currentCycle:Int=0
    var testEntitiesSpawned:Int=0
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
    let droneHUD=SKSpriteNode(imageNamed: "droneHUD")
    let hudTimeBG=SKSpriteNode(imageNamed: "hudTimeBG")
    let hudMsgBG=SKSpriteNode(imageNamed: "hudTimeBG")
    let hudNVG=SKSpriteNode(imageNamed: "hudNightVision")
    
    
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
    
    
    
    // Booleans
    var leftPressed:Bool=false
    var rightPressed:Bool=false
    var upPressed:Bool=false
    var downPressed:Bool=false
    var zoomOutPressed:Bool=false
    var zoomInPressed:Bool=false
    var nightVisionEnabled:Bool=true
    
    // Camera
    var cam=SKCameraNode()
    
    

    
    
    
    
    override func didMove(to view: SKView) {
        
        light.ambientColor=NSColor.black
        light.lightColor=NSColor.yellow
        light.isEnabled=false
        light.falloff=1.5
        light.categoryBitMask=1
        light.shadowColor=NSColor.black
        light.name="playerLight"
        droneHUD.addChild(light)
        

        self.camera=cam
        addChild(cam)
        
        let hudLightMaskRect=CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
        hudLightMask=SKShapeNode(rect: hudLightMaskRect)
        hudLightMask.fillColor=NSColor.init(calibratedRed: 0, green: 0.5, blue: 0, alpha: 1.0)
        hudLightMask.strokeColor=NSColor.systemGreen
        hudLightMask.alpha=0.5
        hudLightMask.isHidden=true
        
        hudLightMask.zPosition=4999
        cam.addChild(hudLightMask)
        
        center.zPosition = -100
        addChild(center)
        
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
        
        hudTimeBG.position.x = -size.width/2+hudTimeBG.size.width/2
        hudTimeBG.position.y = size.height/2-hudTimeBG.size.height/2
        hudTimeBG.isHidden=true
        hudTimeBG.zPosition=5000
        cam.addChild(hudTimeBG)
        
        hudTimeLabel.text="Time"
        hudTimeLabel.fontSize=20
        hudTimeLabel.zPosition=5001
        hudTimeBG.addChild(hudTimeLabel)
        
        hudTimeScaleLabel.text="TimeScale"
        hudTimeScaleLabel.fontSize=20
        hudTimeScaleLabel.zPosition=5001
        hudTimeScaleLabel.position.y = -hudTimeBG.size.height*0.2
        hudTimeBG.addChild(hudTimeScaleLabel)
        
        hudMsgBG.position.x = -size.width/2+hudTimeBG.size.width/2
        hudMsgBG.position.y = -size.height/2+hudTimeBG.size.height/2
        hudMsgBG.alpha=0.0
        hudMsgBG.zPosition=5000
        cam.addChild(hudMsgBG)
        
        hudMsgLabel.text="Message"
        hudMsgLabel.fontSize=16
        hudMsgLabel.zPosition=5001
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
            
        case 37: // L
            if currentState==inGameState
            {
                if light.isEnabled
                {
                    light.isEnabled=false
                    hudLightMask.isHidden=false
                }
                else
                {
                    light.isEnabled=true
                    hudLightMask.isHidden=true
                }
            }
            
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
            print("Water zone #\(waterZonesSpawned)")
            mmGenSplinesLabel.text="Reticulating splines: 100%"
            mmGenWaterLabel.text=String(format: "Hitting the hot tub: %2.0f%%", (CGFloat(waterZonesSpawned)/CGFloat(WATERZONECOUNT))*100)
            
        } // if we need to spawn a water zone
        else if restZonesSpawned < RESTZONECOUNT
        {
            genRestZone(theMap: myMap, theScene: self)
            restZonesSpawned += 1
            print("Rest Zone # \(restZonesSpawned)")
            mmGenRestLabel.text=String(format: "Taking a nap: %2.0f%%", (CGFloat(restZonesSpawned)/CGFloat(RESTZONECOUNT))*100)
        } // if we need to spawn a rest zone
        else if foodZonesSpawned < FOODZONECOUNT
        {
            genFoodZone(theMap: myMap, theScene: self)
            foodZonesSpawned += 1
            print("Food Zone # \(foodZonesSpawned)")
            mmGenFoodLabel.text=String(format: "Cooking dinner: %2.0f%%", (CGFloat(foodZonesSpawned)/CGFloat(FOODZONECOUNT))*100)
        } // if we need to spawn a food zone
        else if treesSpawned < TREECOUNT
        {
            drawTree(theMap: myMap, theScene: self)
            treesSpawned+=10
            mmGenTreeLabel.text=String(format: "Tending the garden: %2.0f%%", (CGFloat(treesSpawned)/CGFloat(TREECOUNT))*100)
            
        } // if we need to spawn trees
        else if testEntitiesSpawned < TESTENTITYCOUNT
        {
            mmGenAnimalsLabel.text=String(format: "Rescuing pit bulls: %2.0f%%", (CGFloat(testEntitiesSpawned)/(CGFloat(TESTENTITYCOUNT)+CGFloat(BUZZARDCOUNT))*100))
            let x=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let y=random(min: -myMap.BOUNDARY*0.8, max: myMap.BOUNDARY*0.8)
            let pos = CGPoint(x: x, y: y)
            spawnHerd(type: ENTITYHERD, loc: pos)
            testEntitiesSpawned += 1

            
        } // if we need to spawn animals
        else if buzzardsSpawned < BUZZARDCOUNT
        {
            mmGenAnimalsLabel.text=String(format: "Rescuing pit bulls: %2.0f%%", ((CGFloat(buzzardsSpawned)+CGFloat(testEntitiesSpawned))/(CGFloat(TESTENTITYCOUNT)+CGFloat(BUZZARDCOUNT))*100))
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
        } // if we're finished generating map
        
    } // genMapZones
    
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
            let tempLeader=TestClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: entityHerdCount)
            print(tempLeader.name)
            
            tempLeader.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
            myMap.entList.append(tempLeader)
            entityHerdCount+=1
            
            for _ in 1...herdsize
            {
                
                let tempEnt=TestClass(theScene: self, theMap: myMap, pos: CGPoint(x: random(min: loc.x-size.width/10, max: loc.x+size.width/10), y: random(min: loc.y-size.height/10, max: loc.y+size.height/10)), number: entityHerdCount, ldr: tempLeader)
                print(tempEnt.name)
                
                tempEnt.sprite.zRotation=random(min: 0, max: CGFloat.pi*2)
                myMap.entList.append(tempEnt)
                entityHerdCount+=1
                
            } // for each member of the herd
            
        } // if we're spawning EntityClass
        
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
        hudTimeLabel.text=myMap.getTimeAsString()
        hudTimeScaleLabel.text = "\(myMap.getTimeScale())x"
        
        let dx=((myMap.BOUNDARY+cam.position.x)/myMap.BOUNDARY)-1
        let dy = ((myMap.BOUNDARY+cam.position.y)/myMap.BOUNDARY)-1
        
        hudMapMarker.position.x = dx*map.size.width/2
        hudMapMarker.position.y = -dy*map.size.height/2
        
        
        //print("Map Marker X: \(dx)")
        
        
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
            light.ambientColor=NSColor.black
            light.falloff=1.5
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
            //print("Ratio: \(lightRatio)")
            //print("RGB: \(r), \(gb), \(gb)")
            light.ambientColor=NSColor(calibratedRed: r, green: gb, blue: gb, alpha: 1.0)
            hudLightMask.fillColor=NSColor(calibratedRed: r, green: gb, blue: gb, alpha: 1.0)
            hudLightMask.alpha -= 0.001*myMap.getTimeScale()
            if hudLightMask.alpha < 0
            {
                hudLightMask.alpha=0
            }
            light.falloff+=0.01
            if light.falloff > 5.0
            {
                light.falloff = 5.0
            }
        }
        else if myMap.getTimeOfDay() < 1200
        {
            light.ambientColor=NSColor.white
            hudLightMask.alpha=0
            light.falloff=5.0
            
        }
        else if myMap.getTimeOfDay() < 1320
        {
            let lightRatio = ((1320-myMap.getTimeOfDay())/120)
            let b=lightRatio
            var rg=lightRatio*1.5
            print("Ratio: \(lightRatio)")
            //print("RGB: \(rg), \(rg), \(b)")
            if rg > 1.0
            {
                rg = 1.0
            }
            light.ambientColor=NSColor(calibratedRed: rg, green: rg, blue: b, alpha: 1.0)
            light.falloff -= 0.01
            if light.falloff < 2.5
            {
                light.falloff=5.0
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
            light.ambientColor=NSColor.black
            light.falloff = 1.5
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        switch currentState
        {
        case inGameState:
            myMap.timePlus()
            lastLightUpdate+=1
            if lastLightUpdate > 4
            {
                adjustLighting()
                lastLightUpdate=0
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
            
            
            
        case mapGenState:
            mapGenDelay += 1
            if mapGenDelay > 10
            {
                generateMap()
            }
            
        case genMapZonesState:
            genMapZones()
           
        default:
            break
            
        } // switch currentState

        
    } // update
} // class GameScene
