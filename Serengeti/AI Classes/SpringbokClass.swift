//
//  Springbok.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/9/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class SpringbokClass:EntityClass
{
    private var isPregnant:Bool=false
    private var isCloseToCheetah:Bool=false  // is close to what?
   
    public var MAXHERD:Int=25
    public var MINHERD:Int=15
    private var MAXCHILD:Int=2
    
    private var diseaseHour:CGFloat=0
    private var diseaseDay:Int = -500
    internal var followDist:CGFloat=150
    internal var followDistVar:CGFloat=0
    
    var targetZone:ZoneClass?
    
    let adultTexture=SKTexture(imageNamed: "springbokAdultSprite")
    let babyTexture=SKTexture(imageNamed: "springbokBabySprite")
    private var lastBabyYear:Int=0
    
    
    
    override init()
    {
        super.init()
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
    } // init
    
    
    
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
        sprite.position=pos
        sprite.name=String(format:"entSpringbok%04d", number)
        name=String(format:"entSpringbok%04d", number)
        sprite.zPosition=140
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=5.1
        TURNRATE=0.15
        TURNFREQ=1.0
        WANDERANGLE=CGFloat.pi/2
        AICycle=0
        ACCELERATION=0.25
        MAXAGE=7*8640
        followDistVar=random(min: -followDist*0.2, max: followDist*0.65)
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        if (age < MAXAGE*0.2)
        {
            sprite.texture=babyTexture
        }
        
    } // full init()
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, leader: EntityClass?)
    {
    
        super.init()
    
        let chance = random(min: 0, max: 1)
        if chance > 0.6
        {
            isMale=true
        }
        else
        {
            isMale=false
        }
        
        
        if leader==nil
        {
            isHerdLeader = true
        }
        
        else
        {
            herdLeader=leader
        }
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "springbokAdultSprite")
        sprite.position=pos
        sprite.name=String(format:"entSpringbok%04d", number)
        name=String(format:"entSpringbok%04d", number)
        sprite.zPosition=140
        
        scene!.addChild(sprite)
        
        let rC=random(min: 0.85, max: 1.0)
        let gC=random(min: 0.85, max: 1.0)
        let bC=random(min: 0.85, max: 1.0)
        sprite.colorBlendFactor=1.0
        sprite.color=NSColor(calibratedRed: rC, green: bC, blue: bC, alpha: 1.0)
        
        
        // Variable updates
        MAXSPEED=5.1
        TURNRATE=0.1
        TURNFREQ=1
        WANDERANGLE=CGFloat.pi/8
        AICycle=0
        ACCELERATION=0.325
        MAXAGE=7*8640
        TURNSPEEDLOST=0.15
        followDistVar=random(min: -followDist*0.2, max: followDist*0.65)
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        
        
        
        if leader==nil
        {
            age=random(min: MAXAGE*0.4, max: MAXAGE*0.6)
            isMale=true
        }
        if (age < MAXAGE*0.2)
        {
            sprite.texture=babyTexture
        }
    } // full init()
    
   func checkHerdLeader()
   {
    var maleIndex:Int = -1
    var maleDistance:CGFloat=500000000
    var closestLeaderDist:CGFloat=500000000
    var closestLeaderIndex:Int = -1
    
        for i in 0..<map!.entList.count
        {
            if map!.entList[i].getAgeString()=="Mature" && map!.entList[i].isAlive() && map!.entList[i].name.contains("Springbok")
            {
                let dist = getDistToEntity(ent: map!.entList[i])
                
               if map!.entList[i].isHerdLeader
               {
                    if dist < closestLeaderDist
                    {
                        closestLeaderDist = dist
                        closestLeaderIndex = i
                    }//if dist < closestLeaderDist
                }//if map!.entList[i].isHerdLeader
                else
               {
                    if dist < maleDistance && map!.entList[i].isMale
                    {
                        maleDistance = dist
                        maleIndex = i
                    }//male distance
                }//else
            }//if male, alive, mature
        }//for statement
        if closestLeaderDist < 5000
        {
            herdLeader=map!.entList[closestLeaderIndex]
            
            map!.entList[closestLeaderIndex].herdLeader=nil
        }// closest leader dist
        else if maleIndex > -1
        {
            herdLeader=map!.entList[maleIndex]
            map!.entList[maleIndex].isHerdLeader=true
            map!.entList[maleIndex].herdLeader=nil
        }
        else
        {
            herdLeader=nil
            isHerdLeader=true
    }
    
    }//check herdleader
    
    override func catchDisease()
    {
        diseaseHour=map!.getTimeOfDay()
        diseaseDay=map!.getDay()
        isDiseased=true
        map!.msg.sendMessage(type: map!.msg.INFECTED, from: self.name)
    }
    
    
    
    
    private func flee()
    {
        if predTarget != nil
        {
            var angle=getAngleToEntity(ent: predTarget!)
            speed+=ACCELERATION
            if speed > MAXSPEED
            {
                speed = MAXSPEED
            }
             if -lastFleeTurn.timeIntervalSinceNow > 1.0
             {
                if angle > CGFloat.pi*2
                {
                    angle -= CGFloat.pi * 2
                }
                if angle < 0
                {
                    angle += CGFloat.pi*2
                }
                angle += CGFloat.pi
                turnToAngle=angle
                isTurning=true
                
                

                
                
                
                let offset:CGFloat=random(min: -CGFloat.pi/2, max: CGFloat.pi/2)
                lastFleeTurn=NSDate()
                    var tempAngle=offset + angle
                
                
               if tempAngle > CGFloat.pi*2
               {
                tempAngle -= CGFloat.pi*2
                }
                if tempAngle < 0
                {
                    tempAngle += CGFloat.pi*2
                }
                isTurning=true
                turnToAngle=tempAngle
            
            }
            
        }
    }
    
    func offMap()
    {
        if isHerdLeader==true && currentState != GOTOSTATE
        {
            if sprite.position.x > map!.BOUNDARY*0.95
            {
                gotoLastState = currentState
                currentState = GOTOSTATE
                gotoPoint.y = sprite.position.y
                gotoPoint.x = map!.BOUNDARY*0.8 - 200
            }
            if sprite.position.x < -map!.BOUNDARY*0.95
            {
                gotoLastState = currentState
                currentState = GOTOSTATE
                gotoPoint.y = sprite.position.y
                gotoPoint.x = map!.BOUNDARY*0.8 + 200
            }
            if sprite.position.y > map!.BOUNDARY*0.95
            {
                gotoLastState = currentState
                currentState = GOTOSTATE
                gotoPoint.y = map!.BOUNDARY*0.8 - 200
                gotoPoint.x = sprite.position.x
            }
            if sprite.position.y < -map!.BOUNDARY*0.95
            {
                gotoLastState = currentState
                currentState = GOTOSTATE
                gotoPoint.y = map!.BOUNDARY*0.8 + 200
                gotoPoint.x = sprite.position.x
            }
        }
        
        
        
        
        
        
    }
    
    func dailyRoutine()
    {
        
        if (map!.getTimeOfDay()<300 || map!.getTimeOfDay()>1200) && currentState != GOTOSTATE
        {
            var resting:Bool=false
            
            if targetZone == nil
            {
                targetZone = findZone(type: ZoneType.RESTZONE)
                
            }
            if targetZone != nil
            {
                if targetZone!.type != ZoneType.RESTZONE
                {
                    targetZone = findZone(type: ZoneType.RESTZONE)
                }
                gotoPoint=targetZone!.sprite.position
                gotoLastState=currentState
                currentState=GOTOSTATE
                
            }
            if currentState==GOTOSTATE
            {
                
                let dist=getDistanceToZone(zone: targetZone!)
                if dist < 200
                {
                    
                    
                    currentState=WANDERSTATE
                    speed=MAXSPEED*0
                    targetZone=nil
                    isResting=true
                    
                    if !isHerdLeader && herdLeader != nil  &&  resting==true
                    {
                        speed=herdLeader!.speed
                    }
                    
                }// if distance is less than 50
            }// if we're in wander state
        }// if its between 300 and 1200
            
        else if (map!.getTimeOfDay()<420)
        {
            if targetZone == nil
            {
                targetZone = findZone(type: ZoneType.WATERZONE)
            }
            if targetZone != nil
            {
                
                
                gotoPoint=targetZone!.sprite.position
                gotoLastState=currentState
                currentState=GOTOSTATE
                
            }
            if currentState==GOTOSTATE
            {
                let dist=getDistanceToZone(zone: targetZone!)
                
                if dist < 500
                {
                    
                    
                    currentState=WANDERSTATE
                    speed=MAXSPEED*0.2
                    targetZone=nil
                }// if distance is less than 50
            }// if we're in wander state
        }// if its between 300 and 420
            
        else if (map!.getTimeOfDay()<600)
        {
            print("Time for Food")
            if targetZone == nil
            {
                print("target zone was nil")
                targetZone = findZone(type: ZoneType.FOODZONE)
                print("Target zone: \(targetZone)")
            }
            if targetZone != nil
            {
                if targetZone!.type != ZoneType.FOODZONE
                {
                    print("Target Zone was not food")
                    targetZone = findZone(type: ZoneType.FOODZONE)
                    print("Target zone: \(targetZone)")
                }
                
                gotoPoint=targetZone!.sprite.position
                gotoLastState=currentState
                currentState=GOTOSTATE
                
            }
            if currentState==GOTOSTATE
            {
                
                let dist=getDistanceToZone(zone: targetZone!)
                if dist < 500
                {
                    
                    
                    currentState=WANDERSTATE
                    speed=MAXSPEED*0.2
                    targetZone=nil
                }// if distance is less than 50
            }// if we're in wander state
        }// if its between 420 and 600
        /*
         else
         {
         currentState=WANDERSTATE
         
         }
         */
    }//daily routine function
    
    
    private func checkPredators()
    {
        
        var closest:CGFloat=50000000000
        var closestIndex:Int = -1
        
        if map!.predList.count > 0
        {
            for i in 0...map!.predList.count - 1
            {
                if map!.predList[i].name.contains("Cheetah")
                {
                    let dist = getDistToEntity(ent: map!.predList[i])
                    if dist<closest
                    {
                        closest=dist
                        closestIndex=i
                    }
                }
            } // for each predator
            
            if closestIndex > -1 && closest < 800
            {
                isFleeing = true
                predTarget=map!.predList[closestIndex]
                //print("Predator is close")
            }
            else
            {
                isFleeing=false
                predTarget=nil
            }
        } // if predators exist
    } // func checkPredators
    
    override func ageEntity() -> Bool
    {
        age += map!.getTimeInterval()*map!.getTimeScale()
        
        let chance = random(min: 0, max: 1)
        if chance > 0.999999999995
        {
            catchDisease()
        }
        
        
        if age > MAXAGE
        {
            map!.msg.sendMessage(type: 8, from: name)
            let deathAction=SKAction.sequence([SKAction.fadeOut(withDuration: 2.5),SKAction.removeFromParent()])
            sprite.run(deathAction)
            alive=false
            return false
        } // if we die of old age
        else
        {
            let ageRatio=age/(MAXAGE*0.5)
            var scale:CGFloat=ageRatio
            if scale < MINSCALE
            {
                scale=MINSCALE
            }
            if scale > MAXSCALE
            {
                scale = MAXSCALE
            }
            sprite.setScale(scale)
            
            
            
            // Baby time!
            if map!.getDay() >= 1 && map!.getDay() <= 3 && !isMale && self.getAgeString()=="Mature" && herdLeader != nil && map!.getYear()-lastBabyYear > 0 && isFleeing==false
            {
                let babyChance=random(min: 0.0, max: 1.0)
                if babyChance > 0.9999994
                {
                    // Hurray! We're having a baby!
                    let babyNumber=Int(random(min: 2, max: 5.999999))
                    for _ in 1...babyNumber
                    {
                        let baby=SpringbokClass(theScene: scene!, theMap: map!, pos: self.sprite.position, number: map!.entityCounter, leader: self)
                        map!.entList.append(baby)
                        map!.entityCounter+=1
                        
                    } // for each baby
                    lastBabyYear=map!.getYear()
                    map!.msg.sendMessage(type: 20, from: self.name)
                    let chance = random(min: 0, max: 1)
                    if chance > 0.6
                    {
                        isMale=true
                    }
                    else
                    {
                        isMale=false
                    }
                    
                } // if we're having a baby
                
                
                
            } // if it's dry season and we're female and we're "mature" and we have a herd leader and we haven't had babies this year
            
            
            return true
        } // if we're still alive
        
        

    } // func ageEntity
    
    
    
    func catchUp()
    {
        var angle = getAngleToEntity(ent: herdLeader!)
        if angle < 0
        {
            angle += CGFloat.pi*2
        }
        turnToAngle=angle
        isTurning=true
        speed = herdLeader!.speed * 1.05
    }
    
    override func update(cycle: Int) -> Int
    {
        if herdLeader != nil
        {
            if (!herdLeader!.isAlive())
            {
              checkHerdLeader()
            }
        }
        
        if isFleeing && predTarget != nil
        {
            flee()
        }
        
        var ret:Int = -1
        if age > MAXAGE*0.2 && sprite.texture==babyTexture
        {
            sprite.texture=adultTexture
        }
        doTurn()
        updateGraphics()
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
            } // we're able to age, if we die, set return death code
        } // if we're alive
        
        if isDiseased && map!.getTimeOfDay() > diseaseHour && map!.getDay() != diseaseDay
        {

            die()
            map!.msg.sendMessage(type: map!.msg.DEATH_DISEASE, from: self.name)
        }
        
        
        
        if cycle==AICycle
        {
            if isHerdLeader==true
            {
                dailyRoutine()
            }
            sprite.zPosition = age/8640 + 140
            
            
            if -lastPredCheck.timeIntervalSinceNow > 1.0
            {
                checkPredators()
                lastPredCheck=NSDate()
            }
            offMap()

            if currentState==WANDERSTATE && !isFleeing
            {
                if herdLeader != nil && !isHerdLeader
                {
                    if getDistToEntity(ent: herdLeader!) > followDist + followDistVar
                    {
                        catchUp()
                    }
                    else
                    {
                        wander()
                    }
                }
                else
                {
                    wander()
                }
               
            }
            else if currentState == GOTOSTATE
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
            
            
        } // if it's our update cycle
        
        return ret
        
    } // func update

} // class SpringbokClass

//map!.entList[i]



