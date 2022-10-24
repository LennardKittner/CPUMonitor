//
//  OverallMemoryUsageItem.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import SwiftUI

struct OverallMemoryUsageItem: View {
    var usage :Double
    var total :Double
    
    var body: some View {
        Text("Memory: \(String(format: "%.2f", usage)) / \(String(format: "%.2f", total)) GB (\(String(format: "%.0f", usage / total * 100))%)")
    }
}

struct OverallMemoryUsageItem_Previews: PreviewProvider {
    static var previews: some View {
        OverallMemoryUsageItem(usage: 2, total: 8)
    }
}
