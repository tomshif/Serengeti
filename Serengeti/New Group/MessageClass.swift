//
//  MessageClass.swift
//  EntityClassTest
//
//  Created by Tom Shiflet on 12/13/18.
//  Copyright © 2018 Tom Shiflet. All rights reserved.
//

import Foundation

class MessageClass
{
    private var unreadQueue=[String]()
    private var archiveQueue=[String]()
    
    let DEATH_PREDATOR:Int=0
    let DEATH_DISEASE:Int=2
    let DEATH_STARVATION:Int=4
    let DEATH_THIRST:Int=6
    let DEATH_AGE:Int=8
    let BORN:Int=20
    let NEWHERDLEADER:Int=22
    
    
    init()
    {
        
    }
    
    public func sendMessage(type: Int, from: String)
    {
        switch type
        {
        case 0:
            let temp="\(from) was killed by a predator."
            unreadQueue.append(temp)
            
        case 2:
            let temp="\(from) died of disease."
            unreadQueue.append(temp)
            
        case 4:
            let temp="\(from) died of starvation."
            unreadQueue.append(temp)
            
        case 6:
            let temp="\(from) died of thirst."
            unreadQueue.append(temp)
            
        case 8:
            let temp="\(from) died of old age."
            unreadQueue.append(temp)
            
        case 22:
            let temp="\(from) found a new herd leader."
            unreadQueue.append(temp)
            
        default:
            break
        } // switch
    } // func sendMessage()
    
    public func sendCustomMessage(message: String)
    {
        unreadQueue.append(message)
        
    } // sendCustomMessage
    
    public func readNextMessage() -> String
    {
        if unreadQueue.count > 0
        {
            let temp = unreadQueue[0]
            archiveQueue.append(unreadQueue[0])
            unreadQueue.remove(at: 0)
            return temp

        } // if we have messages
        else
        {
            return "No new messages."
        } // if there are no messages
    } // readNextMessage
    
    public func clearAll()
    {
        unreadQueue.removeAll()
        archiveQueue.removeAll()
    }
    
    public func readArchivedMessage(index: Int) -> String
    {
        if archiveQueue.count > index
        {
            return archiveQueue[index]
            
        }
        else
        {
            return "Invalid"
        }
        
    } // func readArchivedMessage()
    
    public func getArchivedCount() -> Int
    {
        return archiveQueue.count
    } // func getArchivedCount
    
    public func getUnreadCount() -> Int
    {
        return unreadQueue.count
    } // func getUnreadCount
    
} // MessageClass
