//
//  Licenses.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import SwiftUI

struct Licenses: View {
    var licenseHandler :LicenseHandler
    
    var body: some View {
        ScrollView {
            Text(licenseHandler.licensesAttr)
        }
    }
}

struct Licenses_Previews: PreviewProvider {
    static var previews: some View {
        Licenses(licenseHandler: LicenseHandler())
    }
}
