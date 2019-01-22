//
//  TerrainGen.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/6/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//
// Functions for generation of random map


import Foundation
import SpriteKit
import GameplayKit


func generateTerrainMap() -> Int32
{
    print("Generating Map")
    print("width: \(mapDims)")
    print("height: \(mapDims)")
    
    // Map generation variables

    var seed = Int32(random(min:0, max: 50000))
    
    let noise = GKNoise(GKBillowNoiseSource(frequency: 0.015, octaveCount: 2, persistence: 0.2, lacunarity: 0.005, seed: seed))

    //let noise = GKNoise(GKPerlinNoiseSource(frequency: 0.01, octaveCount: 1, persistence: 0.01, lacunarity: 0.1, seed: seed))
    
    var mapSize=vector_double2()
    mapSize.x=mapDims
    mapSize.y=mapDims
    var mapCenter=vector_double2()
    mapCenter.x=0
    mapCenter.y=0
    var mapSamples=vector_int2()
    mapSamples.x=sampleDims
    mapSamples.y=sampleDims
    noiseMap = GKNoiseMap(noise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
    let texture = SKTexture(noiseMap: noiseMap)
    mapTexture=texture
    map.texture=texture
    map.yScale *= -1
    
    seed = Int32(random(min:0, max: 50000))
    
    let biomeNoise = GKNoise(GKBillowNoiseSource(frequency: 0.01, octaveCount: 1, persistence: 0.1, lacunarity: 0.1, seed: seed))
    
    biomeMap=GKNoiseMap(biomeNoise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
    biomeTexture=SKTexture(noiseMap: biomeMap)
    
    //waterDepth=random(min: -0.425, max: -0.2)
    
    return seed
} // func generateTerrainMap

func genMap()
{
    mapList.removeAll()
    for i in 0..<(sampleDims*sampleDims)
    {
        let mapx=i%Int32(mapDims)
        let mapy=Int(i/Int32(mapDims))

        //let ground=Int(random(min:0, max: 2.99999))
        var currentXY=vector_int2()
        currentXY.x=Int32(mapx)
        currentXY.y=Int32(mapy)
        
        let value=noiseMap.value(at: currentXY)
        
        let tempTile=mapTile(x: Int(mapx), y: Int(mapy), alt: CGFloat(value), type: 0, tile: 0)
        
        mapList.append(tempTile)
    } // for i
    
    print(mapList.count)
    
}

func drawMap()
{
    
    for i in 0...mapList.count-1
    {
        let mapx=mapList[i].x
        let mapy=Int(mapList[i].y)
        
        var ground=0
        //let ground=Int(random(min:0, max: 2.99999))
        var currentXY=vector_int2()
        currentXY.x=Int32(mapx)
        currentXY.y=Int32(mapy)
        
        let value=mapList[i].alt

        if value > 0
        {
            ground=2
        }
        else if value >= -0.6
        {
            ground=1
        }
        else // mud
        {
            ground=4
        }
    
        
        
        
        let tile=SKSpriteNode(imageNamed: "tile0\(ground)")
        let offset = (tile.size.width*CGFloat(mapDims/2))
        tile.position.x = CGFloat(-CGFloat(offset) + (CGFloat(mapx)*tile.size.width))
        tile.position.y = CGFloat(CGFloat(offset) - (CGFloat(mapy)*tile.size.width))
        tile.isHidden=false

        //tile.colorBlendFactor=0.5
        //tile.color=NSColor(calibratedRed: 1.00, green: 1.0, blue: 1.0, alpha: 0)
        //tile.lightingBitMask=1
        //tile.shadowedBitMask=0
        //tile.shadowCastBitMask=0
        tile.name="tile0\(ground)"
        center.addChild(tile)
        tile.zPosition=1
        
        //print("\(mapx),\(mapy) - \(tile.texture)")

        
    } // for i
    

    
    
} // func drawMap

func drawTree(theMap: MapClass, theScene: SKScene)
{
    
    
    
    // first pick a random spot
    for _ in 1...10
    {
    let point=CGPoint(x: random(min: -theMap.BOUNDARY*0.9, max: theMap.BOUNDARY*0.9), y: random(min: -theMap.BOUNDARY*0.9, max: theMap.BOUNDARY*0.9))

    
    var loc=vector_int2()
    loc.x = Int32(point.x)/Int32(theMap.MAPWIDTH)
    loc.y = Int32(point.y)/Int32(theMap.MAPWIDTH)
    
    // check the spot on the biome map to see what kind of tree
    let alt=biomeMap.value(at: loc)
    if alt > 0.5
    {
        let nodes=theScene.nodes(at: point)
        if nodes.count > 0
        {
            for thisOne in nodes
            {
                if thisOne.name=="tile01"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree01")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                } // if we're on tile01
                else if thisOne.name=="tile02"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree02")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                    
                } // if we're on tile 02
                else if thisOne.name=="tile04"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree04")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                    
                } // if we're tile 04
            } // for each node
        } // if we have nodes
        
    } // if the alt is > 0.5
    else if alt < -0.5
    {
        // should be tree #1 so check terrain
        let nodes=theScene.nodes(at: point)
        if nodes.count > 0
        {
            for thisOne in nodes
            {
                if thisOne.name=="tile01"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree01")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                } // if we're on tile01
                else if thisOne.name=="tile02"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree02")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                    
                } // if we're on tile 02
                else if thisOne.name=="tile04"
                {
                    let tempTree=SKSpriteNode(imageNamed: "tree04")
                    tempTree.setScale(random(min: 0.5, max: 1.2))
                    tempTree.zRotation=random(min: 0, max: CGFloat.pi)
                    tempTree.zPosition=101
                    tempTree.position=point
                    theScene.addChild(tempTree)
                    
                } // if we're tile 04
            } // for each node
        } // if we have nodes
    } // if the alt is < 0.5
    } // for each of 100 trees
    
    
} // func drawTree


