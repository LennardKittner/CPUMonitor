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
    let maxMemory = System.physicalMemory()
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
        menuDelegate = OnOpenMenuDelegate(onOpen: refrshMenu)
        statusItem.menu?.delegate = menuDelegate
        configHandler = ConfigHandler(onChange: applyCfg)
    }
    
    func refrshMenu(menu: NSMenu) {
        if let memMenu = menu as? MemMenu {
            memMenu.refreshMenu(memoryUsage: System.memoryUsage())
        }
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
        statusItem.menu = MemMenu(conf: conf, maxMemory: state.maxMemory)
        statusItem.menu?.delegate = menuDelegate
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
