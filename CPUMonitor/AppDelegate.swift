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

//TODO move Menu
//TODO add autostart
//TODO make universall

struct State {
    let memory_max = System.physicalMemory()
    var oldUsage :Double = 0.0
    var icons = [NSImage]()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var state = State()
    var timer :Timer?
    var sys :System?
    var menuDelegate :NSMenuDelegate?
    var preferencesController :NSWindowController?
    var configHandler :ConfigHandler?
  
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
        sys = System()
        loadImages()
        
        statusItem.length = 60
        statusItem.menu = NSMenu()
        menuDelegate = OnOpenMenuDelegate(onOpen: refreshMenu)
        statusItem.menu?.delegate = menuDelegate
        configHandler = ConfigHandler(onChange: applyCfg)
    }
    
    func loadImages() {
        for i in stride(from: 0, to: 101, by: 2) {
            state.icons.append(NSImage(named: NSImage.Name(String(i)))!)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applyCfg(conf :ConfigData) {
        configHandler?.writeCfg()
        initMenu(menu: statusItem.menu!, conf: conf)
        if conf.startAtLogin {
            setStartAtLogin()
        }
        if timer!.timeInterval != conf.refreshTime {
            startTimer(wait: conf.refreshTime)
        }
    }
    
    @objc func setStartAtLogin() {
        //LaunchAtLogin.isEnabled = startAtLogin
    }
    
    func startTimer(wait: Double){
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
    
    func refreshMenu(menu: NSMenu) {
        let memoryUsage = System.memoryUsage()
        let memoryUsageA  = [memoryUsage.free, memoryUsage.inactive, memoryUsage.compressed, memoryUsage.active, memoryUsage.wired]
        (menu.item(at: 0) as? SimpleMemItem)?.update(val1: memoryUsage.free + memoryUsage.inactive, val2: state.memory_max)
        for i in 1..<menu.items.count-2 {
            (menu.item(at: i) as? SimpleMemItem)?.update(val1: memoryUsageA[i-1])
        }
    }
    
    func initMenu(menu: NSMenu, conf: ConfigData) {
        menu.removeAllItems()
        menu.addItem(createSimpleMemItem())
        
        if conf.detailedMemory {
            createDetailedMemItems().forEach(({menu.addItem($0)}))
        }
    
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    func createSimpleMemItem() -> NSMenuItem {
        return SimpleMemItem(prefix: "Memory: ", middle: " GB / ", suffix: " GB", toolTip: "memory usage (free + inactive)")
    }
    
    func createDetailedMemItems() -> [NSMenuItem] {
        var items :[NSMenuItem] = []
        items.append(SimpleMemItem(prefix: "Free: ", suffix: " GB", toolTip: "free memory"))
        items.append(SimpleMemItem(prefix: "Inactive: ", suffix: " GB", toolTip: "memory used by closed apps to speed up next launch"))
        items.append(SimpleMemItem(prefix: "Compressed: ", suffix: " GB", toolTip: "compresed memory"))
        items.append(SimpleMemItem(prefix: "Active: ", suffix: " GB", toolTip: "activly used user memory "))
        items.append(SimpleMemItem(prefix: "Wired: ", suffix: " GB", toolTip: "system memory"))
        return items
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
