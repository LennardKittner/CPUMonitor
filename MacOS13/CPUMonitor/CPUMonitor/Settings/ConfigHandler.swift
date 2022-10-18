//
//  ConfigHandler.swift
//  CPUMonitor
//
//  Created by Lennard on 06.08.22.
//  Copyright © 2022 Lennard Kittner. All rights reserved.
//

import Foundation
import Combine


class ConfigHandler :ObservableObject {
    
    // ~/Library/Containers/com.Lennard.SettingsSwitfUI/Data/Library/"Application Support"/CPUMonitor
    static let CONF_FILE = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/CPUMonitor.json")
    @Published var conf :ConfigData
    @Published var submit :Bool
    private var oldConf :ConfigData! // necessary because removeDuplicates(by: ) does not work
    private var configSink :Cancellable!
    
    init() {
        submit = true
        conf = readCfg(from: ConfigHandler.CONF_FILE) ?? ConfigData()
        oldConf = ConfigData(copy: conf)
        configSink = $conf.sink(receiveValue: { conf in
            if conf == self.oldConf {
                return
            }
            self.applySettings(conf: conf)
            writeCfg(conf, to: ConfigHandler.CONF_FILE)
            self.oldConf = ConfigData(copy: conf)
        })
        applySettings(conf: conf)
    }
    
    private func applySettings(conf: ConfigData) {
        
    }
}
    
func readCfg(from file: URL) -> ConfigData? {
    if let data = try? Data(contentsOf: file) {
        let decoder = JSONDecoder()
        return try? decoder.decode(ConfigData.self, from: data)
    }
    return nil
}

func writeCfg(_ conf: ConfigData, to file: URL) {
    if let jsonData = try? JSONEncoder().encode(conf) {
        try? FileManager.default.createDirectory(atPath: file.deletingLastPathComponent().path, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)
        try? jsonData.write(to: file)
    }
}
