//
//  Licenses.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import SwiftUI

struct Licenses: View {
    @EnvironmentObject var licenseHandler :LicenseHandler
    
    var body: some View {
        ScrollView {
            Text(licenseHandler.licensesAttr)
                .padding(15)
        }
    }
}

struct Licenses_Previews: PreviewProvider {
    static var previews: some View {
        Licenses()
            .environmentObject(LicenseHandler())
    }
}
