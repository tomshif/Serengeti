//
//  ZebraClass.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/9/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class ZebraClass:EntityClass
{
    var counter:Int=0
    var alert:Int=0
    var temper:Int=0
    var MAXHERD:Int=30
    var MAXCHILDRENBORN:Int=2
    
    var followDistance:CGFloat=150
    var lastBaby:CGFloat=0

    
    var isSick:Bool=false
    var isFemale:Bool=false

    var isPregnant:Bool=false
    var isTranqued:Bool=false
    
    let adultTexture=SKTexture(imageNamed: "zebraVariation2Sprite")
    let babyTexture=SKTexture(imageNamed: "zebraVariation1Sprite")

    
    override init()
   
    {
        super.init()
        sprite=SKSpriteNode(imageNamed: "zebraVariation2Sprite")
    } // init
   
    override init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int)
    {
        super.init()
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "zebraVariation2Sprite")
        sprite.position=pos
        sprite.name=String(format:"entZebra%04d", number)
        name=String(format:"entZebra%04d", number)
        sprite.zPosition=100
        
        scene!.addChild(sprite)
        
        // Variable updates
        MAXSPEED=2.0
        TURNRATE=0.20
        TURNFREQ=2
        AICycle=1
        WANDERANGLE=CGFloat.pi/7
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        if age < MAXAGE*0.2
        {
            sprite.texture=babyTexture
        }
    } // full init()
    
    init(theScene:SKScene, theMap: MapClass, pos: CGPoint, number: Int, leader:EntityClass?)
    {
        super.init()
        
        if leader==nil
        {
            isHerdLeader=true
        }// if we dont have a herd leader
        else
        {
            herdLeader=leader
        }// if we have a herd leader
        
        // set the passed references
        map=theMap
        scene=theScene
        
        
        // sprite update
        sprite=SKSpriteNode(imageNamed: "zebraVariation2Sprite")
        sprite.position=pos
        sprite.name=String(format:"entZebra%04d", number)
        name=String(format:"entZebra%04d", number)
        sprite.zPosition=100
        
        scene!.addChild(sprite)
        let rC=random(min: 0.75, max: 1.0)
        let gC=random(min: 0.75, max: 1.0)
        let bC=random(min: 0.75, max: 1.0)
        sprite.colorBlendFactor=1.0
        sprite.color=NSColor(calibratedRed: rC, green: gC, blue: bC, alpha: 1.0)
        
        // Variable updates
        MAXSPEED=2.0
        TURNRATE=0.20
        TURNFREQ=2
        AICycle=1
        WANDERANGLE=CGFloat.pi/7
        MAXAGE=8640*10
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
        age=random(min: 1.0, max: MAXAGE*0.7)
        
        let maleChance=random(min: 0, max: 1)
        if maleChance > 0.75 || leader == nil
        {
            isMale=true
        }
        if age < MAXAGE*0.2
        {
            sprite.texture=babyTexture
        }
    } // full init()
    
    func catchUp()
    {
        var angle=getAngleToEntity(ent: herdLeader!)
        if angle < 0
        {
           angle+=CGFloat.pi*2
        }// if angle is below zero
        // angle=turnToAngle        // removed by Shiflet -- this is inverted
                                    // should be the other way around
        turnToAngle=angle           // added by Shiflet to fix above
        isTurning=true
        speed=herdLeader!.speed*1.05    // added by Shiflet to make sure
                                // that we can catch up
    }//func catch up
    
    
    
    func findNewHerdLeader()
    {
        var maleIndex:Int = -1
        var maleDist:CGFloat=300000
        var nearbyLeaderDist:CGFloat=300000
        var nearbyLeaderIndex:Int = -1
        
        if !isHerdLeader
        {
            for i in 0..<map!.entList.count
            {
                if map!.entList[i].getAgeString()=="Mature" && map!.entList[i].isAlive() && map!.entList[i].name.contains("Zebra")
                {
                    let dist=getDistToEntity(ent: map!.entList[i])
                    if map!.entList[i].isHerdLeader
                    {
                        if dist<nearbyLeaderDist
                        {
                            nearbyLeaderDist=dist
                            nearbyLeaderIndex=i
                        }// if distance to leader is lower than max distance

                    }// if map entlist leader
                    else if map!.entList[i].isMale
                    {
                        if dist < maleDist
                        {
                            maleDist=dist
                            maleIndex=i
                        }// male distance is lower than max distance
                    }// else
                }//if map entlist
            }// for i in map!
            if nearbyLeaderDist<3000 && nearbyLeaderIndex > -1
            {
                herdLeader=map!.entList[nearbyLeaderIndex]
                
            }// if leader dist less than 300000
            else if maleIndex > -1
            {
                herdLeader=map!.entList[maleIndex]
                map!.entList[maleIndex].isHerdLeader=true
            }//else male leader was found
            else
            {
                isHerdLeader=true
                herdLeader=nil
            } // failover to make self leader
            
        }// if no leader and am not leader
    }//func new herd leader
    
    
    
    func giveBirth()
    {
        if !isMale && getAgeString()=="Mature" && age-lastBaby > 8640
        {
            
            let spawnChance:CGFloat=random(min: 0, max: 1.00)
            if spawnChance > 0.9999875
            {
                print("Baby!")
                let baby=ZebraClass(theScene: scene!, theMap: map!, pos: sprite.position, number: map!.entityCounter, leader: self)
                map!.entList.append(baby)
                map!.msg.sendMessage(type: map!.msg.BIRTH, from: name)
                map!.entityCounter+=1
                lastBaby=age
                
            }
        }

    }// func give birth
    
    
    
   override internal func update(cycle: Int) -> Int
    {
        var ret:Int = -1
        giveBirth()
        doTurn()
        updateGraphics()
        
        if age > MAXAGE*0.2 && sprite.texture==babyTexture
        {
            sprite.texture=adultTexture
        }
        
        if alive
        {
            if !ageEntity()
            {
                ret=2
            } // we're able to age, if we die, set return death code
        } // if we're alive
        
        if cycle==AICycle
        {
            if currentState==WANDERSTATE
            {
                // wander() -- removed by Shiflet -- should not wander AND have
                // the opportunity to pursue the herdLeader...should be OR
                if herdLeader != nil && !isHerdLeader
                {
                    if getDistToEntity(ent: herdLeader!) > followDistance
                    {
    
                        catchUp()
                    }//if distance to entity is greater than follow distance
                    else // added by Shiflet -- the OR part
                    {
                        wander()
                    }
                }
                else
                {
                    wander()
                }// else wander
            }//if current state = wander state
            

            if herdLeader != nil
            {
                if !herdLeader!.isAlive()
                {
                    findNewHerdLeader()
                    
                }
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
}// zebra class
