//
//  CheetahClass.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/7/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//
//
import Foundation
import SpriteKit
class CheetahClass:EntityClass
{
    var MAXHERD:Int = 1
    var MAXCHILD:Int = 2
    var isPregnant:Bool = false
    var isChasing:Bool = false // I would recommend doing this more as "var lastMeal:Int=0"
    var isClose:Bool = false        // close to what?
    var isTravel:Bool = false       // travel?
    var cubs:Bool = false
    var followDist:CGFloat = 400
    var lastBaby:CGFloat = 0
    var preyTarget:EntityClass?
    var lastPreyCheck = NSDate()
    var getDiseaseDay:CGFloat = 6
    var timePassed:CGFloat = 0
    var diseaseDay:Int=0
    var diseaseHour:CGFloat=0
    var targetZone:ZoneClass?
    
    override init()
    {
        super.init()
        sprite=SKSpriteNode(imageNamed: "cheetahSprite")
    } // init
    
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "cheetahSprite")
        sprite.position=pos
        sprite.name=String(format:"entCheetah%04d", number)
        name=String(format:"entCheetah%04d", number)
        sprite.zPosition=120
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=6.5
        TURNRATE=0.15
        TURNFREQ=3
        AICycle=0
        MAXAGE=8*8640
        MAXAGE=random(min: MAXAGE*0.7, max: MAXAGE*1.0) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        
        
        
    } // full init()
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, leader: EntityClass?)
    {
        super.init()
        
        MAXAGE=8*8640
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual

        let chance = random(min: 0, max: 1)
        if chance > 0.6
        {
            isMale = true
        }
        
        if leader == nil
        {
            isHerdLeader = true
            age=random(min: MAXAGE*0.3, max: MAXAGE*0.7)
        }// if leader
        else
        {
            herdLeader = leader
            age=random(min: 1.0, max: MAXAGE*0.1)
        }// else leader
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "cheetahSprite")
        sprite.position=pos
        sprite.name="cheetah"
        sprite.name=String(format:"entCheetah%04d", number)
        name=String(format:"entCheetah%04d", number)
        sprite.zPosition=120
        
        scene!.addChild(sprite)
        
        let rC=random(min: 0.85, max: 1.0)
        let gC=random(min: 0.85, max: 1.0)
        let bC=random(min: 0.85, max: 1.0)
        sprite.colorBlendFactor=1.0
        sprite.color=NSColor(calibratedRed: rC, green: gC, blue: bC, alpha: 1.0)
        
        
        // Variable updates
        MAXSPEED=6.5
        TURNRATE=0.15
        TURNFREQ=3
        AICycle=0
        ACCELERATION=0.45
        TURNSPEEDLOST=0.25
    } // full init()
    
    func catchUp()
    {
        var angle = getAngleToEntity(ent: herdLeader!)
        if angle < 0
        {
            angle += CGFloat.pi*2
        }
        turnToAngle=angle
        isTurning=true
        speed = MAXSPEED * 0.45
    }// func catchUp
    
    
    override func update(cycle: Int) -> Int
    {
        
        
        var ret:Int = -1
        
        doTurn()
        updateGraphics()
        Baby()
        Stam()
        meal()
        
        if herdLeader == nil
        {
            border()
        }
        sprite.zPosition = age + 120
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
                let chance=random(min: 0, max: 1)
                if chance > 0.99999999995
                {
                    catchDisease()
                }
            } // we're able to age, if we die, set return death code
        } // if we're alive
        
        if isDiseased && map!.getDay() != diseaseDay && diseaseHour > map!.getTimeOfDay()
        {
            die()
            map!.msg.sendMessage(type: map!.msg.DEATH_DISEASE, from: self.name)
        }
        
        if cycle==AICycle
        {
        
            if (-lastPreyCheck.timeIntervalSinceNow > 1.0 && stamina > 0.85) || (-lastPreyCheck.timeIntervalSinceNow > 1.0 && hunger < 0.15 )
            {
                checkPrey()
                lastPreyCheck = NSDate()

            }// if -lastPreyCheck
            if currentState==WANDERSTATE
            {
                if herdLeader != nil && !isHerdLeader
                {
                    if getDistToEntity(ent: herdLeader!) > followDist
                    {
                        catchUp()
                    }
                    else
                    {
                        wander()
                    }
                }//if herdleader
                else
                {
                    wander()
                }
            }
            else if currentState == HUNTSTATE
            {
                hunt()
            }
            else if currentState==GOTOSTATE
            {
                goTo()
            }
            
            // fix it if our rotation is more than pi*2 or less than 0
            if sprite.zRotation > CGFloat.pi*2
            {
                sprite.zRotation -= CGFloat.pi*2
            }
            if sprite.zRotation < 0
            {
                sprite.zRotation += CGFloat.pi*2
            }
            
            if getAgeString() == "Mature"
            {
                herdLeader = nil
            }
            
            
        } // if it's our update cycle
        
        return ret
        
    } // func update
    
    private func checkPrey()
    {
        var closest:CGFloat=5000000000
        var closestIndex:Int = -1
        
        for i in 0..<map!.entList.count
        {
            if !map!.entList[i].name.contains("Cheetah")
            {
                if !(map!.entList[i].name.contains("Zebra") && map!.entList[i].getAgeString() == "Mature")
                {
                    wander()
                }
                if !(map!.entList[i].name.contains("Zebra") && map!.entList[i].getAgeString() == "Mature" && isDiseased == true)
                {
                    let dist = getDistToEntity(ent: map!.entList[i])
                    if dist < closest
                    {
                        closest=dist
                        closestIndex=i
                    }// if we've found a closer one
                }
            }// if it's a cheetah
        
        }//for each entity
    
        if closestIndex > -1 && closest < 900
        {
            currentState = HUNTSTATE
            preyTarget = map!.entList[closestIndex]
            print("Prey within Range")
        }// if closestIndex
        else
        {
            currentState = WANDERSTATE
        }
    }// func checkPrey()
    
    private func hunt()
    {
        if preyTarget != nil && getAgeString()=="Baby" && getAgeString()=="Juvinile" && herdLeader!.currentState == HUNTSTATE
        {
            speed = 0
            if herdLeader?.currentState == WANDERSTATE
            {
                catchUp()
                Stam()
            }// herdLeader?
        }//if preyTarget
        if preyTarget != nil && getAgeString()=="Mature"
        {
            isChasing = true
            stamina -= 0.0115 *  map!.getTimeScale()
            var angle = getAngleToEntity(ent: preyTarget!)
            if speed > MAXSPEED
            {
                ACCELERATION = 0
                speed = MAXSPEED
            }
            if angle > CGFloat.pi*2
            {
                angle -= CGFloat.pi*2
            }
            if angle < 0
            {
                angle += CGFloat.pi*2
            }
            
            turnToAngle = angle
            isTurning = true
            speed += ACCELERATION
            if speed > MAXSPEED
            {
                speed = MAXSPEED
            }
            let dist = getDistToEntity(ent: preyTarget!)
            if dist < 20
            {
                if preyTarget!.isDiseased == true
                {
                    let chance = random(min: 0, max: 1)
                    if chance > 0.95
                    {
                        catchDisease()
                    }
                }// preyTarget
                map!.msg.sendMessage(type: map!.msg.DEATH_PREDATOR, from: preyTarget!.name)
                preyTarget!.die()
                preyTarget = nil
                border()
                currentState = WANDERSTATE
                speed=0
                hunger = 1.0
                Stam()
            }// dist < 20
            if stamina < 0
            {
                stamina = 0.3
                currentState = WANDERSTATE
                preyTarget = nil
                border()
                map!.msg.sendMessage(type: map!.msg.HUNTFAILED, from: self.name)
            }// if stamina < 0
            
        }// if predator is valid
        
    }// func flee
    
    func Baby()
    {

        
        if age - lastBaby > 12960 && !isMale && getAgeString()=="Mature" && preyTarget == nil
        {
           
            let chance=random(min: 0, max: 1)
            if chance > 0.9995
            {
                let temp = CheetahClass(theScene: scene!, theMap: map!, pos: sprite.position, number: map!.entityCounter, leader: self)
                
                let chance = random(min: 0, max: 0.6)
                if chance > 0.6
                {
                    isMale = true
                }
                
                map!.entityCounter+=1
                
                map!.predList.append(temp)
                map!.msg.sendMessage(type: map!.msg.BORN, from: name)
                lastBaby = age
            }// if chance > 0.9995
        }// if age - lastBaby
    }// func Baby
    
    func border()
    {
        if currentState == WANDERSTATE
        {
        if sprite.position.x > map!.BOUNDARY*0.95
        {
            gotoLastState = currentState
            currentState = GOTOSTATE
            gotoPoint.y = sprite.position.y
            gotoPoint.x = map!.BOUNDARY*0.8
        }// sprite x
        if sprite.position.x < -map!.BOUNDARY*0.95
        {
            gotoLastState = currentState
            currentState = GOTOSTATE
            gotoPoint.y = sprite.position.y
            gotoPoint.x = -map!.BOUNDARY*0.8
        }// sprite -x
        if sprite.position.y > map!.BOUNDARY*0.95
        {
            gotoLastState = currentState
            currentState = GOTOSTATE
            gotoPoint.y = map!.BOUNDARY*0.8
            gotoPoint.x = sprite.position.x
        }// sprite y
        if sprite.position.y < -map!.BOUNDARY*0.95
        {
            gotoLastState = currentState
            currentState = GOTOSTATE
            gotoPoint.y = -map!.BOUNDARY*0.8
            gotoPoint.x = sprite.position.x
        }// sprite -y
        }
    }//border
    
    
    override func catchDisease()
    {
        isDiseased = true
        map!.msg.sendMessage(type:map!.msg.INFECTED, from: self.name)
        diseaseHour=map!.getTimeOfDay()
        diseaseDay=map!.getDay()
    }// override catchDisease
    
    func Stam()
    {
        if currentState != HUNTSTATE
            {
                stamina += 0.00002 * map!.getTimeScale()
            }
        if stamina > 1.0
            {
            stamina = 1.0
            }
        if stamina < 0.85 && currentState == WANDERSTATE
            {
                if targetZone != nil
                    {
                        if targetZone!.type == ZoneType.RESTZONE
                            {
                                let dist = getDistanceToZone(zone: targetZone!)
                                if dist > 400
                                    {
                                        currentState = WANDERSTATE
                                    }
                                if dist < 400
                                    {
                                        speed = 0
                                        stamina += 0.0008
                                    }
                                if isHerdLeader == false
                                {
                                    let dist=getDistToEntity(ent: herdLeader!)
                                    
                                    if dist < 50
                                    {
                                        speed = 0
                                    }
                                        
                                }// isHerdLeader == false
                            }//if targetZone!
                        else
                            {
                                targetZone = findZone(type: ZoneType.RESTZONE)
                            }// else
                        currentState=GOTOSTATE
                        targetZone!.sprite.position = gotoPoint
                        
                    }// targetZone != nil
                else
                {
                    targetZone = findZone(type: ZoneType.RESTZONE)
                }
        }// if stamina < 0.853
    }// func Stam
    
    func meal()
    {
        if currentState != HUNTSTATE
        {
            hunger -= 0.000004 * map!.getTimeScale()
        }
        if hunger == 0
        {
            hunger = 0
            die()
        }// hunger = 0
        if hunger == 1.0
        {
            hunger = 1.0
        }
    }// meal()
    
} // CheetahClass



