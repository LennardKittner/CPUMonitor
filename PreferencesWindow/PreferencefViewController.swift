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
    
    var appDelegate :AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
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
            atLogin.state = NSControl.StateValue(rawValue: (appDelegate?.state.config.startAtLogin)! ? 1 : 0)
            memdetail.state = NSControl.StateValue(rawValue: (appDelegate?.state.config.detailedMemory)! ? 1 : 0)
            refresh.stringValue = String(appDelegate?.state.config.refreshTime ?? 0.5)
        }
        self.parent?.view.window?.title = self.title!
    }
    
    @IBAction func autoStart(_ sender: NSButton) {
        appDelegate?.state.config.startAtLogin = !(appDelegate?.state.config.startAtLogin)!
        appDelegate?.setStartAtLogin()
        appDelegate?.writeCfg(conf: (appDelegate?.state.config)!)
        appDelegate?.applyCfg()
    }
    
    @IBAction func memorydetail(_ sender: Any) {
        appDelegate?.state.config.detailedMemory = !((appDelegate?.state.config.detailedMemory)!)
        appDelegate?.writeCfg(conf: (appDelegate?.state.config)!)
        appDelegate?.applyCfg()
    }
    
    @IBAction func refreshChange(_ sender: NSTextField) {
        if sender.doubleValue > 0.0 {
            appDelegate?.state.config.refreshTime = Double(sender.doubleValue)
            appDelegate?.timer?.invalidate()
            appDelegate?.startTimer(wait: appDelegate?.state.config.refreshTime ?? 0.5)
            appDelegate?.writeCfg(conf: (appDelegate?.state.config)!)
            appDelegate?.applyCfg()
        }
    }
    
    @IBAction func openGitHub(_ sender: Any) {
        let url = URL(string: "https://github.com/Lennard599")!
        NSWorkspace.shared.open(url)
    }
}
