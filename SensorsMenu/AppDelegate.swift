// Copyright © 2020 fordApps. All rights reserved.

import Cocoa
import Foundation
import IOKit.ps
import IOKit
import SystemKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    @IBOutlet weak var window: NSWindow!
    var statusItem: NSStatusItem!
    var preferencesWindow: PreferencesWindow!

    // MARK: MENU ITEMS

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        do {
            try SMCKit.open()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to initialize SMC!"
            alert.runModal()
            NSApplication.shared.terminate(self)
        }
        
        preferencesWindow = PreferencesWindow()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let icon = NSImage(named: "smc")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let _ = SMCKit.close()
    }
    
    @objc func onQuitMenuItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func noMoreGreyOut(_sender: NSMenuItem) {
    }
    
    @objc func PreferencesClicked(_sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        let defaults = UserDefaults.standard
        let batteryCheck = defaults.string(forKey: "battery")
        let systemCheck = defaults.string(forKey: "system")
        let processorCheck = defaults.string(forKey: "processor")
        let memoryCheck = defaults.string(forKey: "memory")
        
        let sensorsData = getSensorsData()
        
        let hour = Calendar.current.component(.hour, from: Date())
        let greetings = NSMenuItem()
        let fullUserName = NSFullUserName()
        
        switch hour {
            case 6..<12 : greetings.title = "🌤 Good Morning, \(fullUserName)!"
            case 12..<18 : greetings.title = "☁️ Good Afternoon, \(fullUserName)!"
            case 18..<22 : greetings.title = "🌙 Good Evening, \(fullUserName)!"
            default: greetings.title = "✨ Goodnight, \(fullUserName)!"
        }
        
        greetings.action = #selector(noMoreGreyOut)
        menu.addItem(greetings)
        menu.addItem(NSMenuItem.separator())
        
        for data in sensorsData {
            if data.items.count == 0 {
                continue
            }
            let temperatureInfo = NSMenuItem()
            temperatureInfo.title = "\(data.title):"
            menu.addItem(temperatureInfo)
            for item in data.items {
                let temperatureInfo = NSMenuItem()
                temperatureInfo.title = "\(item.0)  \(item.1)"
                temperatureInfo.action = #selector(noMoreGreyOut)
                menu.addItem(temperatureInfo)
            }
            menu.addItem(NSMenuItem.separator())
        }
        
        // MARK: BATTERY
        
        if batteryCheck == "yes" {
            let battInfoTitle = NSMenuItem()
            battInfoTitle.title = "🔋 Battery:"
            menu.addItem(battInfoTitle)
            
            let BatteryPercentage = getBatteryPercentage()
            let battInfoPercent = NSMenuItem()
            battInfoPercent.title = "Battery Percentage: \(BatteryPercentage)%"
            battInfoPercent.action = #selector(noMoreGreyOut)
            menu.addItem(battInfoPercent)
            
            let CurrentPowerSource = getBatteryPowerSource()
            let currentPwrScr = NSMenuItem()
            currentPwrScr.title = "Current Power Source: \(CurrentPowerSource)"
            currentPwrScr.action = #selector(noMoreGreyOut)
            let batteryTimeRemainingStatus = getBatteryTimeRemainingStatus()
            let battInfoRemaining = NSMenuItem()
            if CurrentPowerSource == "AC Power" {
            } else {
                battInfoRemaining.action = #selector(noMoreGreyOut)
                battInfoRemaining.title = "Time Remaining: \(batteryTimeRemainingStatus)"
                menu.addItem(battInfoRemaining)
            }
            menu.addItem(currentPwrScr)
            
            var battery = Battery()
            if battery.open() != kIOReturnSuccess { exit(0) }
            
            let battCurrentCapacity = battery.currentCapacity()
            let battCurrentCapacityMenu = NSMenuItem()
            battCurrentCapacityMenu.title = "Current Capacity: \(battCurrentCapacity) mAh"
            battCurrentCapacityMenu.action = #selector(noMoreGreyOut)
            menu.addItem(battCurrentCapacityMenu)
            
            let battMaxCapacity = battery.maxCapactiy()
            let battMaxCapacityMenu = NSMenuItem()
            battMaxCapacityMenu.title = "Maximum Capacity: \(battMaxCapacity) mAh"
            battMaxCapacityMenu.action = #selector(noMoreGreyOut)
            menu.addItem(battMaxCapacityMenu)
            
            let battDesignCapacity = battery.designCapacity()
            let battDesignCapacityMenu = NSMenuItem()
            battDesignCapacityMenu.title = "Design Capacity: \(battDesignCapacity) mAh"
            battDesignCapacityMenu.action = #selector(noMoreGreyOut)
            menu.addItem(battDesignCapacityMenu)
            
            let battCycle = battery.cycleCount()
            let battCycleMenu = NSMenuItem()
            battCycleMenu.title = "Battery Cycles: \(battCycle)"
            battCycleMenu.action = #selector(noMoreGreyOut)
            menu.addItem(battCycleMenu)
            
            menu.addItem(NSMenuItem.separator())
        }
                
        // MARK: SYSTEM
        
        if systemCheck == "yes"  {
            let sysInfoTitle = NSMenuItem()
            sysInfoTitle.title = "🖥 System:"
            menu.addItem(sysInfoTitle)
            
            let Uptime = uptime()
            let sysUptime = NSMenuItem()
            sysUptime.title = "Uptime: \(Uptime)"
            sysUptime.action = #selector(noMoreGreyOut)
            menu.addItem(sysUptime)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // MARK: PROCESSOR
        
        if processorCheck == "yes" {
            let cpuInfoTitle = NSMenuItem()
            cpuInfoTitle.title = "🎛 Processor:"
            menu.addItem(cpuInfoTitle)
            
            let cpuPhysicalCores = System.physicalCores()
            let cpuPhysicalCoresTitle = NSMenuItem()
            cpuPhysicalCoresTitle.title = "CPU Physical Cores: \(cpuPhysicalCores)"
            cpuPhysicalCoresTitle.action = #selector(noMoreGreyOut)
            menu.addItem(cpuPhysicalCoresTitle)
            
            let cpuLogicalCores = System.logicalCores()
            let cpuLogicalCoresTitle = NSMenuItem()
            cpuLogicalCoresTitle.title = "CPU Logical Cores: \(cpuLogicalCores)"
            cpuLogicalCoresTitle.action = #selector(noMoreGreyOut)
            menu.addItem(cpuLogicalCoresTitle)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // MARK: MEMORY
        
        if memoryCheck == "yes" {
            let memoryInfoTitle = NSMenuItem()
            memoryInfoTitle.title = "📎 Memory:"
            menu.addItem(memoryInfoTitle)
            
            let memorySize = System.physicalMemory()
            let memorySizeTitle = NSMenuItem()
            memorySizeTitle.title = "Total: \(memorySize)GB"
            memorySizeTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memorySizeTitle)
            
            let memoryUsage = System.memoryUsage()
            func memoryUnit(_ value: Double) -> String {
                if value < 1.0 { return String(Int(value * 1000.0))    + "MB" }
                else           { return NSString(format:"%.2f", value) as String + "GB" }
            }
            
            let memoryFree = memoryUnit(memoryUsage.free)
            let memoryFreeTitle = NSMenuItem()
            memoryFreeTitle.title = "Free: \(memoryFree)"
            memoryFreeTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memoryFreeTitle)
            
            let memoryWired = memoryUnit(memoryUsage.wired)
            let memoryWiredTitle = NSMenuItem()
            memoryWiredTitle.title = "Wired: \(memoryWired)"
            memoryWiredTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memoryWiredTitle)
            
            let memoryActive = memoryUnit(memoryUsage.active)
            let memoryActiveTitle = NSMenuItem()
            memoryActiveTitle.title = "Active: \(memoryActive)"
            memoryActiveTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memoryActiveTitle)
            
            let memoryInactive = memoryUnit(memoryUsage.inactive)
            let memoryInactiveTitle = NSMenuItem()
            memoryInactiveTitle.title = "Inactive: \(memoryInactive)"
            memoryInactiveTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memoryInactiveTitle)
            
            let memoryCompressed = memoryUnit(memoryUsage.compressed)
            let memoryCompressedTitle = NSMenuItem()
            memoryCompressedTitle.title = "Compressed: \(memoryCompressed)"
            memoryCompressedTitle.action = #selector(noMoreGreyOut)
            menu.addItem(memoryCompressedTitle)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        let p = NSMenuItem()
        p.title = "Preferences..."
        p.action = #selector(PreferencesClicked)
        menu.addItem(p)
        menu.addItem(NSMenuItem.separator())
        
        // MARK: APP VERSION
        
        let n = NSMenuItem()
        n.title = "Current App Version: 1.1"
        menu.addItem(n)
        
        menu.addItem(NSMenuItem.separator())
        
        // MARK: QUIT
        
        let m = NSMenuItem()
        m.title = "Quit SensorsMenu"
        m.action = #selector(onQuitMenuItemClicked)
        menu.addItem(m)
    }
    
    
    func getBatteryTimeRemainingStatus() -> String {
        let timeRemaining: CFTimeInterval = IOPSGetTimeRemainingEstimate()
        if timeRemaining == -2.0 {
            return "Unavailable"
        } else {
            let minutes = timeRemaining / 60
            if minutes < 0 {
                return "Calculating..."
            } else {
                return "\(minutes) minutes"
            }
        }
    }
    
    func getBatteryPowerSource() -> String {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSource = IOPSGetProvidingPowerSourceType(snapshot).takeRetainedValue()
        return powerSource as String
    }
    
    func getBatteryPercentage() -> Int {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                if description["Type"] as? String == kIOPSInternalBatteryType {
                    return description[kIOPSCurrentCapacityKey] as? Int ?? 0
                }
            }
        }
        return 0
    }
    
    func getSensorsData() -> Array<SensorsData> {
        
        var result: Array<SensorsData> = []
        
        // Get Mac's temperature
        let defaults = UserDefaults.standard
        let temperatureCheck = defaults.string(forKey: "temperature")
        let fanCheck = defaults.string(forKey: "fan")
        
        if temperatureCheck == "yes"  {
            do {
                let temps = try SMCKit.allKnownTemperatureSensors()
                var items: Array<(String, String)> = []
                
                for temp in temps {
                    items.append(("\(temp.name):", "\(try SMCKit.temperature(temp.code))"))
                }
                items = items.sorted(by: {$0.0 < $1.0})
                
                result.append(SensorsData(title: "🔥 Temperature", items: items))
                
            } catch {
                // pass
            }
        }

        // Get Mac's Fan speed
        
        if fanCheck == "yes"  {
            do {
                let fans = try SMCKit.allFans()
                var items: Array<(String, String)> = []
                for fan in fans {
                    items.append(("FAN: \(fan.name)", "Current Speed: \(try SMCKit.fanCurrentSpeed(fan.id)) rpm"))
                }
                
                result.append(SensorsData(title: "💨 Fan", items: items))
            } catch {
                // pass
            }
        }
        
        return result
    }

    
    func uptime() -> String {
        
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride
        
        var now = time_t()
        var uptime: time_t = -1
        
        time(&now)
        if (sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 && boottime.tv_sec != 0) {
            uptime = now - boottime.tv_sec
        }
        
        let seconds = uptime
        
        let sDays = String((seconds / 86400)) + " days"
        let sHours = String((seconds % 86400) / 3600) + " hours"
        let sMinutes = String((seconds % 3600) / 60) + " minutes"
        let sSeconds = String((seconds % 3600) % 60) + " seconds"
        
        var sHumanReadable = ""
        
        if ((seconds / 86400) > 0) {
            sHumanReadable = sDays + ", " + sHours + ", " + sMinutes + ", " + sSeconds
        } else if (((seconds % 86400) / 3600) > 0) {
            sHumanReadable = sHours + ", " + sMinutes + ", " + sSeconds
        } else if (((seconds % 3600) / 60) > 0) {
            sHumanReadable = sMinutes + ", " + sSeconds
        } else if (((seconds % 3600) % 60) > 0) {
            sHumanReadable = sSeconds
        }
        return sHumanReadable
    }

    
    func menuDidClose(_ menu: NSMenu) {
        menu.removeAllItems()
    }
}

struct SensorsData {
    var title: String
    var items: Array<(String, String)>
}
