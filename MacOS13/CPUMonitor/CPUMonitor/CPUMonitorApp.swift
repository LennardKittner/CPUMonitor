//
//  CPUMonitorApp.swift
//  CPUMonitor
//
//  Created by Lennard on 18.10.22.
//

import SwiftUI

var configHandler = ConfigHandler()
var systemHandler = SystemHandler(configHandler: configHandler)


//TODO: Licenses
//TODO: start at login
@available(macOS 13.0, *)
@main
struct CPUMonitorApp: App {
    @StateObject private var _configHandler = configHandler
    @StateObject private var _systemHandler = systemHandler
    
    var body: some Scene {
        MenuBarExtra(content: {
            MainMenu(systemHandler: _systemHandler)
                .environmentObject(_configHandler)
        }) {
            Image(String(Int(_systemHandler.currentCpuUsage) + Int(_systemHandler.currentCpuUsage) % 2))
            //CPUUsage(usage: $_systemHandler.currentCpuUsage)
        }
    }
}

