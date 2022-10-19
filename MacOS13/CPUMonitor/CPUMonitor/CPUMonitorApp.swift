//
//  CPUMonitorApp.swift
//  CPUMonitor
//
//  Created by Lennard on 18.10.22.
//

import SwiftUI

var configHandler = ConfigHandler()
var systemHandler = SystemHandler(configHandler: configHandler)

@main
struct CPUMonitorApp: App {
    @StateObject private var _configHandler = configHandler
    @StateObject private var _systemHandler = systemHandler
    @State private var curretnTab = 0
    
    var body: some Scene {
        WindowGroup("") {
            Text("placeholder")
            CPUUsage(usage: $_systemHandler.currentCpuUsage)
        }
        .commands {
            CommandMenu("My Top Menu") {
                CPUUsage(usage: $_systemHandler.currentCpuUsage)
                Divider()
                OverallMemoryUsageItem(usage: (_systemHandler.currentMemoryUsage[.active] ?? 0) + (_systemHandler.currentMemoryUsage[.wired] ?? 0), total: _systemHandler.physicalMemory)
                ForEach(_systemHandler.currentMemoryUsage.keys, id: \.self) { key in
                    MemoryUsageItem(title: key.rawValue, value: _systemHandler.currentMemoryUsage[key] ?? 0)
                }
                Divider()
                Button("Preferences") {
                    TabView(currentTab: $curretnTab)
                        .environmentObject(configHandler)
                        .openNewWindowWithToolbar(title: "CPUMonitorApp", rect: NSRect(x: 0, y: 0, width: 450, height: 150), style: [.closable, .titled], toolbar: Toolbar(tabs: ["About", "Settings"], currentTab: $curretnTab))
                }.keyboardShortcut(",")
                Divider()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q")
            }
        }
    }
}
