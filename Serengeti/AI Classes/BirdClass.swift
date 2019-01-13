//
//  BirdClass.swift
//  AITestBed
//
//  Created by Tom Shiflet on 1/8/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//

import Foundation
import SpriteKit

class BirdClass
{
    let sprite=SKSpriteNode(imageNamed: "bird01")
    let frame1=SKTexture(imageNamed: "bird01")
    let frame2=SKTexture(imageNamed: "bird02")
    
    private var map:MapClass?
    private var scene:SKScene?
    private var leader:BirdClass?
    
    private var isLeader:Bool=false
    private var isPursuing:Bool=false
    public var isAlive:Bool=true
    
    private let MAXSPEED:CGFloat=5.0
    private var speed:CGFloat=2.5
    private let TURNRATE:CGFloat=0.5
    private let TURNFREQ:Double=0.08
    private let FOLLOWDIST:CGFloat=50
    private var followDistVar:CGFloat=0
    private var animationCycle:Int=1
    private let UPDATECYCLE:Int=2
    
    
    public var lastWanderTurn=NSDate()
    
    
    init()
    {
        
    }
    
    init(theMap: MapClass,theScene: SKScene, pos: CGPoint, isLdr: Bool, ldr: BirdClass?)
    {
        map=theMap
        scene=theScene
        
        
        
        sprite.position=pos
        sprite.name="ambBird"
        sprite.setScale(random(min: 0.4, max: 0.7))
        isLeader=isLdr
        sprite.zPosition=220
        
        scene!.addChild(sprite)
        followDistVar=random(min: FOLLOWDIST*0.5, max: FOLLOWDIST*5.5)
        if !isLdr && ldr != nil
        {
            leader=ldr
        }
        
        
        
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
            if speed > MAXSPEED
            {
                speed=MAXSPEED
            }
        } // if we speed up
        else if speedChance > 0.5
        {
            speed -= 0.1
            if speed < MAXSPEED*0.5
            {
                speed=MAXSPEED*0.5
            }
        } // if we slowdown
        
        //check to see if it's time to turn
        let turnDelta = -lastWanderTurn.timeIntervalSinceNow
        if turnDelta > TURNFREQ/Double(map!.getTimeScale())
        {
            let turn=random(min: -TURNRATE, max: TURNRATE)
            sprite.zRotation+=turn
            lastWanderTurn=NSDate()
        } // if it's time to turn
        
        
    } // leaderFly
    
    public func getDistToLeader() -> CGFloat
    {
        if leader != nil
        {
            let dx=leader!.sprite.position.x-sprite.position.x
            let dy=leader!.sprite.position.y-sprite.position.y
            let dist=hypot(dy, dx)
            return dist
        }
        else
        {
            return 0
        }
        
    } // getDistToEntity
    
    func pursue()
    {
        if leader != nil
        {

            speed=MAXSPEED
            let dx=leader!.sprite.position.x-sprite.position.x
            let dy=leader!.sprite.position.y-sprite.position.y
            var angle=atan2(dy, dx)
            var angleDiff = angle-sprite.zRotation
            
            if angle < 0
            {
                angle+=CGFloat.pi*2
            }
            
            if angleDiff > CGFloat.pi*2
            {
                angleDiff -= CGFloat.pi*2
            }
            if angleDiff < -CGFloat.pi*2
            {
                angleDiff += CGFloat.pi*2
            }
            
            if (angleDiff > 0.3 && angleDiff < CGFloat.pi) || angleDiff < -CGFloat.pi
            {
                // turning left
                sprite.zRotation += TURNRATE
                
            } // if turn left
            else if (angleDiff < -0.3 && angleDiff > -CGFloat.pi) || angleDiff > CGFloat.pi
            {
                // we need to turn right
                sprite.zRotation -= TURNRATE
                
            } // else if turn right

        } // if we have a leader
        
    } // func pursue
    

    public func updateGraphics()
    {
        if animationCycle%4 == 0
        {
            sprite.texture=frame1
            
        }
        else
        {
            sprite.texture=frame2
        }
        
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
    
    private func checkLeaderStatus()
    {
        if !isLeader && leader!.isAlive==false
        {
            let removeAction=SKAction.run {
                self.isAlive=false
            }
            let remove=SKAction.sequence([SKAction.fadeOut(withDuration: 0.25), SKAction.removeFromParent(), removeAction])
            sprite.run(remove)
        }
    }
    
    public func update(cycle: Int)
    {

        updateGraphics()
        
        if cycle==UPDATECYCLE && isAlive
        {
            animationCycle+=1
            if animationCycle > 200
            {
                animationCycle=1
            }
            
            if isLeader
            {
                leaderFly()
                let rand=random(min: 0.0, max: 1.0)
                if rand > 0.9985
                {
                    sprite.removeFromParent()
                    isAlive=false
                }
            } // if is leader
            else
            {
                checkLeaderStatus()
                let dist = getDistToLeader()
                if dist > FOLLOWDIST+followDistVar
                {
                    isPursuing=true
                    speed=MAXSPEED*1.5
                }
                if dist < FOLLOWDIST+followDistVar/2
                {
                    isPursuing=false
                    speed=MAXSPEED*1.0
                }
                
                if isPursuing
                {
                    pursue()
                    
                }
                else
                {
                    leaderFly()
                }
                
            } // if not leader
      
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
