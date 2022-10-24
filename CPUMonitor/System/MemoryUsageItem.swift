//
//  MemoryUsageItem.swift
//  CPUMonitor
//
//  Created by Lennard on 18.10.22.
//

import SwiftUI

struct MemoryUsageItem: View {
    var title :String
    var value :Double
    
    var body: some View {
        Text("\(title): \(String(format: "%.2f", value)) GB")
    }
}

struct MemoryUsageItem_Previews: PreviewProvider {
    static var previews: some View {
        MemoryUsageItem(title: "test", value: 2.5)
    }
}
