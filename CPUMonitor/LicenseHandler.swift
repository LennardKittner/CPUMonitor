//
//  LicensesHandler.swift
//  CPUMonitor
//
//  Created by Lennard on 19.10.22.
//

import Foundation

class LicenseHandler :ObservableObject {
    @Published var licenses: String = ""
    @Published var licensesAttr: AttributedString = ""
    
    init() {
        if let filePath = Bundle.main.url(forResource: "Acknowledgements", withExtension: "md") {
            var a = try? String(contentsOf: filePath)
            var b = try? AttributedString(markdown: Data(contentsOf: filePath), options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            licenses = a ?? ""
            licensesAttr = b ?? ""
        }
    }
}
