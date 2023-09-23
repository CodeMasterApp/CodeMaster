//
//  MainCommands.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 23.09.23.
//

import SwiftUI
import Sparkle
import WindowManagement

struct MainCommands: Commands {
    @Environment(\.openWindow)
    var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About CodeMaster") {
                openWindow(id: SceneID.about.rawValue) 
            }

            Button("Check for updates...") {
                NSApp.sendAction(#selector(SPUStandardUpdaterController.checkForUpdates(_:)), to: nil, from: nil)
            }
        }

        CommandGroup(replacing: .appSettings) {
            Button("Settings...") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",")
        }
    }
}