func genRestZone(theMap: MapClass, theScene: SKScene)
{
    let WATERZONEDISTANCE:CGFloat=5000
    
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY),y: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY))
        
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check the terrain tile for the right terrain
                if thisOne.name=="tile02"
                {
                    // Check distances to water zones
                    for ii in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[ii].type==ZoneType.WATERZONE
                        {
                            let dx=theMap.zoneList[ii].sprite.position.x - checkPoint.x
                            let dy=theMap.zoneList[ii].sprite.position.y - checkPoint.y
                            let dist = hypot(dy, dx)
                            //print("Distance: \(dist)")
                            
                            if dist < WATERZONEDISTANCE
                            {
                                foundSpot=true
                            } // if we're in range
                        } // if it's a water zone
                    } // for each zone
                    
                } // if we're on the right terrain
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.RESTZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genRestZone

func genFoodZone(theMap: MapClass, theScene: SKScene)
{
    let RESTZONEDISTANCE:CGFloat=8000
    
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY),y: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY))
        
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check the terrain tile for the right terrain
                if thisOne.name=="tile01"
                {
                    // Check distances to water zones
                    for ii in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[ii].type==ZoneType.RESTZONE
                        {
                            let dx=theMap.zoneList[ii].sprite.position.x - checkPoint.x
                            let dy=theMap.zoneList[ii].sprite.position.y - checkPoint.y
                            let dist = hypot(dy, dx)
                            //print("Distance: \(dist)")
                            
                            if dist < RESTZONEDISTANCE
                            {
                                foundSpot=true
                            } // if we're in range
                        } // if it's a rest zone
                    } // for each zone
                    
                } // if we're on the right terrain
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.FOODZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genFoodZone


func genWaterZone(theMap: MapClass, theScene: SKScene)
{
    var foundSpot:Bool=false
    var checkPoint=CGPoint()
    while !foundSpot
    {
        // pick a spot
        checkPoint=CGPoint(x: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY),y: random(min: -theMap.BOUNDARY, max: theMap.BOUNDARY))
        
        // check to see if it's the right kind of terrain
        let theNodes = theScene.nodes(at: checkPoint)
        if theNodes.count > 0
        {
            for thisOne in theNodes
            {
                // check to see if w're on the right tile
                if thisOne.name=="tile04"
                {
                    // assume we've found a spot
                    foundSpot=true
                    
                    // check distance to closest water zone
                    for zones in 0..<theMap.zoneList.count
                    {
                        if theMap.zoneList[zones].type==ZoneType.WATERZONE
                        {
                            let dx=theMap.zoneList[zones].sprite.position.x-checkPoint.x
                            let dy=theMap.zoneList[zones].sprite.position.y-checkPoint.y
                            let dist=hypot(dy, dx)
                            if dist < 2000
                            {
                                foundSpot=false
                            } // if we're too close
                        } // if it's a water zone
                    } // for each zone in the list
                    
                } // if we're on the right tile
                
            } // for each node
        } // if we have nodes
    } // while we haven't found a good spot
    
    let tempZone=ZoneClass(zoneType: ZoneType.WATERZONE, pos: checkPoint, theScene: theScene)
    theMap.zoneList.append(tempZone)
    
} // func genWaterZone


