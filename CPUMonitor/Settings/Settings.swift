//
//  Settings.swift
//  SettingsSwitfUI
//
//  Created by Lennard on 02.10.22.
//

import SwiftUI
import Combine


struct Settings: View {
    @EnvironmentObject private var configHandler :ConfigHandler
    @State private var error = false
    
    func validatePositiveInt(_ string: String) -> Int? {
        if let num = Int(string) {
            if num > 0 {
                return num
            }
        }
        return nil
    }
    
    func validatePositiveFloat(_ string: String) -> Float? {
        if let num = Float(string) {
            if num > 0 {
                return num
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if error {
            Text("Please enter a positive number")
                    .foregroundColor(.red)
            }
            HStack {
                Text("Refresh intervall:")
                    .padding(.trailing, 34)
                ValidatedTextField(content: $configHandler.conf.refreshIntervall, error: $error, validate: validatePositiveFloat(_:))
                    .frame(width: 100)
                Text("seconds")
            }
            HStack {
                Text("Detailed memory view:")
                    .padding(.trailing, -0.75)
                Toggle(isOn: $configHandler.conf.detailedMemory) {
                    
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            HStack {
                Text("Show CPU utilization:")
                    .padding(.trailing, 7)
                Toggle(isOn: $configHandler.conf.showUtilization) {
                    
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            HStack {
                Text("Start at login:")
                    .padding(.trailing, 55)
                Toggle(isOn: $configHandler.conf.atLogin) {
                    
                }
                .toggleStyle(CheckboxToggleStyle())
                .onChange(of: configHandler.conf.atLogin, perform: {b in
                    configHandler.applyAtLognin()
                })
            }
        }
        .padding(.leading, -95.0)
    }


}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(ConfigHandler())
            .frame(width: 450, height: 150)
    }
}
