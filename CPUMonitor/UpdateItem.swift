//
//  UpdateItem.swift
//  CPUMonitor
//
//  Created by Lennard on 02.08.22.
//  Copyright © 2022 Lennard Kittner. All rights reserved.
//

import Foundation
import AppKit

class UpdateItem :NSMenuItem {
    
    let updateCallBack :([Double]) -> String
    
    init(toolTip :String, update: @escaping ([Double]) -> String) {
        self.updateCallBack = update
        super.init(title: "", action: nil, keyEquivalent: "")
        self.toolTip = toolTip
        self.isEnabled = false
    }
    
    required init(coder: NSCoder) {
        self.updateCallBack = {(a) in String(describing: a)}
        super.init(coder: coder)
    }
    
    func update(values: Double...) {
        self.title = updateCallBack(values)
    }
 
}
