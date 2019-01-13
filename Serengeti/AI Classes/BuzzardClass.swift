//
//  BuzzardClass.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/13/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class BuzzardClass
{
    let sprite=SKSpriteNode(imageNamed: "buzzard")

    
    private var map:MapClass?
    private var scene:SKScene?
    
    public var isAlive:Bool=true
    
    private let MAXSPEED:CGFloat=5.0
    private var speed:CGFloat=2.5
    private let TURNRATE:CGFloat=0.005
    private let TURNFREQ:Double=0.5
    private let UPDATECYCLE:Int=2
    internal var WANDERANGLE:CGFloat=CGFloat.pi/2
    
    internal var nextWanderTurn:Double=0
    
    public var isTurning:Bool=false
    
    internal var turnToAngle:CGFloat=0.0
    
    public var lastWanderTurn=NSDate()
    
    
    init()
    {
        
    }
    
    init(theMap: MapClass,theScene: SKScene, pos: CGPoint, isLdr: Bool, ldr: BirdClass?)
    {
        map=theMap
        scene=theScene
        
        
        
        sprite.position=pos
        sprite.name="ambBuzzard"
        sprite.setScale(random(min: 0.05, max: 0.1))
        sprite.zPosition=220
        sprite.lightingBitMask=1
        sprite.shadowedBitMask=0
        sprite.shadowCastBitMask=0
        scene!.addChild(sprite)
     
        
        
    } // init()
    
    public func remove()
    {
        sprite.removeFromParent()
    } // remove()
    
    func wander()
    {
        
    }
    
    private func leaderFly()
    {
        // check for speed up
        let speedChance=random(min: 0, max: 1.0)
        if speedChance > 0.75
        {
            speed+=0.1

            if speed > MAXSPEED*0.7
            {
                speed=MAXSPEED*0.7
            }
        } // if we speed up
        else if speedChance > 0.5
        {
            speed -= 0.1
            if speed < MAXSPEED*0.5
            {
                speed=MAXSPEED*0.5
                
            } // if speed drops below zero
            
            if isTurning && speed < 0.1
            {
                speed = 0.1
            }
        } // if we slow down
        
        if !isTurning
        {
            if speed < 0.1
            {
                speed = 0.1
            }
            
            //check to see if it's time to turn
            let turnDelta = -lastWanderTurn.timeIntervalSinceNow
            if turnDelta > nextWanderTurn/Double(map!.getTimeScale())
            {
                turnToAngle=sprite.zRotation + random(min: -WANDERANGLE, max: WANDERANGLE)
                
                // Adjust turn to angle to be 0-pi*2
                if turnToAngle >= CGFloat.pi*2
                {
                    turnToAngle -= CGFloat.pi*2
                }
                if turnToAngle < 0
                {
                    turnToAngle += CGFloat.pi*2
                }
                isTurning=true
            } // if it's time to turn
        } // if we're not turning but moving
        
        
    } // leaderFly
    
    public func checkTurning() -> Bool
    {
        return isTurning
    }
    
    internal func doTurn()
    {
        if isTurning
        {
            if abs(turnToAngle-sprite.zRotation) < TURNRATE*2*speed
            {
                sprite.zRotation=turnToAngle
                isTurning=false
                nextWanderTurn=Double(random(min: CGFloat(TURNFREQ), max: CGFloat(TURNFREQ*3)))
                lastWanderTurn=NSDate()
            } // if we can stop turning
            
        } // if we're turning
        
        
        if isTurning
        {
            var angleDiff = turnToAngle-sprite.zRotation
            
            if angleDiff > CGFloat.pi*2
            {
                angleDiff -= CGFloat.pi*2
            }
            if angleDiff < 0
            {
                angleDiff += CGFloat.pi*2
            }
            
            if angleDiff < CGFloat.pi || angleDiff < -CGFloat.pi
            {
                // turning left
                sprite.zRotation += TURNRATE*speed
                
            } // if turn left
            else if angleDiff > -CGFloat.pi || angleDiff > CGFloat.pi
            {
                // we need to turn right
                sprite.zRotation -= TURNRATE*speed
                
            } // else if turn right
            
            
        }// if we're turning
        
    } // func doTurn
    
    
    
    
    public func updateGraphics()
    {
        
        let dx=cos(sprite.zRotation)*speed*map!.getTimeScale()
        let dy=sin(sprite.zRotation)*speed*map!.getTimeScale()
        sprite.position.x+=dx
        sprite.position.y+=dy
        
    } // func updateGraphics
    
    private func checkMapEdge()
    {
        if sprite.position.x > map!.BOUNDARY || sprite.position.x < -map!.BOUNDARY || sprite.position.y > map!.BOUNDARY || sprite.position.y < -map!.BOUNDARY
        {
            sprite.removeFromParent()
            isAlive=false
            
        } // if we're off the map
    }
    
   
    
    public func update(cycle: Int)
    {
        
        updateGraphics()
        doTurn()
        if cycle==UPDATECYCLE && isAlive
        {
                leaderFly()
 
            
            checkMapEdge()
        } // if it's our animation cycle
        
        if sprite.zRotation > CGFloat.pi*2
        {
            sprite.zRotation -= CGFloat.pi*2
        }
        if sprite.zRotation < 0
        {
            sprite.zRotation += CGFloat.pi*2
        }
        
        
        
    } // func update
    
    
    
} // class BirdClass
