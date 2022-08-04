//
//  SimpleMemItem.swift
//  CPUMonitor
//
//  Created by Lennard on 02.08.22.
//  Copyright © 2022 Lennard Kittner. All rights reserved.
//

import Foundation
import AppKit

class SimpleMemItem :NSMenuItem {
    
    var prefix :String
    var middle :String
    var suffix :String
    
    init(prefix :String, middle :String, suffix :String, toolTip :String) {
        self.prefix = prefix
        self.middle = middle
        self.suffix = suffix
        super.init(title: "", action: nil, keyEquivalent: "")
        self.toolTip = toolTip
        self.isEnabled = false
    }
    
    convenience init(prefix :String, suffix :String, toolTip :String) {
        self.init(prefix: prefix, middle: "", suffix: suffix, toolTip: toolTip)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(val1: Double, val2: Double) {
        //let memoryd = memoryUsage.free + memoryUsage.inactive
        // "Memory: \(String(format: "%.2f", memoryd)) GB / \(state.memory_max) GB "
        self.title = prefix + String(format: "%.2f", val1) + middle + String(format: "%.2f", val2) + suffix
    }
    
    func update(val1: Double) {
        self.title = prefix + String(format: "%.2f", val1) + middle + suffix
    }
}
