//
//  ConfigData.swift
//  SettingsSwitfUI
//
//  Created by Lennard on 04.10.22.
//

import Foundation


func ==(op1: ConfigData, op2: ConfigData) -> Bool {
    return op1.atLogin == op2.atLogin
        && op1.detailedMemory == op2.detailedMemory
        && op1.showUtilization == op2.showUtilization
        && (abs(op1.refreshIntervall-op2.refreshIntervall) < Float.ulpOfOne * abs(op1.refreshIntervall+op2.refreshIntervall))
}

final class ConfigData: Decodable, Encodable {
    var detailedMemory :Bool
    var refreshIntervall :Float
    var atLogin :Bool
    var showUtilization :Bool
    
    enum CodingKeys: CodingKey {
        case detailedMemory
        case refreshIntervall
        case atLogin
        case showUtilization
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.refreshIntervall = try container.decode(Float.self, forKey: .refreshIntervall)
        self.detailedMemory = try container.decode(Bool.self, forKey: .detailedMemory)
        self.atLogin = try container.decode(Bool.self, forKey: .atLogin)
        self.showUtilization = try container.decode(Bool.self, forKey: .showUtilization)
    }
    
    init() {
        detailedMemory = false
        refreshIntervall = 2
        atLogin = false
        showUtilization = false
    }
    
    init(copy: ConfigData) {
        detailedMemory = copy.detailedMemory
        refreshIntervall = copy.refreshIntervall
        atLogin = copy.atLogin
        showUtilization = copy.showUtilization
    }
}
