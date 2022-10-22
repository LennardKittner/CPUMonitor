//
//  MainMenu.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import SwiftUI

struct MainMenu: View {
    @EnvironmentObject var systemHandler: SystemHandler
    @EnvironmentObject var configHandler: ConfigHandler
    @EnvironmentObject var licenseHandler: LicenseHandler
    @State private var curretnTab = 0

    var body: some View {
        OverallMemoryUsageItem(usage: (systemHandler.currentMemoryUsage[.active] ?? 0) + (systemHandler.currentMemoryUsage[.wired] ?? 0), total: systemHandler.physicalMemory)
        if configHandler.conf.detailedMemory {
            ForEach(systemHandler.currentMemoryUsage.keys, id: \.self) { key in
                MemoryUsageItem(title: key.rawValue, value: systemHandler.currentMemoryUsage[key] ?? 0)
            }
        }
        Divider()
        Button("Preferences") {
            TabView(currentTab: $curretnTab)
                .tag(2)
                .environmentObject(configHandler)
                .environmentObject(licenseHandler)
                .openNewWindowWithToolbar(title: "CPUMonitorApp", rect: NSRect(x: 0, y: 0, width: 450, height: 150), style: [.closable, .titled], identifier: "Settings", toolbar: Toolbar(tabs: ["About", "Settings", "Licenses"], currentTab: $curretnTab))
        }.keyboardShortcut(",")
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
            .environmentObject(SystemHandler(configHandler: ConfigHandler()))
            .environmentObject(ConfigHandler())
    }
}
