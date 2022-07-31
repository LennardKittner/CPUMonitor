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
        // Do view setup here.
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
            atLogin.state = NSControl.StateValue(rawValue: (appDelegate?.state.startAtLogin)! ? 1 : 0)
            memdetail.state = NSControl.StateValue(rawValue: (appDelegate?.state.detailedMemory)! ? 1 : 0)
            refresh.stringValue = String(appDelegate?.state.refreshTime ?? 0.5)
        }
        //update Title
        self.parent?.view.window?.title = self.title!
    }
    
    func writeConf() {
        let conf_txt = """
        memdetail:\((appDelegate?.state.detailedMemory)! ? "yes" : "no")
        AtLogin:\((appDelegate?.state.startAtLogin)! ? "yes" : "no")
        Refresh:\(String((appDelegate?.state.refreshTime)!))
        """
        try! conf_txt.write(to: (appDelegate?.conf_file)!, atomically: true, encoding: String.Encoding.utf8)
    }
    
    @IBAction func autoStart(_ sender: NSButton) {
        appDelegate?.state.startAtLogin = !((appDelegate?.state.startAtLogin)!)
        appDelegate?.setStartAtLogin()
        writeConf()
    }
    
    @IBAction func memorydetail(_ sender: Any) {
        appDelegate?.state.detailedMemory = !((appDelegate?.state.detailedMemory)!)
        writeConf()
    }
    
    @IBAction func refreshChange(_ sender: NSTextField) {
        if sender.doubleValue > 0.0 {
            appDelegate?.state.refreshTime = Double(sender.doubleValue)
            appDelegate?.timer?.invalidate()
            appDelegate?.startTimer(wait: appDelegate?.state.refreshTime ?? 0.5)
            writeConf()
        }
    }
    
    @IBAction func openGitHub(_ sender: Any) {
        let url = URL(string: "https://github.com/Lennard599")!
        NSWorkspace.shared.open(url)
    }
}
