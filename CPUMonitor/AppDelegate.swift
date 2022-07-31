//
//  AppDelegate.swift
//  CPUMonitor
//
//  Created by Lennard Kittner on 21.08.18.
//  Copyright © 2018 Lennard Kittner. All rights reserved.
//

import Cocoa
//import LaunchAtLogin
import SystemKit

struct State {
    let memory_max = System.physicalMemory()
    let defaultConfig =
                """
                Memdetail:no
                AtLogin:no
                Refresh:0.5
                """
        .data(using: String.Encoding.utf8, allowLossyConversion: false)!
    var startAtLogin = false
    var detailedMemory = false
    var refreshTime :Double = 0.5
    var oldUsage :Double = 0.0
    var icons = [NSImage]()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var state = State()
    var timer :Timer?
    var sys :System?
    var preferencesController :NSWindowController?
    // /Users/<name>/Library/Containers/com.Lennard.CPUMonitor/Data/Library/"Application Support"/CPUMonitor/
    let conf_dir = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/")
    let conf_file = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/CPUMonitor.cfg")
    
    func readCfg() -> State {
        var state = State()
        
        try! FileManager.default.createDirectory(atPath: conf_dir.path, withIntermediateDirectories: true, attributes: nil)
        if !FileManager.default.fileExists(atPath: (conf_file.path)) {
            FileManager.default.createFile(atPath: (conf_file.path), contents: state.defaultConfig, attributes: nil)
        }
        else {
            let conf = try!  String.init(contentsOf: conf_file).components(separatedBy: CharacterSet.newlines)
            for c in conf {
                if c.contains("Memdetail:") {
                    if c.contains("yes") {
                        state.detailedMemory = true
                    }
                }
                else if c.contains("AtLogin:") {
                    if c.contains("yes") {
                        state.startAtLogin = true
                        setStartAtLogin()
                    }
                }
                else if c.contains("Refresh:") {
                    state.refreshTime = Double(c.components(separatedBy: ":")[1]) ?? 0.5
                }
            }
        }
        return state
    }
    
    func loadImages() {
        for i in stride(from: 0, to: 101, by: 2) {
            state.icons.append(NSImage(named: NSImage.Name(String(i)))!)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        readCfg()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
        sys = System()
        loadImages()

        // initializes the menu item
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("0"))
            statusItem.length = 60
        }
        
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
        refreshMenu()

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    //is called when the menubar button is clicked
    func menuNeedsUpdate(_ menu: NSMenu) {
        refreshMenu()
    }
    
    @objc func setStartAtLogin() {
        //LaunchAtLogin.isEnabled = startAtLogin
    }
    
    @objc func startTimer(wait: Double){
        timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
    }

    @objc func refresh(_ sender: Any?) {
        let cpuUsage = sys?.usageCPU()
        let usaged = (cpuUsage?.user)!+(cpuUsage?.system)!
        if state.oldUsage != usaged && usaged > 0 {
            statusItem.button?.toolTip = "CPUusage: \(String(format: "%.2f",usaged))%"
            refreshIcon(usage: usaged)
        }
    }
    
    func refreshIcon(usage: Double){
        let index = Int(usage / 2)
        statusItem.button?.image = state.icons[index]
    }
    
    func refreshMenu() {
        let menu = statusItem.menu!
        menu.removeAllItems()
        let memoryUsage = System.memoryUsage()
        let memoryd = memoryUsage.free + memoryUsage.inactive
        let ram = NSMenuItem(title: "Memory: \(String(format: "%.2f", memoryd)) GB / \(state.memory_max) GB ", action: nil, keyEquivalent: "")
        ram.toolTip = "general memory usage (free + inactive)"
        ram.isEnabled = false
        menu.addItem(ram)
        if state.detailedMemory {
            let free = NSMenuItem(title: "Free: \(String(format: "%.2f", memoryUsage.free)) GB", action: nil, keyEquivalent: "")
            free.isEnabled = false
            free.toolTip = "free memory"
            menu.addItem(free)
            let inactive = NSMenuItem(title: "Inactive: \(String(format: "%.2f", memoryUsage.inactive)) GB", action: nil, keyEquivalent: "")
            inactive.isEnabled = false
            inactive.toolTip = "memory left by closed apps to speed up next launch"
            menu.addItem(inactive)
            let compressed = NSMenuItem(title: "Compressed: \(String(format: "%.2f", memoryUsage.compressed)) GB", action: nil, keyEquivalent: "")
            compressed.isEnabled = false
            compressed.toolTip = "compresed memory"
            menu.addItem(compressed)
            let active = NSMenuItem(title: "Active: \(String(format: "%.2f", memoryUsage.active)) GB", action: nil, keyEquivalent: "")
            active.isEnabled = false
            active.toolTip = "activly by apps used memory "
            menu.addItem(active)
            let wired = NSMenuItem(title: "Wired: \(String(format: "%.2f", memoryUsage.wired)) GB", action: nil, keyEquivalent: "")
            wired.isEnabled = false
            wired.toolTip = "system memory"
            menu.addItem(wired)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    @objc func showPreferences(_ sender: Any?) {
        if (preferencesController == nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if (preferencesController != nil) {
            preferencesController!.showWindow(sender)
        }
        
    }
}
