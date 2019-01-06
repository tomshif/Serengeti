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
    
    let noise = GKNoise(GKBillowNoiseSource(frequency: 0.015, octaveCount: 2, persistence: 0.2, lacunarity: 0.01, seed: seed))

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
        let offset = (tile.size.width/2*CGFloat(mapDims/2))
        tile.position.x = CGFloat(-CGFloat(offset) + (CGFloat(mapx)*tile.size.width/2))
        tile.position.y = CGFloat(CGFloat(offset) - (CGFloat(mapy)*tile.size.width/2))
        tile.isHidden=false
        tile.zPosition=1
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
