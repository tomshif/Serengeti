//
//  CheetahClass.swift
//  AITestBed
//
//  Created by Game Design Shared on 1/7/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit
class CheetahClass:EntityClass
{
    var MAXHERD:Int = 1
    var MAXCHILD:Int = 2
    var isPregnant:Bool = false
    var isChasing:Bool = false
    var lastMeal:Bool = false     // I would recommend doing this more as "var lastMeal:Int=0"
    var isClose:Bool = false        // close to what?
    var isTravel:Bool = false       // travel?
    var cubs:Bool = false
    var followDist:CGFloat = 400
    var lastBaby:CGFloat = 0
    
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
        MAXSPEED=3
        TURNRATE=0.15
        TURNFREQ=3
        AICycle=0
        MAXAGE=8*8640
        MAXAGE=random(min: MAXAGE*0.8, max: MAXAGE*1.4) // adjust max age to the individual
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
        }
        else
        {
            herdLeader = leader
            age=random(min: 1.0, max: MAXAGE*0.1)
        }
        
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
        MAXSPEED=3
        TURNRATE=0.15
        TURNFREQ=3
        AICycle=0
        
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
    }
    
    
    override func update(cycle: Int) -> Int
    {
        
        
        var ret:Int = -1
        
        doTurn()
        updateGraphics()
        Baby()
        
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
                }
                else
                {
                    wander()
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
            
            if getAgeString() == "Mature"
            {
                herdLeader = nil
            }
            
            
        } // if it's our update cycle
        
        return ret
        
    } // func update
    
    func Baby()
    {

        
        if age - lastBaby > 8640 && !isMale && getAgeString()=="Mature"
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
                
                map!.entList.append(temp)
                map!.msg.sendMessage(type: map!.msg.BIRTH, from: name)
                lastBaby = age
            }
        }
    }
    
} // CheetahClass
