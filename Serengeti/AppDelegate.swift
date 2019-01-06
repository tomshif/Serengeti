//
//  AppDelegate.swift
//  Serengeti
//
//  Created by Tom Shiflet on 1/5/19.
//  Copyright © 2019 Liberty Game Dev. All rights reserved.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Make the application close completely when closing the window
    func applicationShouldTerminateAfterLastWindowClosed (_ theApplication: NSApplication) -> Bool { return true }
    
    
}
