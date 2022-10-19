//
//  MainMenu.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import SwiftUI

struct MainMenu: View {
    var systemHandler: SystemHandler
    @EnvironmentObject var configHandler: ConfigHandler
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
                .environmentObject(configHandler)
                .openNewWindowWithToolbar(title: "CPUMonitorApp", rect: NSRect(x: 0, y: 0, width: 450, height: 150), style: [.closable, .titled], toolbar: Toolbar(tabs: ["About", "Settings"], currentTab: $curretnTab))
        }.keyboardShortcut(",")
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu(systemHandler: SystemHandler(configHandler: ConfigHandler()))
            .environmentObject(ConfigHandler())
    }
}
