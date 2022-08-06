//
//  State.swift
//  CPUMonitor
//
//  Created by Lennard on 05.08.22.
//  Copyright © 2022 Lennard Kittner. All rights reserved.
//

import Foundation

class ConfigData :NSObject {
    @objc public var startAtLogin = false
    @objc public var detailedMemory = false
    @objc public var refreshTime :Double = 0.5
}
