//
//  AppDelegate.swift
//  CodeMaster
//
//  Created by Nevio Hirani on 28.09.23.
//

import SwiftUI
import CodeMasterSymbols

final class AppDelegate: NSObject, NSApplicationDelegate, ObservedObject {
    private let updater = SoftwareUpdater()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        enableWindowSizeSaveOnQuit()
        Settings.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()
        
        NSApp.closeWindow(.welcome, .about)
        
        DispatchQueue.main.async {
            var needToHandleOpen = true
            
            // If no windows were reopened by NSQuitAlwaysKeepsWindows, do default behavior.
            // Non-WindowGroup SwiftUI Windows are still in NSApp.windows when they are closed,
            // So we need to think about those.
            if NSApp.windows.count > NSApp.openSwiftUIWindows {
                needToHandleOpen = false
            }
            
            for index in 0..<CommandLine.arguments.count {
                if CommandLine.arguments[index] == "--open" && (index + 1) < CommandLine.arguments.count {
                    let path = CommandLine.arguments[index+1]
                    let url = URL(fileURLWithPath: path)

                    CodeMasterDocumentController.shared.reopenDocument(
                        for: url,
                        withContentsOf: url,
                        display: true
                    ) { document, _, _ in
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }

                    needToHandleOpen = false
                }
            }
            
            if needToHandleOpen {
                self.handleOpen()
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }
        
        handleOpen()
        
        return false
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }
    
    func handleOpen() {
        let behavior = Settings.shared.preferences.general.reopenBehavior

        switch behavior {
        case .welcome:
            NSApp.openWindow(.welcome)
        case .openPanel:
            CodeMasterDocumentController.shared.openDocument(self)
        case .newDocument:
            CodeMasterDocumentController.shared.newDocument(self)
        }
    }
    
    /// Handle urls with the form `codemaster://file/{filepath}:{line}:{column}`
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            let file = URL(fileURLWithPath: url.path).path.split(separator: ":")
            let filePath = URL(fileURLWithPath: String(file[0]))
            let line = file.count > 1 ? Int(file[1]) ?? 0 : 0
            let column = file.count > 2 ? Int(file[2]) ?? 1 : 1
            
            CodeMasterDocumentController.shared
                .openDocument(withContentsOf: filePath, display: true) { document, _, error in
                    if let error {
                        NSAlert(error: error).runModal()
                        return
                    }
                    if line > 0, let document = document as? CodeFileDocument {
                        document.cursorPosition = (line, column > 0 ? column : 1)
                    }
                }
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let projects: [String] = CodeMasterDocumentController.shared.documents
            .map { doc in
                (doc as? WorkspaceDocument)?.fileURL?.path
            }
            .filter { $0 != nil }
            .map { $0! }

        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)
        
        let areAllDocumentsClean = CodeMasterDocumentController.shared.documents.allSatisfy { !$0.isDocumentEdited }
        guard areAllDocumentsClean else {
            CodeMasterDocumentController.shared.closeAllDocuments(
                withDelegate: self,
                didCloseAllSelector: #selector(documentController(_:didCloseAll:contextInfo:)),
                contextInfo: nil
            )
            return .terminateLater
        }
        
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
    
    // MARK: - Open windows
    @IBAction private func openWelcome(_ sender: Any) {
        NSApp.openWindow(.welcome)
    }
    
    @IBAction private func openAbout(_ sender: Any) {
            NSApp.openWindow(.about)
        }

    @IBAction func openFeedback(_ sender: Any) {
        if tryFocusWindow(of: FeedbackView.self) { return }

        FeedbackView().showWindow()
    }

    @IBAction private func checkForUpdates(_ sender: Any) {
        updater.checkForUpdates()
    }
    
    /// Tries to focus a window with specified view content type.
    /// - Parameter type: The type of viewContent which hosted in a window to be focused.
    /// - Returns: `true` if window exist and focused, otherwise - `false`
    private func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
        guard let window = NSApp.windows.filter({ ($0.contentView as? NSHostingView<T>) != nil }).first
        else { return false }

        window.makeKeyAndOrderFront(self)
        return true
    }
    
    // MARK: - Open With CodeMaster (Extension) functions
    private func checkForFilesToOpen() {
        guard let defaults = UserDefaults.init(
                suiteName: "app.codemaster.CodeMaster.shared"
        ) else {
            print("Failed to get/init shared defaults")
            return
        }
        
        // Register enableOpenInCM (enable Open In CodeMaster)
        defaults.register(defaults: ["enableOpenInCM": true])
        
        if let filesToOpen = defaults.string(forKey: "openInCMFiles") {
            let files = filesToOpen.split(separator: ";")

            for filePath in files {
                let fileURL = URL(fileURLWithPath: String(filePath))
                CodeMasterDocumentController.shared.reopenDocument(
                    for: fileURL,
                    withContentsOf: fileURL,
                    display: true
                ) { document, _, _ in
                    document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                }
            }

            defaults.removeObject(forKey: "openInCMFiles")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkForFilesToOpen()
        }
    }
    /// Enable window size restoring on app relaunch after quitting.
    private func enableWindowSizeSaveOnQuit() {
        // This enables window restoring on normal quit (instead of only on force-quit).
        UserDefaults.standard.setValue(true, forKey: "NSQuitAlwaysKeepsWindows")
    }
    // MARK: NSDocumentController delegate

    @objc
    func documentController(_ docController: NSDocumentController, didCloseAll: Bool, contextInfo: Any) {
        NSApplication.shared.reply(toApplicationShouldTerminate: didCloseAll)
    }
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}
