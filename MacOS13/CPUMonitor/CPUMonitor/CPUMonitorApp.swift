//
//  CPUMonitorApp.swift
//  CPUMonitor
//
//  Created by Lennard on 18.10.22.
//

import SwiftUI


//TODO: start at login
@available(macOS 13.0, *)
@main
struct CPUMonitorApp: App {
    @StateObject private var configHandler :ConfigHandler
    @StateObject private var systemHandler :SystemHandler
    @StateObject private var licenseHandler :LicenseHandler
    
    init() {
        let confH = ConfigHandler()
        self._configHandler = StateObject(wrappedValue: confH)
        self._systemHandler = StateObject(wrappedValue: SystemHandler(configHandler: confH))
        self._licenseHandler = StateObject(wrappedValue: LicenseHandler())
    }
    
    var body: some Scene {
        MenuBarExtra(content: {
            MainMenu()
                .environmentObject(configHandler)
                .environmentObject(systemHandler)
                .environmentObject(licenseHandler)
        }) {
            Image(String(Int(systemHandler.currentCpuUsage) + Int(systemHandler.currentCpuUsage) % 2))
            if configHandler.conf.showUtilization {
                Text("\(String(format: "%.2f", systemHandler.currentCpuUsage)) %")
            }
            //CPUUsage(usage: $_systemHandler.currentCpuUsage)
        }
    }
}

