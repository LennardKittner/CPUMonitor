//
//  PreferencefViewController.swift
//  ClipBoardManager
//
//  Created by Lennard Kittner on 18.08.18.
//  Copyright © 2018 Lennard Kittner. All rights reserved.
//

import Cocoa

class PreferencefViewController: NSTabViewController {
    
    @IBOutlet weak var gitHub: NSButtonCell!
    @IBOutlet weak var atLogin: NSButton!
    @IBOutlet weak var memdetail: NSButton!
    @IBOutlet weak var refresh: NSTextField!
    
    private var configHandler :ConfigHandler!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configHandler = (NSApplication.shared.delegate as! AppDelegate).configHandler
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if gitHub != nil {
            let blue = NSColor.linkColor
            let attributedStringColor = [NSAttributedStringKey.foregroundColor : blue];
            let title = NSAttributedString(string: "My GitHub", attributes: attributedStringColor)
            
            gitHub.attributedTitle = title
        }
        if atLogin != nil {
            atLogin.state = NSControl.StateValue(rawValue: configHandler.conf.startAtLogin ? 1 : 0)
            memdetail.state = NSControl.StateValue(rawValue: configHandler.conf.detailedMemory ? 1 : 0)
            refresh.stringValue = String(configHandler.conf.refreshTime)
        }
        self.parent?.view.window?.title = self.title!
    }
    
    @IBAction func autoStart(_ sender: NSButton) {
        let newConf = (configHandler.conf.copy() as! ConfigData)
        newConf.startAtLogin.toggle()
        configHandler.conf = newConf
    }
    
    @IBAction func memorydetail(_ sender: Any) {
        let newConf = (configHandler.conf.copy() as! ConfigData)
        newConf.detailedMemory.toggle()
        configHandler.conf = newConf
    }
    
    @IBAction func refreshChange(_ sender: NSTextField) {
        if sender.doubleValue > 0.0 {
            let newConf = (configHandler.conf.copy() as! ConfigData)
            newConf.refreshTime = Double(sender.doubleValue)
            configHandler.conf = newConf
        }
        sender.doubleValue = configHandler.conf.refreshTime
    }
    
    @IBAction func openGitHub(_ sender: Any) {
        let url = URL(string: "https://github.com/Lennard599")!
        NSWorkspace.shared.open(url)
    }
}
