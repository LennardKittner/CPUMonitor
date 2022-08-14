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
        (item(at: 0) as? UpdateItem)?.update(values: memoryUsage.active + memoryUsage.wired, maxMemory)
        for i in 1..<items.count-2 {
            (item(at: i) as? UpdateItem)?.update(values: memoryUsageA[i-1])
        }
    }
        
    private func createSimpleMemItem() -> NSMenuItem {
        let update = {(a: [Double]) -> String in
            if a.count < 2 {
                return ""
            }
            let per = a[0] / a[1]
            return "Memory: " + String(format: "%.2f", a[0]) + " GB / " + String(format: "%.2f", a[1]) + " GB (\(String(format: "%.0f", per*100))%)"
        }
        return UpdateItem(toolTip: "current memory usage (active + wired)", update: update)
    }
    
    private func createDetailedMemItems() -> [NSMenuItem] {
        let updateFabric = {(prefix: String) -> (([Double]) -> String) in
            return {(a: [Double]) -> String in
                if a.count < 1 {
                    return ""
                }
                return prefix + String(format: "%.2f", a.first!) + " GB"
            }
        }
        var items :[NSMenuItem] = []
        items.append(UpdateItem(toolTip: "free memory", update: updateFabric("Free: ")))
        items.append(UpdateItem(toolTip: "memory used by closed apps to speed up next launch", update: updateFabric("Inactive: ")))
        items.append(UpdateItem(toolTip: "compresed memory", update: updateFabric("Compressed: ")))
        items.append(UpdateItem(toolTip: "activly used user memory ", update: updateFabric("Active: ")))
        items.append(UpdateItem(toolTip: "system memory", update:updateFabric("Wired: ")))
        return items
    }

}
