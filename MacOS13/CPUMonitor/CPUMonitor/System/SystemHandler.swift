//
//  SystemHandler.swift
//  CPUMonitor
//
//  Created by Lennard on 18.10.22.
//

import Foundation
import Combine
import SystemKit
import OrderedCollections

enum MemoryType: String {
    case free = "Free"
    case active = "Active"
    case inactive = "Inactive"
    case wired = "Wired"
    case compressed = "Compressed"
}

class SystemHandler :ObservableObject {
    let physicalMemory = System.physicalMemory()
    @Published var currentCpuUsage :Double
    @Published var currentMemoryUsage :OrderedDictionary<MemoryType, Double>
    private var timer :Timer?
    private let configHandler :ConfigHandler
    private var sys :System
    private var configSink :Cancellable!

    init(configHandler: ConfigHandler) {
        currentCpuUsage = 0
        currentMemoryUsage = [:]
        sys = System()
        self.configHandler = configHandler
        update()
        configSink = configHandler.$submit.sink(receiveValue: { _ in
            
            if self.timer?.timeInterval ?? -1 != TimeInterval(self.configHandler.conf.refreshIntervall) && self.configHandler.conf.refreshIntervall > 0 {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.configHandler.conf.refreshIntervall), target: self, selector: #selector(self.update(_:)), userInfo: nil, repeats: true)
            }
        })
    }
    
    @objc private func update(_ sender: Any?) {
        update()
    }
    
    func update() {
        currentCpuUsage = parseCPUUsage(usage: sys.usageCPU())
        currentMemoryUsage = parseMemoryUsage(usage: System.memoryUsage())
    }
    
    private func parseCPUUsage(usage: (system: Double, user: Double, idle: Double, nice: Double)) -> Double {
        return usage.user + usage.system
    }
    
    private func parseMemoryUsage(usage: (free: Double, active: Double, inactive: Double, wired: Double, compressed: Double)) -> OrderedDictionary<MemoryType, Double> {
        var dict = OrderedDictionary<MemoryType, Double>()
        dict[MemoryType.free] = usage.free
        dict[MemoryType.active] = usage.active
        dict[MemoryType.inactive] = usage.inactive
        dict[MemoryType.wired] = usage.wired
        dict[MemoryType.compressed] = usage.compressed
        return dict
    }
}

