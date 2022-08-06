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

//TODO move Confighandling
//TODO add autostart
//TODO make universall
//TODO change cfg path

struct State {
    let memory_max = System.physicalMemory()
    var oldUsage :Double = 0.0
    var icons = [NSImage]()
    var config = ConfigData()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var state = State()
    var timer :Timer?
    var sys :System?
    var menuDelegate :NSMenuDelegate?
    var preferencesController :NSWindowController?
    //let conf_dir = URL(fileURLWithPath: "\(FileManager.default.homeDirectoryForCurrentUser.path)/.config/CPUMonitor/")
    //let conf_file = URL(fileURLWithPath: "\(FileManager.default.homeDirectoryForCurrentUser.path)/.config/CPUMonitor/CPUMonitor/CPUMonitor.cfg")
    
    // /Users/<name>/Library/Containers/com.Lennard.CPUMonitor/Data/Library/"Application Support"/CPUMonitor/
    let conf_dir = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/")
    let conf_file = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/CPUMonitor.cfg")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)

        sys = System()
        loadImages()
        
        if !FileManager.default.fileExists(atPath: (conf_file.path)) {
            writeCfg(conf: state.config)
        } else {
            state.config = readCfg()
        }
        
        statusItem.length = 60
        statusItem.menu = NSMenu()
        menuDelegate = OnOpenMenuDelegate(onOpen: refreshMenu)
        statusItem.menu?.delegate = menuDelegate
        initMenu(menu: statusItem.menu!)
    }
    
    func readCfg() -> ConfigData {
        let conf = ConfigData()
        if let content = try? String.init(contentsOf: conf_file) {
            ConfigHandler.parseMapToObj(keyValue: ConfigHandler.parseStringToMap(content: content), target: conf)
        }
        return conf
    }
    
    func writeCfg(conf :ConfigData) {
        let config = ConfigHandler.parseMapToString(keyValue: ConfigHandler.parseObjToMap(content: conf))
        if !FileManager.default.fileExists(atPath: (conf_file.path)) {
            try! FileManager.default.createDirectory(atPath: conf_dir.path, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: (conf_file.path), contents: config.data(using: String.Encoding.utf8, allowLossyConversion: false)!, attributes: nil)
            return
        }
        try! config.write(to: conf_file, atomically: true, encoding: String.Encoding.utf8)
    }
    
    func applyCfg() {
        initMenu(menu: statusItem.menu!)
        if state.config.startAtLogin {
            setStartAtLogin()
        }
        if timer!.timeInterval != state.config.refreshTime {
            startTimer(wait: state.config.refreshTime)
        }
    }
    
    func loadImages() {
        for i in stride(from: 0, to: 101, by: 2) {
            state.icons.append(NSImage(named: NSImage.Name(String(i)))!)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    
    func refreshMenu(menu: NSMenu) {
        let memoryUsage = System.memoryUsage()
        let memoryUsageA  = [memoryUsage.free, memoryUsage.inactive, memoryUsage.compressed, memoryUsage.active, memoryUsage.wired]
        (menu.item(at: 0) as? SimpleMemItem)?.update(val1: memoryUsage.free + memoryUsage.inactive, val2: state.memory_max)
        for i in 1..<menu.items.count-2 {
            (menu.item(at: i) as? SimpleMemItem)?.update(val1: memoryUsageA[i-1])
        }
    }
    
    func initMenu(menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(createSimpleMemItem())
        
        if state.config.detailedMemory {
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
