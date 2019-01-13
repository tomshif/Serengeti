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
    
    let biomeMap=GKNoiseMap(biomeNoise, size: mapSize, origin: mapCenter, sampleCount: mapSamples, seamless: false)
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
        tile.zPosition=1
        tile.lightingBitMask=1
        tile.shadowedBitMask=0
        tile.shadowCastBitMask=0
        //tile.colorBlendFactor=((value+1)/4)
        //tile.color=NSColor(calibratedRed: 1.00, green: 1.0, blue: 1.0, alpha: 0)
        //tile.lightingBitMask=1
        //tile.shadowedBitMask=0
        //tile.shadowCastBitMask=0
        tile.name="tile0\(ground)"
        center.addChild(tile)
       
        
        //print("\(mapx),\(mapy) - \(tile.texture)")

        
    } // for i
    

    
    
} // func drawMap

func generateZones(theMap: MapClass, theScene: SKScene)
{
    
    
    let RESTZONECOUNT:Int=100
    let WATERZONECOUNT:Int=50


    
    // First generate water zones
    for i in 0..<WATERZONECOUNT
    {
       
    } // for each zone to create
    
    print("Finished placing water zones.")
    
    // Next generate rest zones
    for i in 0..<RESTZONECOUNT
    {

    } // for each rest zone to create
    
    print("Finished generating zones.")
} // func generateZones

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


