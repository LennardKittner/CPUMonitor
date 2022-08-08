//
//  Menu.swift
//  CPUMonitor
//
//  Created by Lennard on 07.08.22.
//  Copyright © 2022 Lennard Kittner. All rights reserved.
//

import Cocoa

class MemMenu: NSMenu {

    let maxMemory: Double
    
    init(conf: ConfigData, maxMemory: Double) {
        self.maxMemory = maxMemory
        super.init(title: "memMenu")
        removeAllItems()
        addItem(createSimpleMemItem())
        
        if conf.detailedMemory {
            createDetailedMemItems().forEach(({addItem($0)}))
        }

        addItem(NSMenuItem.separator())
        addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        addItem(NSMenuItem.separator())
        addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    required init(coder: NSCoder) {
        maxMemory = 0
        super.init(coder: coder)
    }
    
    func refresh(memoryUsage: (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double)) {
        let memoryUsageA  = [memoryUsage.free, memoryUsage.inactive, memoryUsage.compressed, memoryUsage.active, memoryUsage.wired]
        (item(at: 0) as? SimpleMemItem)?.update(val1: memoryUsage.free + memoryUsage.inactive, val2: maxMemory)
        for i in 1..<items.count-2 {
            (item(at: i) as? SimpleMemItem)?.update(val1: memoryUsageA[i-1])
        }
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

}
