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
//    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate
//        @ObservedObject var settings = Settings.shared

        @Environment(\.openWindow)
        var openWindow

        let updater: SoftwareUpdater = SoftwareUpdater()

//        init() {
//            _ = CodeMasterDocumentController.shared
//            NSMenuItem.swizzle()
//            NSSplitViewItem.swizzle()
//        }
    var body: some Scene {
        WindowGroup { // Change WindowGroup to Window - @N3v1
                    WelcomeWindow()
//                        .keyboardShortcut("1", modifiers: [.command, .shift])
//
//                    ExtensionManagerWindow()
//                        .keyboardShortcut("2", modifiers: [.command, .shift])
//
//                    AboutWindow()
//
//                    SettingsWindow()
//
//                    NSDocumentGroup(for: WorkspaceDocument.self) { workspace in
//                        WindowSplitView(workspace: workspace)
//                    } defaultAction: {
//                        openWindow(id: SceneID.welcome.rawValue)
//                    }
//                    .register(.document(WorkspaceDocument.self)) // Required to make transition modifier work
//                    .transition(.documentWindow)
//                    .windowToolbarStyle(.unifiedCompact(showsTitle: false))
//                    .enableOpenWindow() // Required for opening windows through NSApp
//                    .handlesExternalEvents(matching: [])
//                    .commands {
//                        CodeEditCommands()
//                    }
                }
//                .environment(\.settings, settings.preferences) // Add settings to each window environment
    }
}
