//
//  CodeMasterApp.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 16.09.23.
//

import SwiftUI
import WindowManagement

@main
struct CodeMasterApp: App {
//        @ObservedObject var settings = Settings.shared

        @Environment(\.openWindow)
        var openWindow

//        let updater: SoftwareUpdater = SoftwareUpdater()

//        init() {
//            _ = CodeEditDocumentController.shared
//            NSMenuItem.swizzle()
//            NSSplitViewItem.swizzle()
//        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
