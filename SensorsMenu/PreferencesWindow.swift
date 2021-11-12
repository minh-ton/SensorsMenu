//
//  PreferencesWindow.swift
//  SensorsMenu
//
//  Created by Ford on 5/10/20.
//  Copyright © 2020 fordApps. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    // Preferred Sensors and Stats
    
    @IBOutlet weak var TemperatureCheck: NSButton!
    @IBOutlet weak var FanCheck: NSButton!
    @IBOutlet weak var BatteryCheck: NSButton!
    @IBOutlet weak var SystemCheck: NSButton!
    @IBOutlet weak var ProcessorCheck: NSButton!
    @IBOutlet weak var MemoryCheck: NSButton!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.level = .floating
        NSApp.activate(ignoringOtherApps: true)
        
        let defaults = UserDefaults.standard
        
        let temperatureCheck = defaults.string(forKey: "temperature")
        let fanCheck = defaults.string(forKey: "fan")
        let batteryCheck = defaults.string(forKey: "battery")
        let systemCheck = defaults.string(forKey: "system")
        let processorCheck = defaults.string(forKey: "processor")
        let memoryCheck = defaults.string(forKey: "memory")
        
        if temperatureCheck == "no" {
            TemperatureCheck.state = .off
        } else {
            TemperatureCheck.state = .on
        }
        
        if fanCheck == "no" {
            FanCheck.state = .off
        } else {
            FanCheck.state = .on
        }
        
        if batteryCheck == "no" {
            BatteryCheck.state = .off
        } else {
            BatteryCheck.state = .on
        }
        
        if systemCheck == "no" {
            SystemCheck.state = .off
        } else {
            SystemCheck.state = .on;
        }
        
        if processorCheck == "no" {
            ProcessorCheck.state = .off
        } else {
            ProcessorCheck.state = .on;
        }
        
        if memoryCheck == "no" {
            MemoryCheck.state = .off
        } else {
            MemoryCheck.state = .on;
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        
        if TemperatureCheck.state == .on {
            defaults.setValue("yes", forKey: "temperature")
        } else {
            defaults.setValue("no", forKey: "temperature")
        }
        
        if FanCheck.state == .on {
            defaults.setValue("yes", forKey: "fan")
        } else {
            defaults.setValue("no", forKey: "fan")
        }
        
        if BatteryCheck.state == .on {
            defaults.setValue("yes", forKey: "battery")
        } else {
            defaults.setValue("no", forKey: "battery")
        }
        
        if SystemCheck.state == .on {
            defaults.setValue("yes", forKey: "system")
        } else {
            defaults.setValue("no", forKey: "system")
        }
        
        if ProcessorCheck.state == .on {
            defaults.setValue("yes", forKey: "processor")
        } else {
            defaults.setValue("no", forKey: "processor")
        }
        
        if MemoryCheck.state == .on {
            defaults.setValue("yes", forKey: "memory")
        } else {
            defaults.setValue("no", forKey: "memory")
        }
    
    }
    
}


