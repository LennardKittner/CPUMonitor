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

//TODO add autostart
//TODO make universall

struct State {
    let maxMemory = System.physicalMemory()
    var currentCpuUsage = 0.0
    var icons :[NSImage] = []
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var sys :System
    var state :State
    var menuDelegate :NSMenuDelegate?
    var timer :Timer?
    var preferencesController :NSWindowController?
    var configHandler :ConfigHandler!
  
    override init() {
        sys = System()
        state = State()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.length = 60
        state.icons = loadImages()
        menuDelegate = OnOpenMenuDelegate(onOpen: refrshMenu)
        statusItem.menu?.delegate = menuDelegate
        configHandler = ConfigHandler(onChange: applyCfg)
    }
    
    func refrshMenu(menu: NSMenu) {
        if let memMenu = menu as? MemMenu {
            memMenu.refresh(memoryUsage: System.memoryUsage())
        }
    }
    
    @objc func refreshButton(_ sender: Any?) {
        refresh(cpuUsage: sys.usageCPU())
    }
    
    func refresh(cpuUsage: (system: Double, user: Double, idle: Double, nice: Double)) {
        let usage = cpuUsage.user + cpuUsage.system
        if state.currentCpuUsage != usage && usage >= 0 {
            state.currentCpuUsage = usage
            statusItem.toolTip = "CPUusage: \(String(format: "%.2f",usage))%"
            let index = Int(usage / 2)
            statusItem.image = state.icons[index]
        }
    }
    
    func loadImages() -> [NSImage] {
        var icons :[NSImage] = []
        for i in stride(from: 0, to: 101, by: 2) {
            icons.append(NSImage(named: NSImage.Name(String(i)))!)
        }
        return icons
    }
    
    func applyCfg(conf :ConfigData) {
        configHandler?.writeCfg()
        statusItem.menu = MemMenu(conf: conf, maxMemory: state.maxMemory)
        statusItem.menu?.delegate = menuDelegate
        if conf.startAtLogin {
            setStartAtLogin()
        }
        if timer?.timeInterval ?? -1 != conf.refreshTime {
            timer?.invalidate()
            startTimer(wait: conf.refreshTime)
        }
    }
    
    @objc func setStartAtLogin() {
        //LaunchAtLogin.isEnabled = startAtLogin
    }
    
    func startTimer(wait: Double){
        timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(refreshButton(_:)), userInfo: nil, repeats: true)
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
